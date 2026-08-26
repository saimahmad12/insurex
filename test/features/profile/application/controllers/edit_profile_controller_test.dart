import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/application/controllers/edit_profile_controller.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/profile_update_request.dart';
import 'package:insurancex/features/profile/domain/entities/user_address.dart';
import 'package:insurancex/features/profile/domain/entities/user_profile.dart';

void main() {
  group('EditProfileController', () {
    test('updates editable address and preserves protected fields', () async {
      final MockProfileRepository repository = MockProfileRepository(
        delay: Duration.zero,
      );
      final UserProfile original = (await repository.getProfile())!;
      final EditProfileController controller = EditProfileController(
        repository: repository,
        originalProfile: original,
      );

      final UserProfile? updated = await controller.save(
        _request(original, city: 'Lahore'),
      );

      expect(updated?.address.city, 'Lahore');
      expect(updated?.fullName, original.fullName);
      expect(updated?.emailAddress, original.emailAddress);
      expect(updated?.mobileNumber, original.mobileNumber);
      expect(updated?.maskedIdentityNumber, original.maskedIdentityNumber);
      expect(controller.saveStatus, EditProfileSaveStatus.success);
    });

    test(
      'rejects verified legal identity changes before repository call',
      () async {
        final MockProfileRepository repository = MockProfileRepository(
          delay: Duration.zero,
        );
        final UserProfile original = (await repository.getProfile())!;
        final EditProfileController controller = EditProfileController(
          repository: repository,
          originalProfile: original,
        );

        expect(
          await controller.save(_request(original, fullName: 'Changed Name')),
          isNull,
        );
        expect(controller.validationErrors, contains('legalIdentity'));
        expect(repository.updateProfileCallCount, 0);
      },
    );

    test('allows legal identity fields before verification starts', () async {
      final UserProfile base = (await MockProfileRepository(
        delay: Duration.zero,
      ).getProfile())!;
      final UserProfile original = base.copyWith(
        identityVerification: const IdentityVerification(
          status: IdentityVerificationStatus.notStarted,
          maskedIdentityNumber: '*****-*******-*',
        ),
      );
      final MockProfileRepository repository = MockProfileRepository(
        delay: Duration.zero,
        initialProfile: original,
      );
      final EditProfileController controller = EditProfileController(
        repository: repository,
        originalProfile: original,
      );

      final UserProfile? updated = await controller.save(
        _request(original, fullName: 'Ayesha Ali'),
      );

      expect(updated?.fullName, 'Ayesha Ali');
      expect(repository.updateProfileCallCount, 1);
    });

    test('failed update preserves original profile', () async {
      final MockProfileRepository source = MockProfileRepository(
        delay: Duration.zero,
      );
      final UserProfile original = (await source.getProfile())!;
      final MockProfileRepository repository = MockProfileRepository(
        delay: Duration.zero,
        failUpdate: true,
        initialProfile: original,
      );
      final EditProfileController controller = EditProfileController(
        repository: repository,
        originalProfile: original,
      );

      expect(await controller.save(_request(original, city: 'Lahore')), isNull);
      expect(controller.updatedProfile, isNull);
      expect(controller.originalProfile, same(original));
      expect((await repository.getProfile())?.fullName, original.fullName);
    });

    test('prevents duplicate saves while one is running', () async {
      final MockProfileRepository repository = MockProfileRepository(
        delay: const Duration(milliseconds: 10),
      );
      final UserProfile original = (await repository.getProfile())!;
      final EditProfileController controller = EditProfileController(
        repository: repository,
        originalProfile: original,
      );

      final Future<UserProfile?> first = controller.save(_request(original));
      final Future<UserProfile?> duplicate = controller.save(
        _request(original),
      );
      expect(controller.isSaving, isTrue);
      expect(await duplicate, isNull);
      expect(await first, isNotNull);
      expect(repository.updateProfileCallCount, 1);
    });

    test('rejects invalid input before repository update', () async {
      final MockProfileRepository repository = MockProfileRepository(
        delay: Duration.zero,
      );
      final UserProfile original = (await repository.getProfile())!;
      final EditProfileController controller = EditProfileController(
        repository: repository,
        originalProfile: original,
      );

      expect(await controller.save(_request(original, address: 'x')), isNull);
      expect(controller.validationErrors, contains('address'));
      expect(repository.updateProfileCallCount, 0);
    });
  });
}

ProfileUpdateRequest _request(
  UserProfile profile, {
  String? fullName,
  String? address,
  String? city,
}) {
  return ProfileUpdateRequest(
    fullName: fullName,
    address: UserAddress(
      residentialAddress: address ?? 'House 24, Street 8',
      city: city ?? 'Islamabad',
      country: 'Pakistan',
    ),
  );
}
