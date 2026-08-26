import '../../../claims/domain/entities/blockchain_claim_record.dart';
import '../../../claims/domain/entities/claim_submission_result.dart';
import '../../../claims/domain/entities/insurance_claim.dart';
import '../../../claims/domain/repositories/claim_status_repository.dart';
import '../../domain/entities/claim_payout.dart';
import '../../domain/entities/payout_method.dart';
import '../../domain/repositories/claim_payout_repository.dart';

class MockClaimPayoutRepository implements ClaimPayoutRepository {
  MockClaimPayoutRepository({
    required ClaimStatusRepository claimsRepository,
    this.delay = const Duration(milliseconds: 350),
    this.failLoading = false,
    this.failVerification = false,
    this.failPayoutRequest = false,
    this.throwOnPayoutRequest = false,
    this.verificationOutcome = PayoutMethodVerificationStatus.verified,
    this.refreshOutcome = ClaimPayoutStatus.paid,
    List<PayoutMethod>? initialMethods,
    List<ClaimPayout>? initialPayouts,
  }) : _claimsRepository = claimsRepository,
       _methods = List<PayoutMethod>.of(initialMethods ?? _defaultMethods),
       _payouts = List<ClaimPayout>.of(initialPayouts ?? _defaultPayouts);

  final ClaimStatusRepository _claimsRepository;
  final Duration delay;
  final bool failLoading;
  final bool failVerification;
  final bool failPayoutRequest;
  final bool throwOnPayoutRequest;
  final PayoutMethodVerificationStatus verificationOutcome;
  final ClaimPayoutStatus refreshOutcome;
  final List<PayoutMethod> _methods;
  final List<ClaimPayout> _payouts;
  final Map<String, ClaimPayout> _idempotentResults = <String, ClaimPayout>{};
  int _methodSequence = 10;
  int _payoutSequence = 10;

  static const PayoutMethod _bankMethod = PayoutMethod(
    id: 'pm-bank-001',
    type: PayoutMethodType.bankTransfer,
    displayName: 'Bank Transfer',
    accountHolderName: 'Ayesha Khan',
    maskedAccount: '**** **** **** 4821',
    verificationStatus: PayoutMethodVerificationStatus.verified,
  );

  static const List<PayoutMethod> _defaultMethods = <PayoutMethod>[
    _bankMethod,
    PayoutMethod(
      id: 'pm-easypaisa-001',
      type: PayoutMethodType.easypaisa,
      displayName: 'Easypaisa',
      accountHolderName: 'Ayesha Khan',
      maskedAccount: '03** *** 4821',
      verificationStatus: PayoutMethodVerificationStatus.verified,
    ),
    PayoutMethod(
      id: 'pm-jazzcash-001',
      type: PayoutMethodType.jazzCash,
      displayName: 'JazzCash',
      accountHolderName: 'Ayesha Khan',
      maskedAccount: '03** *** 7314',
      verificationStatus: PayoutMethodVerificationStatus.verified,
    ),
  ];

  static final List<ClaimPayout> _defaultPayouts = <ClaimPayout>[
    ClaimPayout(
      id: 'payout-processing-001',
      claimId: 'CLM20260821006',
      policyName: 'Vehicle Insurance',
      amount: 105000,
      status: ClaimPayoutStatus.processing,
      method: _bankMethod,
      idempotencyKey: 'seed-processing-001',
      reference: 'PAY-2026-006',
      requestedAt: DateTime(2026, 8, 23, 12, 20),
      processingAt: DateTime(2026, 8, 23, 12, 21),
    ),
    ClaimPayout(
      id: 'payout-paid-001',
      claimId: 'CLM20260820007',
      policyName: 'Vehicle Insurance',
      amount: 105000,
      status: ClaimPayoutStatus.paid,
      method: _bankMethod,
      idempotencyKey: 'seed-paid-001',
      reference: 'PAY-2026-007',
      requestedAt: DateTime(2026, 8, 22, 8, 45),
      processingAt: DateTime(2026, 8, 22, 8, 46),
      paidAt: DateTime(2026, 8, 22, 10, 15),
      blockchainRecord: BlockchainClaimRecord(
        status: BlockchainRecordStatus.secured,
        verificationStatus: 'Verified',
        transactionHash: '0xpayout8f3a21cd98472ad03d9f76b2e1854ac9',
        recordedAt: DateTime(2026, 8, 22, 10, 16),
      ),
    ),
  ];

