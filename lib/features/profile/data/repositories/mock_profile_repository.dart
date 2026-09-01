import 'dart:io';

import '../../domain/entities/identity_verification.dart';
import '../../domain/entities/identity_verification_draft.dart';
import '../../domain/entities/profile_field_permissions.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/entities/user_address.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/identity_verification_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/services/account_name_policy.dart';

class MockProfileRepository
    implements ProfileRepository, IdentityVerificationRepository {
  MockProfileRepository({
    this.delay = const Duration(milliseconds: 350),
    this.failLoading = false,
    this.failUpdate = false,
    this.failVerification = false,
    this.emptyProfile = false,
    this.verificationOutcome = IdentityVerificationStatus.pending,
    this.initialVerificationStatus = IdentityVerificationStatus.verified,
    UserProfile? initialProfile,
  }) : _profile = emptyProfile
           ? null
           : initialProfile ?? _profileForStatus(initialVerificationStatus);

  final Duration delay;
  final bool failLoading;
  final bool failUpdate;
  final bool failVerification;
  final bool emptyProfile;
  final IdentityVerificationStatus verificationOutcome;
  final IdentityVerificationStatus initialVerificationStatus;

  UserProfile? _profile;
  int getProfileCallCount = 0;
  int identityLoadCallCount = 0;
  int updateProfileCallCount = 0;
  int verificationCallCount = 0;
  int uploadSessionCallCount = 0;
  int captureRegistrationCallCount = 0;
  int verificationSubmissionCallCount = 0;
  int _uploadSequence = 1;
  int _captureSequence = 1;
  final Map<String, IdentityCaptureInput> _temporaryCaptures =
      <String, IdentityCaptureInput>{};
  IdentityVerificationProgress? _verificationProgress;

  static final UserProfile _defaultProfile = UserProfile(
    id: 'user-insurex-001',
    fullName: 'Saim Ahmad',
    emailAddress: 'Saim.Ahmad@example.com',
    mobileNumber: '+92 300 123 4567',
    dateOfBirth: DateTime(1993, 5, 18),
    gender: ProfileGender.female,
    maskedIdentityNumber: '*****-*******-3',
    address: const UserAddress(
      residentialAddress: 'House 24, Street 8, F-10/2',
      city: 'Islamabad',
      country: 'Pakistan',
    ),
    role: 'Policyholder',
    identityVerification: IdentityVerification(
      status: IdentityVerificationStatus.verified,
      maskedIdentityNumber: '*****-*******-3',
      submittedAt: DateTime(2026, 6, 10, 11, 30),
      verifiedAt: DateTime(2026, 6, 10, 14, 15),
    ),
  );

  static UserProfile _profileForStatus(IdentityVerificationStatus status) {
    if (status == IdentityVerificationStatus.verified) {
      return _defaultProfile;
    }
    const String unavailableIdentity = '*****-*******-*';
    return _defaultProfile.copyWith(
      maskedIdentityNumber: unavailableIdentity,
      identityVerification: IdentityVerification(
        status: status,
        maskedIdentityNumber: unavailableIdentity,
      ),
    );
  }

  @override
  Future<UserProfile?> getProfile() async {
    getProfileCallCount++;
    await _wait();
    _throwIfLoadingFails();
    return _profile;
  }

  @override
  Future<UserProfile?> refreshProfile() => getProfile();

  Future<void> initializeUnverifiedAccountName(String fullName) async {
    final UserProfile? current = _profile;
    if (current == null) {
      throw StateError('The profile is unavailable.');
    }
    const String unavailableIdentity = '*****-*******-*';
    _profile = current.copyWith(
      fullName: AccountNamePolicy.normalizeForDisplay(fullName),
      maskedIdentityNumber: unavailableIdentity,
      identityVerification: const IdentityVerification(
        status: IdentityVerificationStatus.notStarted,
        maskedIdentityNumber: unavailableIdentity,
      ),
    );
    _verificationProgress = null;
    await _deleteAllTemporaryCaptures();
  }

  @override
  Future<UserProfile> updateProfile(ProfileUpdateRequest request) async {
    updateProfileCallCount++;
    await _wait();
    if (failUpdate) {
      throw StateError('Unable to update profile.');
    }
    final UserProfile? current = _profile;
    if (current == null) {
      throw StateError('The profile is unavailable.');
    }

    final ProfileFieldPermissions permissions =
        ProfileFieldPermissions.forVerificationStatus(
          current.identityVerification.status,
        );
    if ((request.fullName != null && !permissions.canEditLegalName) ||
        (request.dateOfBirth != null && !permissions.canEditDateOfBirth) ||
        (request.gender != null && !permissions.canEditGender)) {
      throw StateError(
        'Protected identity information cannot be updated directly.',
      );
    }
    final UserProfile updated = current.copyWith(
      fullName: request.fullName?.trim(),
      dateOfBirth: request.dateOfBirth,
      gender: request.gender,
      address: request.address.copyWith(
        residentialAddress: request.address.residentialAddress.trim(),
        city: request.address.city.trim(),
        country: request.address.country.trim(),
      ),
    );
    _profile = updated;
    return updated;
  }

  @override
  Future<IdentityVerification> getIdentityVerification() async {
    identityLoadCallCount++;
    await _wait();
    _throwIfLoadingFails();
    final UserProfile? current = _profile;
    if (current == null) {
      throw StateError('Identity verification is unavailable.');
    }
    return current.identityVerification;
  }

  @override
  Future<String> getCanonicalAccountName() async {
    final UserProfile? current = _profile;
    if (current == null) {
      throw StateError('The account name is unavailable.');
    }
    return current.fullName;
  }

  @override
  Future<IdentityVerification> startIdentityVerification() async {
    verificationCallCount++;
    await _wait();
    if (failVerification) {
      throw StateError('Unable to start identity verification.');
    }
    final UserProfile? current = _profile;
    if (current == null) {
      throw StateError('Identity verification is unavailable.');
    }
    if (current.identityVerification.status ==
            IdentityVerificationStatus.submitted ||
        current.identityVerification.status ==
            IdentityVerificationStatus.pending ||
        current.identityVerification.status ==
            IdentityVerificationStatus.verified) {
      return current.identityVerification;
    }
    final IdentityVerification updated = IdentityVerification(
      status: IdentityVerificationStatus.capturing,
      maskedIdentityNumber: current.maskedIdentityNumber,
    );
    _profile = current.copyWith(identityVerification: updated);
    return updated;
  }

  @override
  Future<IdentityVerificationProgress?> getVerificationProgress() async {
    await _wait();
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
    uploadSessionCallCount++;
    await _wait();
    if (failVerification) {
      throw StateError('Unable to create a secure upload session.');
    }
    final DateTime now = DateTime.now();
    return IdentityUploadSession(
      sessionId: 'identity-upload-${_uploadSequence++}',
      expiresAt: now.add(const Duration(minutes: 10)),
    );
  }

  @override
  Future<IdentityCaptureEvidence> registerCapture(
    IdentityUploadSession session,
    IdentityCaptureInput capture,
  ) async {
    captureRegistrationCallCount++;
    await _wait();
    if (failVerification || session.expiresAt.isBefore(DateTime.now())) {
      throw StateError('The secure upload session is unavailable.');
    }
    if (!capture.quality.passesFrontendChecks) {
      throw StateError('The capture did not pass quality checks.');
    }
    if (!capture.temporaryPath.startsWith('synthetic:') &&
        !await File(capture.temporaryPath).exists()) {
      throw StateError('The temporary capture is unavailable.');
    }
    final bool duplicate = _temporaryCaptures.values.any(
      (IdentityCaptureInput item) =>
          item.side != capture.side && item.fingerprint == capture.fingerprint,
    );
    if (duplicate) {
      throw StateError('Each capture must be unique.');
    }
    final String captureId = 'secure-capture-${_captureSequence++}';
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
    final UserProfile? current = _profile;
    if (current == null) {
      throw StateError('Identity verification is unavailable.');
    }
    if (current.identityVerification.status ==
            IdentityVerificationStatus.verified ||
        current.identityVerification.status ==
            IdentityVerificationStatus.submitted ||
        current.identityVerification.status ==
            IdentityVerificationStatus.pending) {
      return current.identityVerification;
    }
    verificationSubmissionCallCount++;
    await _wait();
    if (failVerification) {
      throw StateError('Unable to submit identity verification.');
    }
    if (!submission.consentConfirmed ||
        !_captureMatches(submission.front) ||
        !_captureMatches(submission.back) ||
        !_captureMatches(submission.selfie)) {
      throw StateError('Verification evidence is incomplete.');
    }
    if (submission.front.fingerprint == submission.back.fingerprint) {
      throw StateError('Front and back captures must be different.');
    }
    if (AccountNamePolicy.meaningfullyDiffers(
          current.fullName,
          submission.legalDetails.fullLegalName,
        ) &&
        !submission.accountNameChangeConfirmed) {
      throw StateError('The account name update was not confirmed.');
    }
    final DateTime now = DateTime.now();
    final IdentityVerificationStatus outcome = switch (verificationOutcome) {
      IdentityVerificationStatus.notStarted ||
      IdentityVerificationStatus.capturing ||
      IdentityVerificationStatus.submitted =>
        IdentityVerificationStatus.pending,
      _ => verificationOutcome,
    };
    final String digits = submission.legalDetails.cnicNumber.replaceAll(
      RegExp('[^0-9]'),
      '',
    );
    final String maskedCnic =
        '*****-*******-${digits.isEmpty ? '*' : digits.substring(digits.length - 1)}';
    final IdentityVerification result = IdentityVerification(
      status: outcome,
      maskedIdentityNumber: maskedCnic,
      submittedAt: now,
      verifiedAt: outcome == IdentityVerificationStatus.verified ? now : null,
      rejectionReason: switch (outcome) {
        IdentityVerificationStatus.rejected =>
          'The submitted information could not be verified. Check image clarity or document validity.',
        IdentityVerificationStatus.technicalFailure =>
          'Verification is temporarily unavailable.',
        _ => null,
      },
      expiresAt: outcome == IdentityVerificationStatus.verified
          ? now.add(const Duration(days: 1095))
          : null,
      additionalCaptureSide:
          outcome == IdentityVerificationStatus.additionalCaptureRequired
          ? IdentityCaptureSide.front
          : null,
      providerReference: 'mock-verification-${now.microsecondsSinceEpoch}',
      proofRecordHash: outcome == IdentityVerificationStatus.verified
          ? 'proof-${now.millisecondsSinceEpoch}'
          : null,
    );
    _profile = outcome == IdentityVerificationStatus.verified
        ? current.copyWith(
            fullName: AccountNamePolicy.normalizeForDisplay(
              submission.legalDetails.fullLegalName,
            ),
            dateOfBirth: submission.legalDetails.dateOfBirth,
            gender: submission.legalDetails.gender,
            maskedIdentityNumber: maskedCnic,
            identityVerification: result,
          )
        : current.copyWith(identityVerification: result);
    if (outcome == IdentityVerificationStatus.verified) {
      _verificationProgress = null;
      await _deleteAllTemporaryCaptures();
    } else if (outcome == IdentityVerificationStatus.pending ||
        outcome == IdentityVerificationStatus.submitted ||
        outcome == IdentityVerificationStatus.rejected) {
      _verificationProgress = IdentityVerificationProgress(
        consentConfirmed: submission.consentConfirmed,
        nameChangeConfirmed:
            _verificationProgress?.nameChangeConfirmed ?? false,
        legalDetails: submission.legalDetails,
      );
      await _deleteAllTemporaryCaptures();
    }
    return result;
  }

  @override
  Future<void> cancelIdentityVerification() async {
    _verificationProgress = null;
    await _deleteAllTemporaryCaptures();
    final UserProfile? current = _profile;
    if (current?.identityVerification.status ==
        IdentityVerificationStatus.capturing) {
      _profile = current!.copyWith(
        identityVerification: IdentityVerification(
          status: IdentityVerificationStatus.notStarted,
          maskedIdentityNumber: current.maskedIdentityNumber,
        ),
      );
    }
  }

  bool _captureMatches(IdentityCaptureEvidence evidence) {
    final IdentityCaptureInput? stored = _temporaryCaptures[evidence.captureId];
    return stored?.side == evidence.side &&
        stored?.fingerprint == evidence.fingerprint;
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

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }

  void _throwIfLoadingFails() {
    if (failLoading) {
      throw StateError('Unable to load profile.');
    }
  }
}
