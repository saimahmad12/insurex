import 'package:flutter/foundation.dart';

import '../../../claims/domain/entities/insurance_claim.dart';
import '../../../claims/domain/repositories/claim_status_repository.dart';
import '../../domain/entities/claim_payout.dart';
import '../../domain/entities/payout_method.dart';
import '../../domain/repositories/claim_payout_repository.dart';
import '../validators/payout_method_validator.dart';

enum ClaimPayoutInitialStatus { initial, loading, success, ineligible, failure }

enum PayoutMethodOperationStatus {
  idle,
  adding,
  verifying,
  verificationPending,
  verified,
  failure,
}

enum PayoutSubmissionStatus {
  idle,
  submitting,
  processing,
  paid,
  failure,
  reversed,
}

enum PayoutStatusRefreshStatus { idle, refreshing, failure }

enum ClaimPayoutFlowStep { method, review, status, receipt }

class ClaimPayoutController extends ChangeNotifier {
  ClaimPayoutController({
    required String claimId,
    required ClaimStatusRepository claimsRepository,
    required ClaimPayoutRepository payoutRepository,
  }) : _claimId = claimId,
       _claimsRepository = claimsRepository,
       _payoutRepository = payoutRepository;

  final String _claimId;
  final ClaimStatusRepository _claimsRepository;
  final ClaimPayoutRepository _payoutRepository;

  ClaimPayoutInitialStatus _initialStatus = ClaimPayoutInitialStatus.initial;
  PayoutMethodOperationStatus _methodStatus = PayoutMethodOperationStatus.idle;
  PayoutSubmissionStatus _submissionStatus = PayoutSubmissionStatus.idle;
  PayoutStatusRefreshStatus _refreshStatus = PayoutStatusRefreshStatus.idle;
  ClaimPayoutFlowStep _flowStep = ClaimPayoutFlowStep.method;
  InsuranceClaim? _claim;
  ClaimPayout? _payout;
  List<PayoutMethod> _methods = const <PayoutMethod>[];
  PayoutMethod? _selectedMethod;
  PayoutMethodType? _selectedMethodType;
  String? _initialErrorMessage;
  String? _methodErrorMessage;
  String? _submissionErrorMessage;
  String? _refreshErrorMessage;
  String? _idempotencyKey;
  bool _consentConfirmed = false;
  bool _initialized = false;
  bool _initialRequestInProgress = false;
  bool _methodRequestInProgress = false;
  bool _submissionInProgress = false;
  bool _refreshInProgress = false;
  bool _disposed = false;

