import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/profile/application/controllers/profile_controller.dart';
import 'package:insurancex/features/profile/data/repositories/mock_auth_session_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/profile_update_request.dart';
import 'package:insurancex/features/profile/domain/entities/user_profile.dart';
import 'package:insurancex/features/profile/domain/repositories/profile_repository.dart';
import 'package:insurancex/features/profile/presentation/pages/profile_page.dart';

void main() {
  testWidgets('shows loading then renders profile header and complete menu', (
    WidgetTester tester,
  ) async {
    await _pumpProfile(
      tester,
      profileRepository: MockProfileRepository(
        delay: const Duration(milliseconds: 10),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('profile_initial_loading')), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_header')), findsOneWidget);
    expect(find.text('Saim Ahmad'), findsOneWidget);
    expect(find.text('Policyholder'), findsOneWidget);
    expect(find.text('Identity Verified'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Saved Payout Methods'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms and Conditions'), findsOneWidget);
  });

  testWidgets('shows error and retries successfully', (
    WidgetTester tester,
  ) async {
    final UserProfile profile = (await MockProfileRepository(
      delay: Duration.zero,
    ).getProfile())!;
    int calls = 0;
    await _pumpProfile(
      tester,
      profileRepository: _TestProfileRepository(() async {
        calls++;
        if (calls == 1) {
          throw StateError('offline');
        }
        return profile;
      }),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_load_error')), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_header')), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('pull-to-refresh keeps existing profile visible', (
    WidgetTester tester,
  ) async {
    final UserProfile profile = (await MockProfileRepository(
      delay: Duration.zero,
    ).getProfile())!;
    final Completer<UserProfile?> completer = Completer<UserProfile?>();
    int calls = 0;
    await _pumpProfile(
      tester,
      profileRepository: _TestProfileRepository(() {
        calls++;
        return calls == 1
            ? Future<UserProfile?>.value(profile)
            : completer.future;
      }),
    );
    await tester.pumpAndSettle();

    final RefreshIndicatorState indicator = tester.state<RefreshIndicatorState>(
      find.byKey(const Key('profile_refresh_indicator')),
    );
    final Future<void> refresh = indicator.show();
    await tester.pump();
    expect(find.text(profile.fullName), findsOneWidget);
    expect(find.byKey(const Key('profile_initial_loading')), findsNothing);
    completer.complete(profile.copyWith(fullName: 'Ayesha Ali'));
    await tester.pumpAndSettle();
    await refresh;
    expect(find.text('Ayesha Ali'), findsOneWidget);
  });

  testWidgets('confirms logout before clearing the session', (
    WidgetTester tester,
  ) async {
    final MockAuthSessionRepository session = MockAuthSessionRepository(
      delay: Duration.zero,
    );
    bool loggedOut = false;
    await _pumpProfile(
      tester,
      authSessionRepository: session,
      onLogoutSuccess: () {
        loggedOut = true;
      },
    );
    await tester.pumpAndSettle();

    final Finder logout = find.byKey(const Key('profile_logout'));
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.tap(logout);
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(session.logoutCallCount, 0);

    await tester.tap(logout);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_logout_button')));
    await tester.pumpAndSettle();
    expect(session.logoutCallCount, 1);
    expect(loggedOut, isTrue);
  });

  testWidgets(
    'Personal Information opens once and applies the successful update',
    (WidgetTester tester) async {
      final Completer<UserProfile?> result = Completer<UserProfile?>();
      int openCount = 0;
      await _pumpProfile(
        tester,
        onEditProfile: (UserProfile profile) {
          openCount++;
          return result.future;
        },
      );
      await tester.pumpAndSettle();

      final Finder personalInformation = find.byKey(
        const Key('profile_personal_information'),
      );
      await tester.tap(personalInformation);
      await tester.tap(personalInformation);
      await tester.pump();
      expect(openCount, 1);

      final UserProfile current = (await MockProfileRepository(
        delay: Duration.zero,
      ).getProfile())!;
      result.complete(current.copyWith(fullName: 'Updated Profile Name'));
      await tester.pumpAndSettle();

      expect(find.text('Updated Profile Name'), findsOneWidget);
    },
  );

  testWidgets(
    'Identity Verification opens once and synchronizes the Profile badge',
    (WidgetTester tester) async {
      final Completer<IdentityVerification?> result =
          Completer<IdentityVerification?>();
      int openCount = 0;
      await _pumpProfile(
        tester,
        onIdentityVerification: () {
          openCount++;
          return result.future;
        },
      );
      await tester.pumpAndSettle();

      final Finder identityVerification = find.byKey(
        const Key('profile_identity_verification'),
      );
      await tester.tap(identityVerification);
      await tester.tap(identityVerification);
      await tester.pump();
      expect(openCount, 1);

      result.complete(
        IdentityVerification(
          status: IdentityVerificationStatus.pending,
          maskedIdentityNumber: '*****-*******-3',
          submittedAt: DateTime(2026, 8, 26),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verification Pending'), findsOneWidget);
    },
  );
}

Future<void> _pumpProfile(
  WidgetTester tester, {
  ProfileRepository? profileRepository,
  MockAuthSessionRepository? authSessionRepository,
  VoidCallback? onLogoutSuccess,
  Future<UserProfile?> Function(UserProfile profile)? onEditProfile,
  Future<IdentityVerification?> Function()? onIdentityVerification,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: ProfilePage(
        controller: ProfileController(
          profileRepository:
              profileRepository ?? MockProfileRepository(delay: Duration.zero),
          authSessionRepository:
              authSessionRepository ??
              MockAuthSessionRepository(delay: Duration.zero),
        ),
        onEditProfile: onEditProfile ?? (UserProfile profile) async => null,
        onIdentityVerification: onIdentityVerification ?? () async => null,
        onMyPolicies: () {},
        onMyClaims: () {},
        onPayments: () {},
        onPayoutMethods: () {},
        onSecurity: () {},
        onNotifications: () {},
        onHelpSupport: () {},
        onPrivacyPolicy: () {},
        onTermsAndConditions: () {},
        onLogoutSuccess: onLogoutSuccess ?? () {},
      ),
    ),
  );
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
