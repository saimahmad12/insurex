import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/auth/application/controllers/seller_login_controller.dart';
import 'package:insurancex/features/auth/application/validators/seller_auth_validator.dart';
import 'package:insurancex/features/auth/data/repositories/mock_seller_auth_repository.dart';
import 'package:insurancex/features/auth/domain/entities/seller_authentication.dart';
import 'package:insurancex/features/auth/domain/entities/seller_registration.dart';

void main() {
  for (final ({String email, SellerRegistrationStatus status}) scenario
      in <({String email, SellerRegistrationStatus status})>[
        (
          email: 'approved@insurex.test',
          status: SellerRegistrationStatus.approved,
        ),
        (
          email: 'pending@insurex.test',
          status: SellerRegistrationStatus.pendingApproval,
        ),
        (
          email: 'rejected@insurex.test',
          status: SellerRegistrationStatus.rejected,
        ),
        (
          email: 'suspended@insurex.test',
          status: SellerRegistrationStatus.suspended,
        ),
      ]) {
    test('authoritative ${scenario.status.name} seller is resolved', () async {
      final SellerLoginController controller = _controller(
        MockSellerAuthRepository(delay: Duration.zero),
      );

      final SellerAuthenticationResult? result = await controller.login(
        businessEmail: scenario.email,
        password: MockSellerAuthRepository.demoPassword,
      );

      expect(result?.account?.registrationStatus, scenario.status);
      expect(controller.status, SellerLoginStatus.resolved);
    });
  }

  test('invalid credentials produce an inline retryable error', () async {
    final SellerLoginController controller = _controller(
      MockSellerAuthRepository(delay: Duration.zero),
    );

    expect(
      await controller.login(
        businessEmail: 'approved@insurex.test',
        password: 'wrong-password',
      ),
      isNull,
    );
    expect(controller.status, SellerLoginStatus.failure);
    expect(controller.errorMessage, 'Invalid business email or password.');
  });

  test('technical login failure produces a general retryable error', () async {
    final SellerLoginController controller = _controller(
      MockSellerAuthRepository(delay: Duration.zero),
    );

    expect(
      await controller.login(
        businessEmail: 'technical@insurex.test',
        password: MockSellerAuthRepository.demoPassword,
      ),
      isNull,
    );
    expect(controller.errorMessage, contains('Please try again'));
  });

  test('selected seller portal cannot authorize a customer role', () async {
    final SellerLoginController controller = _controller(
      MockSellerAuthRepository(delay: Duration.zero),
    );

    expect(
      await controller.login(
        businessEmail: 'customer@insurex.test',
        password: MockSellerAuthRepository.demoPassword,
      ),
      isNull,
    );
    expect(controller.errorMessage, contains('not authorized'));
  });

  test('duplicate seller login submissions are prevented', () async {
    final MockSellerAuthRepository repository = MockSellerAuthRepository(
      delay: const Duration(milliseconds: 20),
    );
    final SellerLoginController controller = _controller(repository);

    final Future<SellerAuthenticationResult?> first = controller.login(
      businessEmail: 'approved@insurex.test',
      password: MockSellerAuthRepository.demoPassword,
    );
    final Future<SellerAuthenticationResult?> duplicate = controller.login(
      businessEmail: 'approved@insurex.test',
      password: MockSellerAuthRepository.demoPassword,
    );

    expect(await duplicate, isNull);
    expect(await first, isNotNull);
    expect(repository.loginCallCount, 1);
  });
}

SellerLoginController _controller(MockSellerAuthRepository repository) {
  return SellerLoginController(
    repository: repository,
    validator: const SellerAuthValidator(),
  );
}
