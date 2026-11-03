import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../domain/entities/identity_verification.dart';
import '../../domain/entities/identity_verification_draft.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/entities/user_address.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository({
    required AuthTokenStorage tokenStorage,
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _tokenStorage = tokenStorage,
       _client = client ?? http.Client();

  final AuthTokenStorage _tokenStorage;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<UserProfile?> getProfile() {
    return _loadProfile();
  }

  @override
  Future<UserProfile?> refreshProfile() {
    return _loadProfile();
  }

  @override
  Future<UserProfile> updateProfile(ProfileUpdateRequest request) async {
    final String token = await _requireAccessToken();

    final Map<String, dynamic> body = <String, dynamic>{
      'address': <String, dynamic>{
        'residentialAddress': request.address.residentialAddress.trim(),
        'city': request.address.city.trim(),
        'country': request.address.country.trim(),
      },
    };

    if (request.fullName != null) {
      body['fullName'] = request.fullName!.trim();
    }

    if (request.dateOfBirth != null) {
      body['dateOfBirth'] = _dateOnly(request.dateOfBirth!);
    }

    if (request.gender != null) {
      body['gender'] = request.gender!.name;
    }

    final http.Response response = await _client
        .patch(
          Uri.parse(
            '${ApiConfig.baseUrl}'
            '/api/profile/me',
          ),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(requestTimeout);

    final Map<String, dynamic> json = _decodeSuccessfulResponse(
      response,
      expectedStatus: 200,
    );

    return _profileFromResponse(json);
  }

  Future<UserProfile> _loadProfile() async {
    final String token = await _requireAccessToken();

    final http.Response response = await _client
        .get(
          Uri.parse(
            '${ApiConfig.baseUrl}'
            '/api/profile/me',
          ),
          headers: <String, String>{
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(requestTimeout);

    final Map<String, dynamic> json = _decodeSuccessfulResponse(
      response,
      expectedStatus: 200,
    );

    return _profileFromResponse(json);
  }

  UserProfile _profileFromResponse(Map<String, dynamic> response) {
    final Object? rawProfile = response['profile'];

    if (rawProfile is! Map<String, dynamic>) {
      throw const FormatException('Profile response is invalid.');
    }

    final Map<String, dynamic> profile = rawProfile;

    final Object? rawAddress = profile['address'];

    final Map<String, dynamic> address = rawAddress is Map<String, dynamic>
        ? rawAddress
        : <String, dynamic>{};

    final Object? rawVerification = profile['identityVerification'];

    final Map<String, dynamic> verification =
        rawVerification is Map<String, dynamic>
        ? rawVerification
        : <String, dynamic>{};

    final String maskedIdentityNumber =
        _optionalString(profile['maskedIdentityNumber']) ?? '*****-*******-*';

    return UserProfile(
      id: _requiredString(profile['id'], 'id'),
      fullName: _requiredString(profile['fullName'], 'fullName'),
      emailAddress: _requiredString(profile['emailAddress'], 'emailAddress'),
      mobileNumber: _requiredString(profile['mobileNumber'], 'mobileNumber'),
      dateOfBirth: _parseDate(profile['dateOfBirth']),
      gender: _parseGender(profile['gender']),
      maskedIdentityNumber: maskedIdentityNumber,
      address: UserAddress(
        residentialAddress:
            _optionalString(address['residentialAddress']) ?? '',
        city: _optionalString(address['city']) ?? '',
        country: _optionalString(address['country']) ?? '',
      ),
      role: _requiredString(profile['role'], 'role'),
      identityVerification: IdentityVerification(
        status: _parseStatus(verification['status']),
        maskedIdentityNumber:
            _optionalString(verification['maskedIdentityNumber']) ??
            maskedIdentityNumber,
        submittedAt: _parseDate(verification['submittedAt']),
        verifiedAt: _parseDate(verification['verifiedAt']),
        rejectionReason: _optionalString(verification['rejectionReason']),
        expiresAt: _parseDate(verification['expiresAt']),
        additionalCaptureSide: _parseCaptureSide(
          verification['additionalCaptureSide'],
        ),
        providerReference: _optionalString(verification['providerReference']),
        proofRecordHash: _optionalString(verification['proofRecordHash']),
      ),
    );
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
      throw StateError(
        'Your session has expired. '
        'Please sign in again.',
      );
    }

    if (response.statusCode != expectedStatus) {
      throw StateError(
        _extractErrorMessage(
          response.body,
          'Profile request failed with '
          'status '
          '${response.statusCode}.',
        ),
      );
    }

    final Object? decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid profile response.');
    }

    return decoded;
  }

  String _requiredString(Object? value, String field) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    throw FormatException(
      'Profile field "$field" '
      'is missing.',
    );
  }

  String? _optionalString(Object? value) {
    if (value is! String) {
      return null;
    }

    final String result = value.trim();

    return result.isEmpty ? null : result;
  }

  DateTime? _parseDate(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  ProfileGender? _parseGender(Object? value) {
    return switch (value) {
      'male' => ProfileGender.male,
      'female' => ProfileGender.female,
      'other' => ProfileGender.other,
      'preferNotToSay' => ProfileGender.preferNotToSay,
      _ => null,
    };
  }

  IdentityVerificationStatus _parseStatus(Object? value) {
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

  IdentityCaptureSide? _parseCaptureSide(Object? value) {
    return switch (value) {
      'front' => IdentityCaptureSide.front,
      'back' => IdentityCaptureSide.back,
      'selfie' => IdentityCaptureSide.selfie,
      _ => null,
    };
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
      // Use safe fallback.
    }

    return fallback;
  }
}
