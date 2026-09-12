import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/app.dart';
import 'package:insurancex/core/navigation/app_routes.dart';
import 'package:insurancex/features/auth/data/repositories/mock_seller_auth_repository.dart';

void main() {
  testWidgets('approved seller routes to Seller Dashboard', (
    WidgetTester tester,
  ) async {
    await _openSellerLogin(tester);
    await _login(tester, 'approved@insurex.test');

    expect(find.text('Approved Assurance Ltd'), findsOneWidget);
    expect(find.text('Approved Seller'), findsOneWidget);
    expect(find.text('Company Summary'), findsOneWidget);
    expect(find.byKey(const Key('seller_bottom_navigation')), findsOneWidget);
    expect(
      find.byKey(const Key('seller_navigation_home_selected')),
      findsOneWidget,
    );
  });

  testWidgets('seller dashboard is the authenticated route root', (
    WidgetTester tester,
  ) async {
    await _openSellerLogin(tester);
    await _login(tester, 'approved@insurex.test');
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );

    expect(navigator.canPop(), isFalse);
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('Company Summary'), findsOneWidget);
    expect(find.text('Company Portal'), findsNothing);
  });

  testWidgets('unavailable seller tabs keep Home and show feedback', (
    WidgetTester tester,
  ) async {
    await _openSellerLogin(tester);
    await _login(tester, 'approved@insurex.test');

    for (final String tab in <String>[
      'products',
      'applications',
      'claims',
      'profile',
    ]) {
      await tester.tap(find.byKey(Key('seller_navigation_$tab')));
      await tester.pump();

      expect(
        find.text('This feature will be available in the next module.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('seller_navigation_home_selected')),
        findsOneWidget,
      );
      expect(find.text('Company Summary'), findsOneWidget);
    }
  });

  testWidgets(
    'pending seller routes to approval page and Back preserves login',
    (WidgetTester tester) async {
      await _openSellerLogin(tester);
      await _login(tester, 'pending@insurex.test');

      expect(find.text('Approval Pending'), findsOneWidget);
      expect(find.text('Company Summary'), findsNothing);
      await tester.tap(find.byKey(const Key('seller_status_back')));
      await tester.pumpAndSettle();

      expect(find.text('Company Portal'), findsOneWidget);
      expect(
        _fieldText(tester, 'seller_login_email_field'),
        'pending@insurex.test',
      );
    },
  );

  testWidgets('rejected seller can retry registration', (
    WidgetTester tester,
  ) async {
    await _openSellerLogin(tester);
    await _login(tester, 'rejected@insurex.test');

    expect(find.text('Registration Not Approved'), findsOneWidget);
    await tester.tap(find.byKey(const Key('seller_retry_registration')));
    await tester.pumpAndSettle();

    expect(find.text('Register Insurance Company'), findsOneWidget);
  });

  testWidgets('suspended seller can contact support', (
    WidgetTester tester,
  ) async {
    await _openSellerLogin(tester);
    await _login(tester, 'suspended@insurex.test');

    expect(find.text('Account Suspended'), findsOneWidget);
    await tester.tap(find.byKey(const Key('seller_status_support')));
    await tester.pump();

    expect(find.textContaining('secure support channel'), findsOneWidget);
  });

  testWidgets('failed seller login remains on login', (
    WidgetTester tester,
  ) async {
    await _openSellerLogin(tester);
    await _login(tester, 'technical@insurex.test');

    expect(find.text('Company Portal'), findsOneWidget);
    expect(find.text('Company Summary'), findsNothing);
    expect(find.textContaining('Please try again'), findsOneWidget);
  });
}

Future<void> _openSellerLogin(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    InsureXApp(
      sellerAuthRepository: MockSellerAuthRepository(delay: Duration.zero),
    ),
  );
  final NavigatorState navigator = tester.state<NavigatorState>(
    find.byType(Navigator).first,
  );
  unawaited(navigator.pushNamed(AppRoutes.sellerLogin));
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester, String email) async {
  await tester.enterText(_editableField('seller_login_email_field'), email);
  await tester.enterText(
    _editableField('seller_login_password_field'),
    MockSellerAuthRepository.demoPassword,
  );
  await tester.tap(find.byKey(const Key('seller_login_button')));
  await tester.pumpAndSettle();
}

Finder _editableField(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(EditableText),
);

String _fieldText(WidgetTester tester, String key) {
  return tester.widget<EditableText>(_editableField(key)).controller.text;
}
