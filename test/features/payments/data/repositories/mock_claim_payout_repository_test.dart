import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/data/repositories/mock_claim_status_repository.dart';
import 'package:insurancex/features/payments/data/repositories/mock_claim_payout_repository.dart';
import 'package:insurancex/features/payments/domain/entities/claim_payout.dart';
import 'package:insurancex/features/payments/domain/entities/payout_method.dart';

void main() {
  group('MockClaimPayoutRepository', () {
    late MockClaimStatusRepository claimsRepository;

    setUp(() {
      claimsRepository = MockClaimStatusRepository(delay: Duration.zero);
    });

    test('stores only masked payout destinations', () async {
      final MockClaimPayoutRepository repository = MockClaimPayoutRepository(
        claimsRepository: claimsRepository,
        delay: Duration.zero,
        initialMethods: const <PayoutMethod>[],
        initialPayouts: const <ClaimPayout>[],
      );
      const String rawIban = 'PK36SCBL0000001123456702';

      final PayoutMethod method = await repository.addPayoutMethod(
        const PayoutMethodRequest(
          type: PayoutMethodType.bankTransfer,
          accountHolderName: 'Ayesha Khan',
          destination: rawIban,
          bankName: 'Standard Chartered',
        ),
      );
      final List<PayoutMethod> stored = await repository.getPayoutMethods();

      expect(method.maskedAccount, '**** **** **** 6702');
      expect(method.maskedAccount, isNot(contains(rawIban)));
      expect(stored.single.maskedAccount, method.maskedAccount);
    });

    test('is idempotent and prevents a second active payout', () async {
      final MockClaimPayoutRepository repository = MockClaimPayoutRepository(
        claimsRepository: claimsRepository,
        delay: Duration.zero,
        initialPayouts: const <ClaimPayout>[],
      );
      final PayoutMethod method = (await repository.getPayoutMethods()).first;

      final ClaimPayout first = await repository.requestPayout(
        claimId: MockClaimStatusRepository.approvedClaimId,
        payoutMethodId: method.id,
        idempotencyKey: 'stable-key',
      );
      final ClaimPayout duplicate = await repository.requestPayout(
        claimId: MockClaimStatusRepository.approvedClaimId,
        payoutMethodId: method.id,
        idempotencyKey: 'stable-key',
      );

      expect(duplicate.id, first.id);
      expect(await repository.getPayoutHistory(), hasLength(1));
      await expectLater(
        repository.requestPayout(
          claimId: MockClaimStatusRepository.approvedClaimId,
          payoutMethodId: (await repository.getPayoutMethods())[1].id,
          idempotencyKey: 'stable-key',
        ),
        throwsStateError,
      );
      await expectLater(
        repository.requestPayout(
          claimId: MockClaimStatusRepository.approvedClaimId,
          payoutMethodId: method.id,
          idempotencyKey: 'different-key',
        ),
        throwsStateError,
      );
    });

    test(
      'refresh advances processing payment to a paid receipt state',
      () async {
        final MockClaimPayoutRepository repository = MockClaimPayoutRepository(
          claimsRepository: claimsRepository,
          delay: Duration.zero,
          initialPayouts: const <ClaimPayout>[],
        );
        final PayoutMethod method = (await repository.getPayoutMethods()).first;
        final ClaimPayout processing = await repository.requestPayout(
          claimId: MockClaimStatusRepository.approvedClaimId,
          payoutMethodId: method.id,
          idempotencyKey: 'refresh-key',
        );

        final ClaimPayout paid = await repository.refreshPayoutStatus(
          processing.id,
        );

        expect(paid.status, ClaimPayoutStatus.paid);
        expect(paid.paidAt, isNotNull);
        expect(paid.blockchainRecord?.verificationStatus, 'Verified');
      },
    );

    test('sets a verified default method and removes it safely', () async {
      final MockClaimPayoutRepository repository = MockClaimPayoutRepository(
        claimsRepository: claimsRepository,
        delay: Duration.zero,
      );
      final List<PayoutMethod> methods = await repository.getPayoutMethods();

      final List<PayoutMethod> defaulted = await repository
          .setDefaultPayoutMethod(methods[1].id);
      expect(
        defaulted.where((PayoutMethod method) => method.isDefault),
        hasLength(1),
      );
      expect(defaulted[1].isDefault, isTrue);

      final List<PayoutMethod> remaining = await repository.removePayoutMethod(
        methods[1].id,
      );
      expect(remaining, hasLength(2));
      expect(remaining.any((PayoutMethod method) => method.isDefault), isTrue);
    });
  });
}