  ClaimPayoutInitialStatus get initialStatus => _initialStatus;
  PayoutMethodOperationStatus get methodStatus => _methodStatus;
  PayoutSubmissionStatus get submissionStatus => _submissionStatus;
  PayoutStatusRefreshStatus get refreshStatus => _refreshStatus;
  ClaimPayoutFlowStep get flowStep => _flowStep;
  InsuranceClaim? get claim => _claim;
  ClaimPayout? get payout => _payout;
  List<PayoutMethod> get methods => _methods;
  PayoutMethod? get selectedMethod => _selectedMethod;
  PayoutMethodType? get selectedMethodType => _selectedMethodType;
  String? get initialErrorMessage => _initialErrorMessage;
  String? get methodErrorMessage => _methodErrorMessage;
  String? get submissionErrorMessage => _submissionErrorMessage;
  String? get refreshErrorMessage => _refreshErrorMessage;
  String? get idempotencyKey => _idempotencyKey;
  bool get consentConfirmed => _consentConfirmed;
  bool get isInitialLoading =>
      _initialStatus == ClaimPayoutInitialStatus.loading;
  bool get isMethodOperationRunning =>
      _methodStatus == PayoutMethodOperationStatus.adding ||
      _methodStatus == PayoutMethodOperationStatus.verifying;
  bool get isSubmitting =>
      _submissionStatus == PayoutSubmissionStatus.submitting;
  bool get isRefreshingStatus =>
      _refreshStatus == PayoutStatusRefreshStatus.refreshing;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _loadInitial();
  }

  Future<void> retryInitialLoad() => _loadInitial();

  void selectMethodType(PayoutMethodType type) {
    if (_selectedMethodType == type && _selectedMethod == null) {
      return;
    }
    _selectedMethodType = type;
    _selectedMethod = null;
    _methodStatus = PayoutMethodOperationStatus.idle;
    _methodErrorMessage = null;
    _notify();
  }

  void selectSavedMethod(PayoutMethod method) {
    _selectedMethodType = null;
    if (!method.isVerified) {
      _selectedMethod = method;
      _methodStatus = PayoutMethodOperationStatus.failure;
      _methodErrorMessage = 'Verify this payout method before continuing.';
      _notify();
      return;
    }
    _selectedMethod = method;
    _methodStatus = PayoutMethodOperationStatus.verified;
    _methodErrorMessage = null;
    _notify();
  }

  bool continueWithSelectedMethod() {
    if (_selectedMethod?.isVerified != true) {
      _methodErrorMessage = 'Select a verified payout method.';
      _methodStatus = PayoutMethodOperationStatus.failure;
      _notify();
      return false;
    }
    _flowStep = ClaimPayoutFlowStep.review;
    _submissionErrorMessage = null;
    _notify();
    return true;
  }

  Future<bool> addAndVerifyMethod(PayoutMethodRequest request) async {
    if (_methodRequestInProgress) {
      return false;
    }
    final Map<String, String> errors = PayoutMethodValidator.validate(request);
    if (errors.isNotEmpty) {
      _methodStatus = PayoutMethodOperationStatus.failure;
      _methodErrorMessage = errors.values.first;
      _notify();
      return false;
    }

    _methodRequestInProgress = true;
    _methodStatus = PayoutMethodOperationStatus.adding;
    _methodErrorMessage = null;
    _notify();

    try {
      final PayoutMethod added = await _payoutRepository.addPayoutMethod(
        request,
      );
      _methodStatus = PayoutMethodOperationStatus.verifying;
      _notify();
      final PayoutMethod verified = await _payoutRepository.verifyPayoutMethod(
        added.id,
      );
      _methods = List<PayoutMethod>.unmodifiable(<PayoutMethod>[
        ..._methods.where((PayoutMethod method) => method.id != verified.id),
        verified,
      ]);
      _selectedMethod = verified;
      if (!verified.isVerified) {
        _methodStatus =
            verified.verificationStatus ==
                PayoutMethodVerificationStatus.verificationPending
            ? PayoutMethodOperationStatus.verificationPending
            : PayoutMethodOperationStatus.failure;
        _methodErrorMessage =
            verified.verificationStatus ==
                PayoutMethodVerificationStatus.verificationPending
            ? 'Payout method verification is pending.'
            : 'The payout method could not be verified.';
        return false;
      }
      _methodStatus = PayoutMethodOperationStatus.verified;
      _flowStep = ClaimPayoutFlowStep.review;
      return true;
    } catch (_) {
      _methodStatus = PayoutMethodOperationStatus.failure;
      _methodErrorMessage = 'Unable to add this payout method. Try again.';
      return false;
    } finally {
      _methodRequestInProgress = false;
      _notify();
    }
  }

  void editPayoutMethod() {
    _flowStep = ClaimPayoutFlowStep.method;
    _consentConfirmed = false;
    _submissionErrorMessage = null;
    _notify();
  }

  void updateConsent(bool value) {
    if (_consentConfirmed == value) {
      return;
    }
    _consentConfirmed = value;
    _submissionErrorMessage = null;
    _notify();
  }

  Future<void> confirmPayout() async {
    if (_submissionInProgress) {
      return;
    }
    if (!_consentConfirmed) {
      _submissionErrorMessage =
          'Confirm that the payout details are correct and belong to you.';
      _notify();
      return;
    }
    final PayoutMethod? method = _selectedMethod;
    if (method == null || !method.isVerified) {
      _submissionErrorMessage = 'Select a verified payout method.';
      _notify();
      return;
    }

    _submissionInProgress = true;
    _submissionStatus = PayoutSubmissionStatus.submitting;
    _submissionErrorMessage = null;
    _idempotencyKey ??=
        'payout-$_claimId-${DateTime.now().microsecondsSinceEpoch}';
    _notify();

    try {
      _payout = await _payoutRepository.requestPayout(
        claimId: _claimId,
        payoutMethodId: method.id,
        idempotencyKey: _idempotencyKey!,
      );
      _applyPayoutState(_payout!);
      _flowStep = ClaimPayoutFlowStep.status;
    } catch (_) {
      _submissionStatus = PayoutSubmissionStatus.failure;
      _submissionErrorMessage =
          'Unable to request your payout. Your approved claim remains safe.';
    } finally {
      _submissionInProgress = false;
      _notify();
    }
  }

  Future<void> refreshPayoutStatus() async {
    final ClaimPayout? current = _payout;
    if (current == null || _refreshInProgress) {
      return;
    }
    _refreshInProgress = true;
    _refreshStatus = PayoutStatusRefreshStatus.refreshing;
    _refreshErrorMessage = null;
    _notify();

    try {
      _payout = await _payoutRepository.refreshPayoutStatus(current.id);
      _applyPayoutState(_payout!);
      _refreshStatus = PayoutStatusRefreshStatus.idle;
    } catch (_) {
      _refreshStatus = PayoutStatusRefreshStatus.failure;
      _refreshErrorMessage =
          'Unable to refresh payment status. Existing information is shown.';
    } finally {
      _refreshInProgress = false;
      _notify();
    }
  }

  void retryFailedPayout() {
    if (_payout?.status != ClaimPayoutStatus.failed) {
      return;
    }
    _idempotencyKey = null;
    _consentConfirmed = false;
    _submissionStatus = PayoutSubmissionStatus.idle;
    _submissionErrorMessage = null;
    _flowStep = ClaimPayoutFlowStep.review;
    _notify();
  }

  void showReceipt() {
    if (_payout?.status != ClaimPayoutStatus.paid) {
      return;
    }
    _flowStep = ClaimPayoutFlowStep.receipt;
    _notify();
  }

  void showStatus() {
    if (_payout == null) {
      return;
    }
    _flowStep = ClaimPayoutFlowStep.status;
    _notify();
  }

  Future<void> _loadInitial() async {
    if (_initialRequestInProgress) {
      return;
    }
    _initialRequestInProgress = true;
    _initialStatus = ClaimPayoutInitialStatus.loading;
    _initialErrorMessage = null;
    _notify();

    try {
      _claim = await _claimsRepository.getClaimById(_claimId);
      if (_claim == null) {
        _initialStatus = ClaimPayoutInitialStatus.failure;
        _initialErrorMessage = 'The approved claim could not be found.';
        return;
      }
      _payout = await _payoutRepository.getPayoutByClaimId(_claimId);
      if (_payout != null) {
        _selectedMethod = _payout!.method;
        _applyPayoutState(_payout!);
        _flowStep = _payout!.status == ClaimPayoutStatus.paid
            ? ClaimPayoutFlowStep.receipt
            : ClaimPayoutFlowStep.status;
        _initialStatus = ClaimPayoutInitialStatus.success;
        return;
      }
      if (!isClaimEligibleForPayout(_claim!)) {
        _initialStatus = ClaimPayoutInitialStatus.ineligible;
        _initialErrorMessage =
            'This claim is not currently eligible to receive payment.';
        return;
      }
      _methods = List<PayoutMethod>.unmodifiable(
        await _payoutRepository.getPayoutMethods(),
      );
      _initialStatus = ClaimPayoutInitialStatus.success;
      _flowStep = ClaimPayoutFlowStep.method;
    } catch (_) {
      _initialStatus = ClaimPayoutInitialStatus.failure;
      _initialErrorMessage = 'Unable to load payout information. Try again.';
    } finally {
      _initialRequestInProgress = false;
      _notify();
    }
  }

  void _applyPayoutState(ClaimPayout payout) {
    _submissionStatus = switch (payout.status) {
      ClaimPayoutStatus.processing => PayoutSubmissionStatus.processing,
      ClaimPayoutStatus.paid => PayoutSubmissionStatus.paid,
      ClaimPayoutStatus.failed => PayoutSubmissionStatus.failure,
      ClaimPayoutStatus.reversed => PayoutSubmissionStatus.reversed,
      _ => PayoutSubmissionStatus.idle,
    };
    _submissionErrorMessage = payout.failureMessage;
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