  @override
  Future<List<PayoutMethod>> getPayoutMethods() async {
    await _wait();
    _throwIfLoadingFails();
    return List<PayoutMethod>.unmodifiable(_methods);
  }

  @override
  Future<PayoutMethod> addPayoutMethod(PayoutMethodRequest request) async {
    await _wait();
    if (request.accountHolderName.trim().isEmpty ||
        request.destination.trim().isEmpty) {
      throw StateError('The payout method details are invalid.');
    }

    final String displayName = switch (request.type) {
      PayoutMethodType.bankTransfer =>
        request.bankName?.trim().isNotEmpty == true
            ? request.bankName!.trim()
            : 'Bank Transfer',
      PayoutMethodType.easypaisa => 'Easypaisa',
      PayoutMethodType.jazzCash => 'JazzCash',
    };
    final String maskedAccount = request.type == PayoutMethodType.bankTransfer
        ? maskBankAccount(request.destination)
        : maskPakistaniMobile(request.destination);
    final PayoutMethod method = PayoutMethod(
      id: 'mock-pm-${_methodSequence++}',
      type: request.type,
      displayName: displayName,
      accountHolderName: request.accountHolderName.trim(),
      maskedAccount: maskedAccount,
      verificationStatus: PayoutMethodVerificationStatus.unverified,
    );
    _methods.add(method);
    return method;
  }

  @override
  Future<PayoutMethod> verifyPayoutMethod(String payoutMethodId) async {
    await _wait();
    final int index = _methods.indexWhere(
      (PayoutMethod method) => method.id == payoutMethodId,
    );
    if (index < 0) {
      throw StateError('The payout method could not be found.');
    }

    final PayoutMethod verified = _methods[index].copyWith(
      verificationStatus: failVerification
          ? PayoutMethodVerificationStatus.failed
          : verificationOutcome,
    );
    _methods[index] = verified;
    return verified;
  }

  @override
  Future<ClaimPayout> requestPayout({
    required String claimId,
    required String payoutMethodId,
    required String idempotencyKey,
  }) async {
    await _wait();
    if (throwOnPayoutRequest) {
      throw StateError('Unable to request the payout.');
    }

    final InsuranceClaim? claim = await _claimsRepository.getClaimById(claimId);
    if (claim == null ||
        !claim.belongsToCurrentUser ||
        claim.status != ClaimStatus.approved) {
      throw StateError('Only an approved claim can receive a payout.');
    }
    final double approvedAmount = claim.approvedAmount ?? 0;
    if (approvedAmount <= 0) {
      throw StateError('The approved payout amount is invalid.');
    }

    final PayoutMethod method = _methods.firstWhere(
      (PayoutMethod item) => item.id == payoutMethodId,
      orElse: () => throw StateError('The payout method is unavailable.'),
    );
    if (!method.isVerified) {
      throw StateError('Verify the payout method before requesting payment.');
    }

    final ClaimPayout? idempotentResult = _idempotentResults[idempotencyKey];
    if (idempotentResult != null) {
      if (idempotentResult.claimId != claimId ||
          idempotentResult.method.id != payoutMethodId) {
        throw StateError('The idempotency key belongs to another payout.');
      }
      return idempotentResult;
    }

    final ClaimPayout? existing = _findByClaimId(claimId);
    if (existing != null &&
        (existing.status == ClaimPayoutStatus.processing ||
            existing.status == ClaimPayoutStatus.paid ||
            existing.status == ClaimPayoutStatus.reversed)) {
      throw StateError('A payout already exists for this claim.');
    }

    final DateTime now = DateTime.now();
    final bool failed = failPayoutRequest;
    final ClaimPayout payout = ClaimPayout(
      id: 'mock-payout-${_payoutSequence++}',
      claimId: claim.id,
      policyName: claim.policyName,
      amount: approvedAmount,
      status: failed ? ClaimPayoutStatus.failed : ClaimPayoutStatus.processing,
      method: method,
      idempotencyKey: idempotencyKey,
      reference:
          'PAY-${now.year}-${_payoutSequence.toString().padLeft(4, '0')}',
      requestedAt: now,
      processingAt: failed ? null : now,
      failureMessage: failed
          ? 'The payment provider could not process this payout.'
          : null,
    );
    _replacePayoutForClaim(payout);
    _idempotentResults[idempotencyKey] = payout;
    return payout;
  }

