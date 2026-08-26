import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/application/controllers/profile_controller.dart';
import 'package:insurancex/features/profile/data/repositories/mock_auth_session_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/profile_update_request.dart';
import 'package:insurancex/features/profile/domain/entities/user_profile.dart';
import 'package:insurancex/features/profile/domain/repositories/profile_repository.dart';

void main() {
  group('ProfileController', () {
    test('loads once and prevents duplicate initialization', () async {
      final MockProfileRepository repository = MockProfileRepository(
        delay: const Duration(milliseconds: 10),
      );
      final ProfileController controller = ProfileController(
        profileRepository: repository,
        authSessionRepository: MockAuthSessionRepository(delay: Duration.zero),
      );

      final Future<void> first = controller.initialize();
      final Future<void> duplicate = controller.initialize();
      expect(controller.isInitialLoading, isTrue);
      await Future.wait(<Future<void>>[first, duplicate]);

      expect(repository.getProfileCallCount, 1);
      expect(controller.loadStatus, ProfileLoadStatus.success);
      expect(controller.profile?.fullName, 'Saim Ahmad');
    });

    test('represents missing profile', () async {
      final ProfileController controller = ProfileController(
        profileRepository: MockProfileRepository(
          delay: Duration.zero,
          emptyProfile: true,
        ),
        authSessionRepository: MockAuthSessionRepository(delay: Duration.zero),
      );

      await controller.initialize();
      expect(controller.loadStatus, ProfileLoadStatus.empty);
      expect(controller.profile, isNull);
    });

    test('retries failure without recreating the controller', () async {
      final UserProfile profile = (await MockProfileRepository(
        delay: Duration.zero,
      ).getProfile())!;
      int calls = 0;
      final _TestProfileRepository repository = _TestProfileRepository(
        () async {
          calls++;
          if (calls == 1) {
            throw StateError('offline');
          }
          return profile;
        },
      );
      final ProfileController controller = ProfileController(
        profileRepository: repository,
        authSessionRepository: MockAuthSessionRepository(delay: Duration.zero),
      );

      await controller.initialize();
      expect(controller.loadStatus, ProfileLoadStatus.failure);
      await controller.retry();
      expect(controller.loadStatus, ProfileLoadStatus.success);
      expect(calls, 2);
    });

    test(
      'refresh preserves existing profile while request is running',
      () async {
        final UserProfile profile = (await MockProfileRepository(
          delay: Duration.zero,
        ).getProfile())!;
        final Completer<UserProfile?> refreshCompleter =
            Completer<UserProfile?>();
        int calls = 0;
        final _TestProfileRepository repository = _TestProfileRepository(() {
          calls++;
          return calls == 1
              ? Future<UserProfile?>.value(profile)
              : refreshCompleter.future;
        });
        final ProfileController controller = ProfileController(
          profileRepository: repository,
          authSessionRepository: MockAuthSessionRepository(
            delay: Duration.zero,
          ),
        );
        await controller.initialize();

        final Future<void> refresh = controller.refresh();
        final Future<void> duplicate = controller.refresh();
        expect(controller.profile, same(profile));
        expect(controller.isRefreshing, isTrue);
        expect(calls, 2);
        refreshCompleter.complete(profile.copyWith(fullName: 'Updated User'));
        await Future.wait(<Future<void>>[refresh, duplicate]);

        expect(controller.profile?.fullName, 'Updated User');
        expect(controller.isRefreshing, isFalse);
      },
    );

    test('failed refresh preserves existing data', () async {
      final UserProfile profile = (await MockProfileRepository(
        delay: Duration.zero,
      ).getProfile())!;
      int calls = 0;
      final ProfileController controller = ProfileController(
        profileRepository: _TestProfileRepository(() async {
          calls++;
          if (calls == 1) {
            return profile;
          }
          throw StateError('offline');
        }),
        authSessionRepository: MockAuthSessionRepository(delay: Duration.zero),
      );
      await controller.initialize();

      await controller.refresh();
      expect(controller.profile, same(profile));
      expect(controller.refreshStatus, ProfileRefreshStatus.failure);
      expect(controller.refreshErrorMessage, isNotNull);
    });

    test(
      'applies an updated identity verification to the loaded profile',
      () async {
        final ProfileController controller = ProfileController(
          profileRepository: MockProfileRepository(delay: Duration.zero),
          authSessionRepository: MockAuthSessionRepository(
            delay: Duration.zero,
          ),
        );
        await controller.initialize();
        final IdentityVerification pending = IdentityVerification(
          status: IdentityVerificationStatus.pending,
          maskedIdentityNumber: '*****-*******-3',
          submittedAt: DateTime(2026, 8, 26),
        );

        controller.applyIdentityVerification(pending);

        expect(controller.profile?.identityVerification, same(pending));
        expect(
          controller.profile?.identityVerification.status,
          IdentityVerificationStatus.pending,
        );
      },
    );

    test(
      'logout reports success and failure without duplicate requests',
      () async {
        final MockAuthSessionRepository successRepository =
            MockAuthSessionRepository(delay: const Duration(milliseconds: 10));
        final ProfileController success = ProfileController(
          profileRepository: MockProfileRepository(delay: Duration.zero),
          authSessionRepository: successRepository,
        );

        final Future<bool> first = success.logout();
        final Future<bool> duplicate = success.logout();
        expect(success.isLoggingOut, isTrue);
        expect(await first, isTrue);
        expect(await duplicate, isFalse);
        expect(successRepository.logoutCallCount, 1);
        expect(successRepository.sessionActive, isFalse);

        final ProfileController failure = ProfileController(
          profileRepository: MockProfileRepository(delay: Duration.zero),
          authSessionRepository: MockAuthSessionRepository(
            delay: Duration.zero,
            failLogout: true,
          ),
        );
        expect(await failure.logout(), isFalse);
        expect(failure.logoutStatus, LogoutStatus.failure);
        expect(failure.logoutErrorMessage, isNotNull);
      },
    );
  });
}

class _TestProfileRepository implements ProfileRepository {
  _TestProfileRepository(this.handler);

  final Future<UserProfile?> Function() handler;

  @override
  Future<UserProfile?> getProfile() => handler();

  @override
  Future<UserProfile?> refreshProfile() => handler();

  @override
  Future<UserProfile> updateProfile(ProfileUpdateRequest request) {
    throw UnimplementedError();
  }
}
