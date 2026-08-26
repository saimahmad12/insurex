import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/data/repositories/mock_claim_status_repository.dart';
import 'package:insurancex/features/payments/application/controllers/claim_payout_controller.dart';
import 'package:insurancex/features/payments/data/repositories/mock_claim_payout_repository.dart';
import 'package:insurancex/features/payments/domain/entities/claim_payout.dart';
import 'package:insurancex/features/payments/domain/entities/payout_method.dart';

void main() {
  group('ClaimPayoutController', () {
    late MockClaimStatusRepository claimsRepository;

    setUp(() {
      claimsRepository = MockClaimStatusRepository(delay: Duration.zero);
    });

    test(
      'runs the approved claim through review, processing, and receipt',
      () async {
        final MockClaimPayoutRepository payoutRepository =
            MockClaimPayoutRepository(
              claimsRepository: claimsRepository,
              delay: Duration.zero,
              initialPayouts: const <ClaimPayout>[],
            );
        final ClaimPayoutController controller = ClaimPayoutController(
          claimId: MockClaimStatusRepository.approvedClaimId,
          claimsRepository: claimsRepository,
          payoutRepository: payoutRepository,
        );

        await controller.initialize();
        expect(controller.initialStatus, ClaimPayoutInitialStatus.success);
        expect(controller.flowStep, ClaimPayoutFlowStep.method);

        controller.selectSavedMethod(controller.methods.first);
        expect(controller.continueWithSelectedMethod(), isTrue);
        expect(controller.flowStep, ClaimPayoutFlowStep.review);

        await controller.confirmPayout();
        expect(controller.payout, isNull);
        expect(controller.submissionErrorMessage, isNotNull);

        controller.updateConsent(true);
        await controller.confirmPayout();
        final String payoutId = controller.payout!.id;
        final String idempotencyKey = controller.idempotencyKey!;
        expect(controller.submissionStatus, PayoutSubmissionStatus.processing);
        expect(controller.flowStep, ClaimPayoutFlowStep.status);

        await controller.confirmPayout();
        expect(controller.payout!.id, payoutId);
        expect(controller.idempotencyKey, idempotencyKey);

        await controller.refreshPayoutStatus();
        expect(controller.submissionStatus, PayoutSubmissionStatus.paid);
        controller.showReceipt();
        expect(controller.flowStep, ClaimPayoutFlowStep.receipt);
      },
    );

    test(
      'method verification uses its own loading state and preserves selection',
      () async {
        final MockClaimPayoutRepository payoutRepository =
            MockClaimPayoutRepository(
              claimsRepository: claimsRepository,
              delay: const Duration(milliseconds: 10),
              initialPayouts: const <ClaimPayout>[],
            );
        final ClaimPayoutController controller = ClaimPayoutController(
          claimId: MockClaimStatusRepository.approvedClaimId,
          claimsRepository: claimsRepository,
          payoutRepository: payoutRepository,
        );
        await controller.initialize();
        controller.selectMethodType(PayoutMethodType.easypaisa);

        final Future<bool> verification = controller.addAndVerifyMethod(
          const PayoutMethodRequest(
            type: PayoutMethodType.easypaisa,
            accountHolderName: 'Ayesha Khan',
            destination: '03001234567',
          ),
        );

        expect(controller.isMethodOperationRunning, isTrue);
        expect(controller.isInitialLoading, isFalse);
        expect(controller.isSubmitting, isFalse);
        expect(await verification, isTrue);
        expect(controller.selectedMethod?.maskedAccount, '03** *** 4567');
        expect(controller.flowStep, ClaimPayoutFlowStep.review);
      },
    );

    test(
      'pending verification does not leave an operation spinner running',
      () async {
        final ClaimPayoutController controller = ClaimPayoutController(
          claimId: MockClaimStatusRepository.approvedClaimId,
          claimsRepository: claimsRepository,
          payoutRepository: MockClaimPayoutRepository(
            claimsRepository: claimsRepository,
            delay: Duration.zero,
            verificationOutcome:
                PayoutMethodVerificationStatus.verificationPending,
            initialPayouts: const <ClaimPayout>[],
          ),
        );
        await controller.initialize();

        final bool verified = await controller.addAndVerifyMethod(
          const PayoutMethodRequest(
            type: PayoutMethodType.jazzCash,
            accountHolderName: 'Ayesha Khan',
            destination: '03001234567',
          ),
        );

        expect(verified, isFalse);
        expect(
          controller.methodStatus,
          PayoutMethodOperationStatus.verificationPending,
        );
        expect(controller.isMethodOperationRunning, isFalse);
        expect(controller.flowStep, ClaimPayoutFlowStep.method);
      },
    );

    test(
      'submission failure keeps the claim and selected method available',
      () async {
        final MockClaimPayoutRepository payoutRepository =
            MockClaimPayoutRepository(
              claimsRepository: claimsRepository,
              delay: Duration.zero,
              throwOnPayoutRequest: true,
              initialPayouts: const <ClaimPayout>[],
            );
        final ClaimPayoutController controller = ClaimPayoutController(
          claimId: MockClaimStatusRepository.approvedClaimId,
          claimsRepository: claimsRepository,
          payoutRepository: payoutRepository,
        );
        await controller.initialize();
        final PayoutMethod selected = controller.methods.first;
        controller.selectSavedMethod(selected);
        controller.continueWithSelectedMethod();
        controller.updateConsent(true);

        await controller.confirmPayout();

        expect(controller.submissionStatus, PayoutSubmissionStatus.failure);
        expect(controller.flowStep, ClaimPayoutFlowStep.review);
        expect(controller.claim?.id, MockClaimStatusRepository.approvedClaimId);
        expect(controller.selectedMethod, selected);
        expect(controller.consentConfirmed, isTrue);
      },
    );
  });
}
