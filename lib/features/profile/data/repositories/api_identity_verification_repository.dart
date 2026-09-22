import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../domain/entities/identity_verification.dart';
import '../../domain/entities/identity_verification_draft.dart';
import '../../domain/repositories/identity_verification_repository.dart';

class ApiIdentityVerificationRepository
    implements IdentityVerificationRepository {
  ApiIdentityVerificationRepository({
    required AuthTokenStorage tokenStorage,
    required Future<String> Function() canonicalAccountNameLoader,
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _tokenStorage = tokenStorage,
       _canonicalAccountNameLoader = canonicalAccountNameLoader,
       _client = client ?? http.Client();

  final AuthTokenStorage _tokenStorage;
  final Future<String> Function() _canonicalAccountNameLoader;
  final http.Client _client;
  final Duration requestTimeout;

  final Map<String, IdentityCaptureInput> _temporaryCaptures =
      <String, IdentityCaptureInput>{};

  IdentityVerificationProgress? _verificationProgress;

  int _uploadSequence = 1;
  int _captureSequence = 1;

  @override
  Future<String> getCanonicalAccountName() async {
    final Map<String, dynamic> response = await _getJson(
      '/api/identity/details',
    );

    final Map<String, dynamic>? verification = _verificationMap(response);

    final Object? fullName = verification?['fullName'];

    if (fullName is String && fullName.trim().isNotEmpty) {
      return fullName.trim();
    }

    return _canonicalAccountNameLoader();
  }

  @override
  Future<IdentityVerification> getIdentityVerification() async {
    final Map<String, dynamic> statusResponse = await _getJson(
      '/api/identity/status',
    );

    final Map<String, dynamic>? statusData = _verificationMap(statusResponse);

    final IdentityVerificationStatus status = _statusFromApi(
      statusData?['status'],
    );

    String maskedIdentityNumber = '*****-*******-*';

    if (status != IdentityVerificationStatus.notStarted) {
      final Map<String, dynamic> detailsResponse = await _getJson(
        '/api/identity/details',
      );

      final Map<String, dynamic>? details = _verificationMap(detailsResponse);

      maskedIdentityNumber = _maskCnic(details?['cnicNumber']);
    }

    final DateTime? submittedAt = _parseDate(statusData?['submittedAt']);

    final DateTime? reviewedAt = _parseDate(statusData?['reviewedAt']);

    final Object? rejectionReason = statusData?['rejectionReason'];

    return IdentityVerification(
      status: status,
      maskedIdentityNumber: maskedIdentityNumber,
      submittedAt: submittedAt,
      verifiedAt: status == IdentityVerificationStatus.verified
          ? reviewedAt
          : null,
      rejectionReason:
          rejectionReason is String && rejectionReason.trim().isNotEmpty
          ? rejectionReason
          : null,
    );
  }

  @override
  Future<IdentityVerification> startIdentityVerification() async {
    final IdentityVerification current = await getIdentityVerification();

    switch (current.status) {
      case IdentityVerificationStatus.submitted:
      case IdentityVerificationStatus.pending:
      case IdentityVerificationStatus.verified:
        return current;

      case IdentityVerificationStatus.notStarted:
      case IdentityVerificationStatus.capturing:
      case IdentityVerificationStatus.rejected:
      case IdentityVerificationStatus.expired:
      case IdentityVerificationStatus.additionalCaptureRequired:
      case IdentityVerificationStatus.technicalFailure:
        return IdentityVerification(
          status: IdentityVerificationStatus.capturing,
          maskedIdentityNumber: current.maskedIdentityNumber,
        );
    }
  }

  @override
  Future<IdentityVerificationProgress?> getVerificationProgress() async {
    return _verificationProgress;
  }

  @override
  Future<void> saveVerificationProgress(
    IdentityVerificationProgress progress,
  ) async {
    _verificationProgress = progress;
  }

  @override
  Future<void> clearVerificationProgress() async {
    _verificationProgress = null;
  }

  @override
  Future<IdentityUploadSession> createUploadSession() async {
    final DateTime now = DateTime.now();

    return IdentityUploadSession(
      sessionId:
          'identity-upload-'
          '${now.microsecondsSinceEpoch}-'
          '${_uploadSequence++}',
      expiresAt: now.add(const Duration(minutes: 10)),
    );
  }

  @override
  Future<IdentityCaptureEvidence> registerCapture(
    IdentityUploadSession session,
    IdentityCaptureInput capture,
  ) async {
    if (session.expiresAt.isBefore(DateTime.now())) {
      throw StateError('The secure upload session has expired.');
    }

    if (!capture.quality.passesFrontendChecks) {
      throw StateError('The capture did not pass quality checks.');
    }

    final File file = File(capture.temporaryPath);

    if (!await file.exists()) {
      throw StateError('The temporary capture is unavailable.');
    }

    final bool duplicate = _temporaryCaptures.values.any(
      (IdentityCaptureInput existing) =>
          existing.side != capture.side &&
          existing.fingerprint == capture.fingerprint,
    );

    if (duplicate) {
      throw StateError('Each identity capture must be unique.');
    }

    final String captureId =
        'identity-capture-'
        '${DateTime.now().microsecondsSinceEpoch}-'
        '${_captureSequence++}';

    _temporaryCaptures[captureId] = capture;

    return IdentityCaptureEvidence(
      captureId: captureId,
      side: capture.side,
      fingerprint: capture.fingerprint,
      quality: capture.quality,
    );
  }

  @override
  Future<void> discardCapture(String captureId) async {
    final IdentityCaptureInput? capture = _temporaryCaptures.remove(captureId);

    await _deleteTemporaryCapture(capture?.temporaryPath);
  }

  @override
  Future<IdentityVerification> submitIdentityVerification(
    IdentityVerificationSubmission submission,
  ) async {
    if (!submission.consentConfirmed) {
      throw StateError('Identity verification consent is required.');
    }

    if (submission.uploadSession.expiresAt.isBefore(DateTime.now())) {
      throw StateError('The secure upload session has expired.');
    }

    // Makes retries safer.
    //
    // If the previous upload already reached the backend but
    // Flutter did not receive the response, do not submit again.
    final IdentityVerification current = await getIdentityVerification();

    if (current.status == IdentityVerificationStatus.submitted ||
        current.status == IdentityVerificationStatus.pending ||
        current.status == IdentityVerificationStatus.verified) {
      return current;
    }

    final IdentityCaptureInput front = _captureForEvidence(submission.front);

    final IdentityCaptureInput back = _captureForEvidence(submission.back);

    final IdentityCaptureInput selfie = _captureForEvidence(submission.selfie);

    if (front.fingerprint == back.fingerprint) {
      throw StateError('Front and back captures must be different.');
    }

    // First create/update the identity details record.
    await _postJson('/api/identity/details', <String, dynamic>{
      'fullName': submission.legalDetails.fullLegalName.trim(),
      'cnicNumber': submission.legalDetails.cnicNumber.trim(),
      'gender': submission.legalDetails.gender.name,
      'dateOfBirth': _dateOnly(submission.legalDetails.dateOfBirth),
      'cnicExpiryDate': _dateOnly(submission.legalDetails.cnicExpiryDate),
    });

    // Then upload all three images as multipart/form-data.
    final Map<String, dynamic> uploadResponse = await _uploadDocuments(
      frontPath: front.temporaryPath,
      backPath: back.temporaryPath,
      selfiePath: selfie.temporaryPath,
    );

    final Map<String, dynamic>? verification = _verificationMap(uploadResponse);

    if (verification == null) {
      throw const FormatException('Identity verification response is invalid.');
    }

    final IdentityVerificationStatus status = _statusFromApi(
      verification['status'],
    );

    final IdentityVerification result = IdentityVerification(
      status: status,
      maskedIdentityNumber: _maskCnic(submission.legalDetails.cnicNumber),
      submittedAt: _parseDate(verification['submittedAt']),
    );

    _verificationProgress = IdentityVerificationProgress(
      consentConfirmed: submission.consentConfirmed,
      nameChangeConfirmed: submission.accountNameChangeConfirmed,
      legalDetails: submission.legalDetails,
    );

    await _deleteAllTemporaryCaptures();

    return result;
  }

  @override
  Future<void> cancelIdentityVerification() async {
    _verificationProgress = null;

    await _deleteAllTemporaryCaptures();

    // There is currently no backend DELETE/CANCEL endpoint.
    // If details were already stored with status "capturing",
    // the backend record remains editable.
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    final String token = await _requireAccessToken();

    final http.Response response = await _client
        .get(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(requestTimeout);

    return _decodeSuccessfulResponse(response, expectedStatus: 200);
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final String token = await _requireAccessToken();

    final http.Response response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(requestTimeout);

    return _decodeSuccessfulResponse(response, expectedStatus: 200);
  }

  Future<Map<String, dynamic>> _uploadDocuments({
    required String frontPath,
    required String backPath,
    required String selfiePath,
  }) async {
    final String token = await _requireAccessToken();

    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConfig.baseUrl}'
        '/api/identity/documents',
      ),
    );

    request.headers.addAll(<String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'cnicFront',
        frontPath,
        contentType: _imageMediaType(frontPath),
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'cnicBack',
        backPath,
        contentType: _imageMediaType(backPath),
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'selfie',
        selfiePath,
        contentType: _imageMediaType(selfiePath),
      ),
    );

    final http.StreamedResponse streamedResponse = await _client
        .send(request)
        .timeout(requestTimeout);

    final String responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 401) {
      throw StateError('Your session has expired. Please sign in again.');
    }

    if (streamedResponse.statusCode != 201) {
      throw StateError(
        _extractErrorMessage(
          responseBody,
          'Identity document upload failed with status '
          '${streamedResponse.statusCode}.',
        ),
      );
    }

    final Object? decoded = jsonDecode(responseBody);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid identity upload response.');
    }

    return decoded;
  }

  Future<String> _requireAccessToken() async {
    final String? token = await _tokenStorage.readAccessToken();

    if (token == null || token.trim().isEmpty) {
      throw StateError('Authentication is required.');
    }

    return token;
  }

  Map<String, dynamic> _decodeSuccessfulResponse(
    http.Response response, {
    required int expectedStatus,
  }) {
    if (response.statusCode == 401) {
      throw StateError('Your session has expired. Please sign in again.');
    }

    if (response.statusCode != expectedStatus) {
      throw StateError(
        _extractErrorMessage(
          response.body,
          'Request failed with status '
          '${response.statusCode}.',
        ),
      );
    }

    final Object? decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid server response.');
    }

    return decoded;
  }

  Map<String, dynamic>? _verificationMap(Map<String, dynamic> response) {
    final Object? verification = response['verification'];

    if (verification is Map<String, dynamic>) {
      return verification;
    }

    return null;
  }

  IdentityCaptureInput _captureForEvidence(IdentityCaptureEvidence evidence) {
    final IdentityCaptureInput? capture =
        _temporaryCaptures[evidence.captureId];

    if (capture == null ||
        capture.side != evidence.side ||
        capture.fingerprint != evidence.fingerprint) {
      throw StateError('Identity verification evidence is incomplete.');
    }

    return capture;
  }

  IdentityVerificationStatus _statusFromApi(Object? value) {
    return switch (value) {
      'notStarted' => IdentityVerificationStatus.notStarted,

      'capturing' => IdentityVerificationStatus.capturing,

      'submitted' => IdentityVerificationStatus.submitted,

      'pending' => IdentityVerificationStatus.pending,

      'verified' => IdentityVerificationStatus.verified,

      'rejected' => IdentityVerificationStatus.rejected,

      'expired' => IdentityVerificationStatus.expired,

      'additionalCaptureRequired' =>
        IdentityVerificationStatus.additionalCaptureRequired,

      'technicalFailure' => IdentityVerificationStatus.technicalFailure,

      _ => IdentityVerificationStatus.technicalFailure,
    };
  }

  String _maskCnic(Object? value) {
    if (value is! String) {
      return '*****-*******-*';
    }

    final String digits = value.replaceAll(RegExp('[^0-9]'), '');

    if (digits.isEmpty) {
      return '*****-*******-*';
    }

    return '*****-*******-'
        '${digits.substring(digits.length - 1)}';
  }

  DateTime? _parseDate(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  String _dateOnly(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');

    final String month = date.month.toString().padLeft(2, '0');

    final String day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final Object? decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        final Object? message = decoded['message'];

        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      // Use the safe fallback below.
    }

    return fallback;
  }

  MediaType _imageMediaType(String path) {
    final String lower = path.toLowerCase();

    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }

    if (lower.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }

    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }

    throw StateError('Unsupported identity image format.');
  }

  Future<void> _deleteAllTemporaryCaptures() async {
    final List<String> paths = _temporaryCaptures.values
        .map((IdentityCaptureInput capture) => capture.temporaryPath)
        .toList();

    _temporaryCaptures.clear();

    for (final String path in paths) {
      await _deleteTemporaryCapture(path);
    }
  }

  Future<void> _deleteTemporaryCapture(String? path) async {
    if (path == null || path.startsWith('synthetic:')) {
      return;
    }

    final File file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }
}
