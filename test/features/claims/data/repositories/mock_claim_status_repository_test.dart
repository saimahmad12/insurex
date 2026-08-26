import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/data/repositories/mock_claim_status_repository.dart';
import 'package:insurancex/features/claims/domain/entities/claim_filter.dart';
import 'package:insurancex/features/claims/domain/entities/claim_submission_result.dart';
import 'package:insurancex/features/claims/domain/entities/insurance_claim.dart';

void main() {
  group('MockClaimStatusRepository', () {
    test('loads all active and historical claim examples', () async {
      final MockClaimStatusRepository repository = MockClaimStatusRepository(
        delay: Duration.zero,
      );

      final List<InsuranceClaim> claims = await repository.getClaims();

      expect(claims, hasLength(8));
      expect(
        claims.map((InsuranceClaim claim) => claim.status),
        containsAll(<ClaimStatus>[
          ClaimStatus.submitted,
          ClaimStatus.aiAnalysisPending,
          ClaimStatus.underReview,
          ClaimStatus.additionalEvidenceRequired,
          ClaimStatus.approved,
          ClaimStatus.rejected,
          ClaimStatus.paymentProcessing,
          ClaimStatus.settled,
        ]),
      );
    });

    test('ID lookup returns the same claim data used by the list', () async {
      final MockClaimStatusRepository repository = MockClaimStatusRepository(
        delay: Duration.zero,
      );
      final List<InsuranceClaim> claims = await repository.getClaims();
      final InsuranceClaim historical = claims.firstWhere(
        (InsuranceClaim claim) => claim.status == ClaimStatus.settled,
      );

      final InsuranceClaim? byId = await repository.getClaimById(historical.id);

      expect(byId, same(historical));
      expect(byId?.payment?.paidAt, isNotNull);
      expect(byId?.decision?.approvedAmount, isNotNull);
    });

    test('loads the most recently updated active claim only', () async {
      final MockClaimStatusRepository repository = MockClaimStatusRepository(
        delay: Duration.zero,
      );

      final InsuranceClaim? claim = await repository.getMostRecentActiveClaim();

      expect(claim?.id, MockClaimStatusRepository.underReviewClaimId);
      expect(claim?.status.isActiveClaim, isTrue);
      expect(claim?.status, isNot(ClaimStatus.approved));
      expect(claim?.status, isNot(ClaimStatus.rejected));
      expect(claim?.status, isNot(ClaimStatus.settled));
    });

    test('returns null for an unknown non-submitted claim ID', () async {
      final MockClaimStatusRepository repository = MockClaimStatusRepository(
        delay: Duration.zero,
      );

      expect(await repository.getClaimById('missing'), isNull);
    });

    test('keeps a newly tracked submitted claim in the shared list', () async {
      final MockClaimStatusRepository repository = MockClaimStatusRepository(
        delay: Duration.zero,
        claims: <InsuranceClaim>[],
      );

      final InsuranceClaim? submitted = await repository.getClaimById(
        'CLM-2026-NEW01',
      );
      final List<InsuranceClaim> claims = await repository.getClaims();

      expect(submitted?.id, 'CLM-2026-NEW01');
      expect(claims, contains(same(submitted)));
    });
  });
}
