import 'package:flutter/foundation.dart';

import '../../domain/entities/fraud_risk_level.dart';
import '../../domain/entities/claim_payment.dart';
import '../../domain/entities/insurance_claim.dart';
import '../../domain/entities/claim_submission_result.dart';
import '../../domain/entities/claim_timeline_event.dart';
import '../../domain/repositories/claim_status_repository.dart';
import '../../../payments/domain/entities/claim_payout.dart';
import '../../../payments/domain/repositories/claim_payout_repository.dart';
import '../services/claim_timeline_builder.dart';

enum ClaimStatusLoadState {
  initial,
  loading,
  success,
  empty,
  notFound,
  failure,
}

enum ClaimStatusAction {
  viewSubmittedInformation,
  viewAnalysisProgress,
  contactSupport,
  uploadEvidence,
  viewDecision,
  receivePayment,
  viewVerificationStatus,
  trackPayment,
  retryPayment,
  viewReason,
  viewReceipt,
}

class ClaimStatusController extends ChangeNotifier {
  ClaimStatusController({
    required ClaimStatusRepository repository,
    ClaimPayoutRepository? payoutRepository,
    InsuranceClaim? initialClaim,
  }) : _repository = repository,
       _payoutRepository = payoutRepository,
       _claim = initialClaim,
       _loadState = initialClaim == null
           ? ClaimStatusLoadState.initial
           : ClaimStatusLoadState.success;

  final ClaimStatusRepository _repository;
  final ClaimPayoutRepository? _payoutRepository;

  ClaimStatusLoadState _loadState;
  InsuranceClaim? _claim;
  ClaimPayout? _payout;
  String? _requestedClaimId;
  String? _errorMessage;
  String? _refreshErrorMessage;
  bool _initialized = false;
  bool _requestInProgress = false;
  bool _isRefreshing = false;
  bool _disposed = false;

  ClaimStatusLoadState get loadState => _loadState;
  InsuranceClaim? get claim => _claim;
  ClaimPayout? get payout => _payout;
  ClaimPayment? get payment {
    final ClaimPayout? currentPayout = _payout;
    if (currentPayout != null) {
      return currentPayout.toClaimPayment();
    }
    final InsuranceClaim? currentClaim = _claim;
    if (currentClaim?.payment != null) {
      return currentClaim!.payment;
    }
    final double? approvedAmount = currentClaim?.approvedAmount;
    if (currentClaim?.status == ClaimStatus.approved &&
        approvedAmount != null &&
        approvedAmount > 0) {
      return ClaimPayment(
        status: ClaimPaymentStatus.notStarted,
        amount: approvedAmount,
      );
    }
    return null;
  }

  String? get errorMessage => _errorMessage;
  String? get refreshErrorMessage => _refreshErrorMessage;
  bool get isRefreshing => _isRefreshing;
  bool get isInitialLoading =>
      _loadState == ClaimStatusLoadState.loading && _claim == null;

  List<ClaimTimelineEvent> get timeline => _claim == null
      ? const <ClaimTimelineEvent>[]
      : ClaimTimelineBuilder.build(_claim!);

  FraudRiskLevel get fraudRiskLevel =>
      fraudRiskLevelForScore(_claim?.aiVerificationResult?.fraudRiskScore);

  bool get requiresManualReview {
    final InsuranceClaim? currentClaim = _claim;
    if (currentClaim == null) {
      return false;
    }
    return currentClaim.aiVerificationResult?.requiresManualReview == true ||
        fraudRiskLevel == FraudRiskLevel.medium ||
        fraudRiskLevel == FraudRiskLevel.high ||
        currentClaim.status == ClaimStatus.underReview ||
        currentClaim.status == ClaimStatus.additionalEvidenceRequired;
  }

  bool get showPaymentCard {
    final InsuranceClaim? currentClaim = _claim;
    if (payment == null) {
      return false;
    }
    return currentClaim!.status == ClaimStatus.approved ||
        currentClaim.status == ClaimStatus.paymentProcessing ||
        currentClaim.status == ClaimStatus.settled;
  }

