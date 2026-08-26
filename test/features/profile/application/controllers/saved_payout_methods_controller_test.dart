import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/data/repositories/mock_claim_status_repository.dart';
import 'package:insurancex/features/payments/data/repositories/mock_claim_payout_repository.dart';
import 'package:insurancex/features/payments/domain/entities/claim_payout.dart';
import 'package:insurancex/features/payments/domain/entities/payout_method.dart';
import 'package:insurancex/features/profile/application/controllers/saved_payout_methods_controller.dart';

void main() {
  group('SavedPayoutMethodsController', () {
    test('loads, defaults, and removes masked methods', () async {
      final MockClaimPayoutRepository repository = _repository();
      final SavedPayoutMethodsController controller =
          SavedPayoutMethodsController(repository: repository);
      await controller.initialize();

      expect(controller.methods, hasLength(3));
      expect(controller.methods.first.isDefault, isTrue);
      expect(
        controller.methods.every(
          (method) => method.maskedAccount.contains('*'),
        ),
        isTrue,
      );

      final PayoutMethod wallet = controller.methods[1];
      expect(await controller.setDefault(wallet), isTrue);
      expect(
        controller.methods
            .singleWhere((method) => method.id == wallet.id)
            .isDefault,
        isTrue,
      );
      expect(await controller.remove(wallet), isTrue);
      expect(
        controller.methods.any((method) => method.id == wallet.id),
        isFalse,
      );
    });

    test(
      'adds and verifies a method without retaining raw destination',
      () async {
        final SavedPayoutMethodsController controller =
            SavedPayoutMethodsController(
              repository: _repository(initialMethods: const <PayoutMethod>[]),
            );
        await controller.initialize();

        expect(
          await controller.addAndVerifyMethod(
            const PayoutMethodRequest(
              type: PayoutMethodType.easypaisa,
              accountHolderName: 'Ayesha Khan',
              destination: '03001234567',
            ),
          ),
          isTrue,
        );
        expect(controller.methods.single.maskedAccount, '03** *** 4567');
        expect(controller.methods.single.isDefault, isTrue);
      },
    );

    test('pending verification stops the operation spinner', () async {
      final SavedPayoutMethodsController controller =
          SavedPayoutMethodsController(
            repository: _repository(
              initialMethods: const <PayoutMethod>[],
              verificationOutcome:
                  PayoutMethodVerificationStatus.verificationPending,
            ),
          );
      await controller.initialize();

      expect(
        await controller.addAndVerifyMethod(
          const PayoutMethodRequest(
            type: PayoutMethodType.jazzCash,
            accountHolderName: 'Ayesha Khan',
            destination: '03001234567',
          ),
        ),
        isFalse,
      );
      expect(
        controller.operationStatus,
        SavedPayoutMethodOperationStatus.verificationPending,
      );
      expect(controller.isAddingOrVerifying, isFalse);
    });
  });
}

MockClaimPayoutRepository _repository({
  List<PayoutMethod>? initialMethods,
  PayoutMethodVerificationStatus verificationOutcome =
      PayoutMethodVerificationStatus.verified,
}) {
  return MockClaimPayoutRepository(
    claimsRepository: MockClaimStatusRepository(delay: Duration.zero),
    delay: Duration.zero,
    initialMethods: initialMethods,
    initialPayouts: const <ClaimPayout>[],
    verificationOutcome: verificationOutcome,
  );
}
