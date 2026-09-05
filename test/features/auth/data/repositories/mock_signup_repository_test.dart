import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/auth/data/repositories/mock_signup_repository.dart';
import 'package:insurancex/features/auth/domain/entities/account_role.dart';
import 'package:insurancex/features/auth/domain/entities/signup_request.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';

void main() {
  test(
    'successful signup initializes the canonical unverified account name',
    () async {
      final MockProfileRepository profileRepository = MockProfileRepository(
        delay: Duration.zero,
      );
      final MockSignupRepository signupRepository = MockSignupRepository(
        initializeAccountName:
            profileRepository.initializeUnverifiedAccountName,
        delay: Duration.zero,
      );

      final SignupRequest request = const SignupRequest(
        fullName: '  New   Policyholder  ',
        email: 'policyholder@example.test',
        mobileNumber: '+923001234567',
        password: 'synthetic-password',
        role: AccountRole.customer,
      );
      final bool prepared = await signupRepository.prepareSignup(request);

      final profile = await profileRepository.getProfile();
      expect(prepared, isTrue);
      expect(signupRepository.isCompleted, isFalse);
      expect(profile?.fullName, 'New Policyholder');
      expect(
        profile?.identityVerification.status,
        IdentityVerificationStatus.notStarted,
      );
      expect(await signupRepository.completeSignup(request), isTrue);
      expect(signupRepository.isCompleted, isTrue);
    },
  );
}