  ClaimStatusAction? get contextualAction {
    switch (_claim?.status) {
      case ClaimStatus.submitted:
        return ClaimStatusAction.viewSubmittedInformation;
      case ClaimStatus.aiAnalysisPending:
        return ClaimStatusAction.viewAnalysisProgress;
      case ClaimStatus.aiAnalysisCompleted:
      case ClaimStatus.underReview:
        return ClaimStatusAction.contactSupport;
      case ClaimStatus.additionalEvidenceRequired:
        return ClaimStatusAction.uploadEvidence;
      case ClaimStatus.approved:
        if (!isClaimEligibleForPayout(_claim!)) {
          return _actionForExistingPayment(_claim!.payment) ??
              ClaimStatusAction.viewDecision;
        }
        return switch (_payout?.status) {
          ClaimPayoutStatus.verificationPending =>
            ClaimStatusAction.viewVerificationStatus,
          ClaimPayoutStatus.processing => ClaimStatusAction.trackPayment,
          ClaimPayoutStatus.paid => ClaimStatusAction.viewReceipt,
          ClaimPayoutStatus.failed => ClaimStatusAction.retryPayment,
          ClaimPayoutStatus.reversed => ClaimStatusAction.contactSupport,
          ClaimPayoutStatus.notAvailable ||
          ClaimPayoutStatus.actionRequired ||
          ClaimPayoutStatus.ready ||
          null => ClaimStatusAction.receivePayment,
        };
      case ClaimStatus.rejected:
        return ClaimStatusAction.viewReason;
      case ClaimStatus.paymentProcessing:
        return ClaimStatusAction.trackPayment;
      case ClaimStatus.settled:
        return ClaimStatusAction.viewReceipt;
      case null:
        return null;
    }
  }

  Future<void> initialize({String? claimId}) async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _requestedClaimId = claimId ?? _claim?.id;

    if (_claim != null) {
      await _loadPayoutForClaim(_claim!);
      _notify();
      return;
    }
    await _loadInitial();
  }

  Future<void> refresh() async {
    if (_requestInProgress) {
      return;
    }

    _requestInProgress = true;
    _isRefreshing = true;
    _refreshErrorMessage = null;
    _notify();

    try {
      final InsuranceClaim? refreshedClaim = await _loadRequestedClaim(
        _claim?.id ?? _requestedClaimId,
      );
      if (refreshedClaim == null) {
        _refreshErrorMessage = 'The latest claim status is unavailable.';
      } else {
        _claim = refreshedClaim;
        await _loadPayoutForClaim(refreshedClaim);
        _loadState = ClaimStatusLoadState.success;
      }
    } catch (_) {
      _refreshErrorMessage =
          'Unable to refresh this claim. Existing information is still shown.';
    } finally {
      _requestInProgress = false;
      _isRefreshing = false;
      _notify();
    }
  }

  Future<void> retry() {
    if (_claim != null) {
      return refresh();
    }
    return _loadInitial();
  }

  Future<void> _loadInitial() async {
    if (_requestInProgress) {
      return;
    }

    _requestInProgress = true;
    _loadState = ClaimStatusLoadState.loading;
    _errorMessage = null;
    _notify();

    try {
      _claim = await _loadRequestedClaim(_requestedClaimId);
      if (_claim != null) {
        await _loadPayoutForClaim(_claim!);
      }
      _loadState = _claim == null
          ? _requestedClaimId == null
                ? ClaimStatusLoadState.empty
                : ClaimStatusLoadState.notFound
          : ClaimStatusLoadState.success;
    } catch (_) {
      _loadState = ClaimStatusLoadState.failure;
      _errorMessage = 'Unable to load claim status. Please try again.';
    } finally {
      _requestInProgress = false;
      _notify();
    }
  }

  Future<InsuranceClaim?> _loadRequestedClaim(String? claimId) {
    if (claimId == null) {
      return _repository.getMostRecentActiveClaim();
    }
    return _repository.getClaimById(claimId);
  }

  Future<void> _loadPayoutForClaim(InsuranceClaim claim) async {
    final ClaimPayoutRepository? repository = _payoutRepository;
    if (repository == null) {
      return;
    }
    try {
      _payout = await repository.getPayoutByClaimId(claim.id);
    } catch (_) {
      // Claim status remains usable when the payout snapshot is unavailable.
    }
  }

  ClaimStatusAction? _actionForExistingPayment(ClaimPayment? currentPayment) {
    return switch (currentPayment?.status) {
      ClaimPaymentStatus.verificationPending =>
        ClaimStatusAction.viewVerificationStatus,
      ClaimPaymentStatus.processing => ClaimStatusAction.trackPayment,
      ClaimPaymentStatus.paid => ClaimStatusAction.viewReceipt,
      ClaimPaymentStatus.failed => ClaimStatusAction.retryPayment,
      ClaimPaymentStatus.reversed => ClaimStatusAction.contactSupport,
      ClaimPaymentStatus.notStarted || ClaimPaymentStatus.ready || null => null,
    };
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