  @override
  Future<ClaimPayout?> getPayoutByClaimId(String claimId) async {
    await _wait();
    _throwIfLoadingFails();
    final InsuranceClaim? claim = await _claimsRepository.getClaimById(claimId);
    if (claim?.belongsToCurrentUser != true) {
      return null;
    }
    return _findByClaimId(claimId);
  }

  @override
  Future<List<ClaimPayout>> getPayoutHistory() async {
    await _wait();
    _throwIfLoadingFails();
    final List<ClaimPayout> payouts = <ClaimPayout>[];
    for (final ClaimPayout payout in _payouts) {
      final InsuranceClaim? claim = await _claimsRepository.getClaimById(
        payout.claimId,
      );
      if (claim?.belongsToCurrentUser == true) {
        payouts.add(payout);
      }
    }
    payouts.sort(
      (ClaimPayout first, ClaimPayout second) =>
          second.requestedAt.compareTo(first.requestedAt),
    );
    return List<ClaimPayout>.unmodifiable(payouts);
  }

  @override
  Future<ClaimPayout> refreshPayoutStatus(String payoutId) async {
    await _wait();
    _throwIfLoadingFails();
    final int index = _payouts.indexWhere(
      (ClaimPayout payout) => payout.id == payoutId,
    );
    if (index < 0) {
      throw StateError('The payout could not be found.');
    }

    final ClaimPayout current = _payouts[index];
    final InsuranceClaim? claim = await _claimsRepository.getClaimById(
      current.claimId,
    );
    if (claim?.belongsToCurrentUser != true) {
      throw StateError('The payout is unavailable.');
    }
    if (current.status != ClaimPayoutStatus.processing) {
      return current;
    }
    final DateTime now = DateTime.now();
    final ClaimPayout refreshed = switch (refreshOutcome) {
      ClaimPayoutStatus.paid => current.copyWith(
        status: ClaimPayoutStatus.paid,
        paidAt: now,
        clearFailureMessage: true,
        blockchainRecord: BlockchainClaimRecord(
          status: BlockchainRecordStatus.secured,
          verificationStatus: 'Verified',
          transactionHash: '0xmockpayout${current.id.hashCode.abs()}',
          recordedAt: now,
        ),
      ),
      ClaimPayoutStatus.failed => current.copyWith(
        status: ClaimPayoutStatus.failed,
        failureMessage: 'The payment provider could not process this payout.',
      ),
      ClaimPayoutStatus.reversed => current.copyWith(
        status: ClaimPayoutStatus.reversed,
        failureMessage: 'This payout was reversed and requires support.',
      ),
      _ => current,
    };
    _payouts[index] = refreshed;
    _idempotentResults[current.idempotencyKey] = refreshed;
    return refreshed;
  }

  ClaimPayout? _findByClaimId(String claimId) {
    for (final ClaimPayout payout in _payouts.reversed) {
      if (payout.claimId == claimId) {
        return payout;
      }
    }
    return null;
  }

  void _replacePayoutForClaim(ClaimPayout payout) {
    _payouts.removeWhere((ClaimPayout item) => item.claimId == payout.claimId);
    _payouts.add(payout);
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }

  void _throwIfLoadingFails() {
    if (failLoading) {
      throw StateError('Unable to load payout information.');
    }
  }
}
