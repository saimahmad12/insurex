import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/auth/application/controllers/seller_registration_controller.dart';
import 'package:insurancex/features/auth/application/validators/seller_auth_validator.dart';
import 'package:insurancex/features/auth/data/repositories/mock_seller_registration_repository.dart';
import 'package:insurancex/features/auth/domain/entities/seller_registration.dart';

void main() {
  test(
    'invalid seller form is rejected before repository submission',
    () async {
      final MockSellerRegistrationRepository repository =
          MockSellerRegistrationRepository(delay: Duration.zero);
      final SellerRegistrationController controller = _controller(repository);

      expect(
        await controller.submit(
          registeredCompanyName: '',
          businessEmail: '',
          businessPhoneNumber: '',
          companyRegistrationNumber: '',
          insuranceLicenseNumber: '',
          officeAddress: '',
          authorizedRepresentativeName: '',
          password: '',
          confirmPassword: '',
        ),
        isNull,
      );

      expect(repository.submitCallCount, 0);
      expect(
        controller.errorFor(SellerRegistrationField.registeredCompanyName),
        isNotNull,
      );
      expect(
        controller.errorFor(SellerRegistrationField.supportedCategories),
        isNotNull,
      );
      expect(controller.errorFor(SellerRegistrationField.terms), isNotNull);
      expect(
        controller.errorFor(SellerRegistrationField.declarations),
        isNotNull,
      );
    },
  );

  test('supported categories can be selected and removed', () {
    final SellerRegistrationController controller = _controller(
      MockSellerRegistrationRepository(delay: Duration.zero),
    );

    controller.toggleCategory(InsuranceCategory.health);
    controller.toggleCategory(InsuranceCategory.vehicle);
    expect(controller.selectedCategories, <InsuranceCategory>{
      InsuranceCategory.health,
      InsuranceCategory.vehicle,
    });

    controller.toggleCategory(InsuranceCategory.health);
    expect(controller.selectedCategories, <InsuranceCategory>{
      InsuranceCategory.vehicle,
    });
  });

  test('terms and declarations are required independently', () async {
    final MockSellerRegistrationRepository repository =
        MockSellerRegistrationRepository(delay: Duration.zero);
    final SellerRegistrationController controller = _controller(repository);
    _selectRequiredOptions(controller, acceptTerms: false);

    expect(await _submit(controller), isNull);
    expect(controller.errorFor(SellerRegistrationField.terms), isNotNull);
    expect(controller.errorFor(SellerRegistrationField.declarations), isNull);
    expect(repository.submitCallCount, 0);
  });

  test('successful registration becomes pending approval', () async {
    final MockSellerRegistrationRepository repository =
        MockSellerRegistrationRepository(delay: Duration.zero);
    final SellerRegistrationController controller = _controller(repository);
    _selectRequiredOptions(controller);

    final SellerRegistrationResult? result = await _submit(controller);

    expect(result?.status, SellerRegistrationStatus.pendingApproval);
    expect(controller.status, SellerRegistrationStatus.pendingApproval);
    expect(repository.submitCallCount, 1);
    expect(
      repository.lastRequest?.supportedCategories,
      contains(InsuranceCategory.health),
    );
    expect(repository.lastRequest?.acceptedTerms, isTrue);
    expect(repository.lastRequest?.confirmedDeclarations, isTrue);
  });

  test('duplicate registration submissions are prevented', () async {
    final MockSellerRegistrationRepository repository =
        MockSellerRegistrationRepository(
          delay: const Duration(milliseconds: 20),
        );
    final SellerRegistrationController controller = _controller(repository);
    _selectRequiredOptions(controller);

    final Future<SellerRegistrationResult?> first = _submit(controller);
    final Future<SellerRegistrationResult?> duplicate = _submit(controller);

    expect(await duplicate, isNull);
    expect(await first, isNotNull);
    expect(repository.submitCallCount, 1);
  });

  test(
    'registration rejection remains retryable with an inline error',
    () async {
      final MockSellerRegistrationRepository repository =
          MockSellerRegistrationRepository(
            resultStatus: SellerRegistrationStatus.rejected,
            delay: Duration.zero,
          );
      final SellerRegistrationController controller = _controller(repository);
      _selectRequiredOptions(controller);

      expect(await _submit(controller), isNull);
      expect(controller.status, SellerRegistrationStatus.rejected);
      expect(controller.errorMessage, contains('could not be accepted'));
    },
  );

  test(
    'technical registration failure exposes retryable error state',
    () async {
      final MockSellerRegistrationRepository repository =
          MockSellerRegistrationRepository(
            delay: Duration.zero,
            throwTechnicalFailure: true,
          );
      final SellerRegistrationController controller = _controller(repository);
      _selectRequiredOptions(controller);

      expect(await _submit(controller), isNull);
      expect(controller.status, SellerRegistrationStatus.technicalFailure);
      expect(controller.errorMessage, contains('Please try again'));
    },
  );
}

SellerRegistrationController _controller(
  MockSellerRegistrationRepository repository,
) {
  return SellerRegistrationController(
    repository: repository,
    validator: const SellerAuthValidator(),
  );
}

void _selectRequiredOptions(
  SellerRegistrationController controller, {
  bool acceptTerms = true,
}) {
  controller.selectDesignation(RepresentativeDesignation.authorizedOfficer);
  controller.toggleCategory(InsuranceCategory.health);
  controller.setTermsAccepted(acceptTerms);
  controller.setDeclarationsConfirmed(true);
}

Future<SellerRegistrationResult?> _submit(
  SellerRegistrationController controller,
) {
  return controller.submit(
    registeredCompanyName: 'Synthetic Assurance Limited',
    businessEmail: 'seller@example.test',
    businessPhoneNumber: '+923001234567',
    companyRegistrationNumber: 'SECP-123456',
    insuranceLicenseNumber: 'SECP-INS-7788',
    officeAddress: '12 Blue Area, Islamabad',
    authorizedRepresentativeName: 'Ayesha Khan',
    password: 'SellerPass1',
    confirmPassword: 'SellerPass1',
  );
}
