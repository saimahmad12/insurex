import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/app.dart';
import 'package:insurancex/core/navigation/app_routes.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/auth/application/controllers/seller_registration_controller.dart';
import 'package:insurancex/features/auth/application/validators/seller_auth_validator.dart';
import 'package:insurancex/features/auth/data/repositories/mock_seller_registration_repository.dart';
import 'package:insurancex/features/auth/presentation/pages/seller_registration_page.dart';

void main() {
  testWidgets('seller form displays validation, category, and terms errors', (
    WidgetTester tester,
  ) async {
    final MockSellerRegistrationRepository repository =
        MockSellerRegistrationRepository(delay: Duration.zero);
    await _setTestSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: SellerRegistrationPage(
          controller: SellerRegistrationController(
            repository: repository,
            validator: const SellerAuthValidator(),
          ),
          onBack: () {},
          onRoleSelected: (_) {},
          onSubmitted: (_) {},
          onLoginPressed: () {},
          onTermsPressed: () {},
          onPrivacyPressed: () {},
        ),
      ),
    );

    final Finder submit = find.byKey(
      const Key('seller_registration_submit_button'),
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Enter the registered company name.'), findsOneWidget);
    expect(
      find.text('Select at least one insurance category.'),
      findsOneWidget,
    );
    expect(find.text('You must accept the terms to continue.'), findsOneWidget);
    expect(
      find.text('Confirm that the company information is accurate.'),
      findsOneWidget,
    );
    expect(repository.submitCallCount, 0);
  });

  testWidgets('submitted page Back preserves entered seller registration', (
    WidgetTester tester,
  ) async {
    final MockSellerRegistrationRepository repository =
        MockSellerRegistrationRepository(delay: Duration.zero);
    await _setTestSurface(tester);
    await tester.pumpWidget(
      InsureXApp(sellerRegistrationRepository: repository),
    );
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    unawaited(navigator.pushNamed(AppRoutes.sellerSignup));
    await tester.pumpAndSettle();

    expect(find.text('Register Insurance Company'), findsOneWidget);
    expect(find.textContaining('CNIC'), findsNothing);
    await _enterValidRegistration(tester);

    final Finder healthCategory = find.byKey(
      const ValueKey<String>('seller_category_health'),
    );
    await tester.ensureVisible(healthCategory);
    await tester.tap(healthCategory);
    await tester.pump();
    expect(tester.widget<FilterChip>(healthCategory).selected, isTrue);

    final Finder designation = find.byKey(
      const Key('seller_representative_designation_field'),
    );
    await tester.ensureVisible(designation);
    await tester.tap(designation);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Authorized Officer').last);
    await tester.pumpAndSettle();

    final Finder terms = find.descendant(
      of: find.byKey(const Key('seller_terms_agreement')),
      matching: find.byType(Checkbox),
    );
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.tap(find.byKey(const Key('seller_declarations_checkbox')));
    await tester.pump();

    final Finder submit = find.byKey(
      const Key('seller_registration_submit_button'),
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('Seller Registration Submitted'), findsOneWidget);
    expect(
      find.textContaining('pending administrator approval'),
      findsOneWidget,
    );
    expect(repository.submitCallCount, 1);
    expect(repository.lastRequest?.supportedCategories, isNotEmpty);

    await tester.tap(find.byKey(const Key('seller_submitted_back')));
    await tester.pumpAndSettle();

    expect(find.text('Register Insurance Company'), findsOneWidget);
    expect(
      _fieldText(tester, 'seller_company_name_field'),
      'Synthetic Assurance Limited',
    );
    expect(
      _fieldText(tester, 'seller_business_email_field'),
      'seller@example.test',
    );
  });
}

Future<void> _setTestSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 1300);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _enterValidRegistration(WidgetTester tester) async {
  await tester.enterText(
    _editableField('seller_company_name_field'),
    'Synthetic Assurance Limited',
  );
  await tester.enterText(
    _editableField('seller_business_email_field'),
    'seller@example.test',
  );
  await tester.enterText(
    _editableField('seller_business_phone_field'),
    '+923001234567',
  );
  await tester.enterText(
    _editableField('seller_company_registration_field'),
    'SECP-123456',
  );
  await tester.enterText(
    _editableField('seller_license_field'),
    'SECP-INS-7788',
  );
  await tester.enterText(
    _editableField('seller_office_address_field'),
    '12 Blue Area, Islamabad',
  );
  await tester.enterText(
    _editableField('seller_representative_name_field'),
    'Ayesha Khan',
  );
  await tester.enterText(
    _editableField('seller_password_field'),
    'SellerPass1',
  );
  await tester.enterText(
    _editableField('seller_confirm_password_field'),
    'SellerPass1',
  );
}

Finder _editableField(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(EditableText),
);

String _fieldText(WidgetTester tester, String key) {
  return tester.widget<EditableText>(_editableField(key)).controller.text;
}
