import '../../domain/entities/claim_policy.dart';
import '../../domain/entities/claim_request.dart';
import '../../domain/entities/claim_submission_result.dart';
import '../../domain/repositories/file_claim_repository.dart';

class MockFileClaimRepository implements FileClaimRepository {
  MockFileClaimRepository({
    this.loadDelay = const Duration(milliseconds: 500),
    this.submitDelay = const Duration(milliseconds: 700),
    this.failLoading = false,
    this.failSubmission = false,
    List<ClaimPolicy>? policies,
  }) : _policies = policies ?? _defaultPolicies;

  final Duration loadDelay;
  final Duration submitDelay;
  final bool failLoading;
  final bool failSubmission;
  final List<ClaimPolicy> _policies;

  static final List<ClaimPolicy> _defaultPolicies = <ClaimPolicy>[
    ClaimPolicy(
      id: '1',
      name: 'Vehicle Insurance',
      policyNumber: 'INS-2026-001',
      type: ClaimPolicyType.vehicle,
      coverageType: 'Comprehensive Vehicle Coverage',
      expiresAt: DateTime(2027, 8, 14),
      coverageLimit: 2500000,
      status: ClaimPolicyStatus.active,
    ),
    ClaimPolicy(
      id: '2',
      name: 'Health Insurance',
      policyNumber: 'INS-2026-002',
      type: ClaimPolicyType.health,
      coverageType: 'Comprehensive Health Coverage',
      expiresAt: DateTime(2026, 12, 20),
      coverageLimit: 1000000,
      status: ClaimPolicyStatus.active,
    ),
    ClaimPolicy(
      id: '3',
      name: 'Travel Insurance',
      policyNumber: 'INS-2026-003',
      type: ClaimPolicyType.travel,
      coverageType: 'International Travel Coverage',
      expiresAt: DateTime(2027, 3, 10),
      coverageLimit: 750000,
      status: ClaimPolicyStatus.active,
    ),
  ];

  @override
  Future<List<ClaimPolicy>> loadPolicies() async {
    await Future<void>.delayed(loadDelay);
    if (failLoading) {
      throw StateError('Unable to load policies.');
    }
    return List<ClaimPolicy>.unmodifiable(_policies);
  }

  @override
  Future<ClaimSubmissionResult> submitClaim(ClaimRequest request) async {
    await Future<void>.delayed(submitDelay);
    if (failSubmission) {
      throw StateError('Unable to submit claim.');
    }

    final DateTime now = DateTime.now();
    final String sequence = (now.microsecondsSinceEpoch % 100000)
        .toString()
        .padLeft(5, '0');

    return ClaimSubmissionResult(
      claimId: 'CLM-${now.year}-$sequence',
      submittedAt: now,
      status: ClaimStatus.pendingReview,
      aiVerificationCompleted: true,
      blockchainRecordStatus: 'Pending Integration',
    );
  }
}
