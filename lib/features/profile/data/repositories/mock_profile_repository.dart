import '../../domain/entities/identity_verification.dart';
import '../../domain/entities/profile_field_permissions.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/entities/user_address.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/identity_verification_repository.dart';
import '../../domain/repositories/profile_repository.dart';

class MockProfileRepository
    implements ProfileRepository, IdentityVerificationRepository {
  MockProfileRepository({
    this.delay = const Duration(milliseconds: 350),
    this.failLoading = false,
    this.failUpdate = false,
    this.failVerification = false,
    this.emptyProfile = false,
    this.verificationOutcome = IdentityVerificationStatus.pending,
    UserProfile? initialProfile,
  }) : _profile = emptyProfile ? null : initialProfile ?? _defaultProfile;

  final Duration delay;
  final bool failLoading;
  final bool failUpdate;
  final bool failVerification;
  final bool emptyProfile;
  final IdentityVerificationStatus verificationOutcome;

  UserProfile? _profile;
  int getProfileCallCount = 0;
  int updateProfileCallCount = 0;
  int verificationCallCount = 0;

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

  @override
  Future<UserProfile?> getProfile() async {
    getProfileCallCount++;
    await _wait();
    _throwIfLoadingFails();
    return _profile;
  }

  @override
  Future<UserProfile?> refreshProfile() => getProfile();

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
    await _wait();
    _throwIfLoadingFails();
    final UserProfile? current = _profile;
    if (current == null) {
      throw StateError('Identity verification is unavailable.');
    }
    return current.identityVerification;
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
    final DateTime now = DateTime.now();
    final IdentityVerification updated = IdentityVerification(
      status: verificationOutcome,
      maskedIdentityNumber: current.maskedIdentityNumber,
      submittedAt: now,
      verifiedAt: verificationOutcome == IdentityVerificationStatus.verified
          ? now
          : null,
      rejectionReason:
          verificationOutcome == IdentityVerificationStatus.rejected
          ? 'The submitted information could not be verified.'
          : null,
    );
    _profile = current.copyWith(identityVerification: updated);
    return updated;
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
