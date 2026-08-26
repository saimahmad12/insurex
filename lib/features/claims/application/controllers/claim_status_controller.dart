import 'package:flutter/foundation.dart';

import '../../domain/entities/fraud_risk_level.dart';
import '../../domain/entities/insurance_claim.dart';
import '../../domain/entities/claim_submission_result.dart';
import '../../domain/entities/claim_timeline_event.dart';
import '../../domain/repositories/claim_status_repository.dart';
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
  viewPaymentStatus,
  viewReason,
  viewReceipt,
}

class ClaimStatusController extends ChangeNotifier {
  ClaimStatusController({
    required ClaimStatusRepository repository,
    InsuranceClaim? initialClaim,
  }) : _repository = repository,
       _claim = initialClaim,
       _loadState = initialClaim == null
           ? ClaimStatusLoadState.initial
           : ClaimStatusLoadState.success;

  final ClaimStatusRepository _repository;

  ClaimStatusLoadState _loadState;
  InsuranceClaim? _claim;
  String? _requestedClaimId;
  String? _errorMessage;
  String? _refreshErrorMessage;
  bool _initialized = false;
  bool _requestInProgress = false;
  bool _isRefreshing = false;
  bool _disposed = false;

  ClaimStatusLoadState get loadState => _loadState;
  InsuranceClaim? get claim => _claim;
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
    if (currentClaim?.payment == null) {
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
        return ClaimStatusAction.viewDecision;
      case ClaimStatus.rejected:
        return ClaimStatusAction.viewReason;
      case ClaimStatus.paymentProcessing:
        return ClaimStatusAction.viewPaymentStatus;
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
