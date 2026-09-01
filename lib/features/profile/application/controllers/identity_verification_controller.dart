import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/identity_verification.dart';
import '../../domain/entities/identity_verification_draft.dart';
import '../../domain/repositories/identity_verification_repository.dart';
import '../../domain/services/account_name_policy.dart';
import '../validators/identity_verification_validator.dart';

enum IdentityLoadStatus { initial, loading, success, failure }

enum IdentityCaptureOperationStatus { idle, registering, success, failure }

enum IdentitySubmissionStatus {
  idle,
  creatingUploadSession,
  uploading,
  processing,
  success,
  failure,
}

enum IdentityVerificationFlowStep {
  status,
  introduction,
  legalDetails,
  frontCapture,
  backCapture,
  liveness,
  processing,
  result,
}

enum IdentityProcessingStage {
  idle,
  uploadingFront,
  uploadingBack,
  checkingImageQuality,
  verifyingIdentityDetails,
  checkingLiveness,
  completingVerification,
}

class IdentityVerificationController extends ChangeNotifier {
  IdentityVerificationController({
    required IdentityVerificationRepository repository,
  }) : _repository = repository;

  final IdentityVerificationRepository _repository;
  IdentityLoadStatus _loadStatus = IdentityLoadStatus.initial;
  IdentityCaptureOperationStatus _captureStatus =
      IdentityCaptureOperationStatus.idle;
  IdentitySubmissionStatus _submissionStatus = IdentitySubmissionStatus.idle;
  IdentityVerificationFlowStep _flowStep = IdentityVerificationFlowStep.status;
  IdentityProcessingStage _processingStage = IdentityProcessingStage.idle;
  IdentityVerification? _verification;
  IdentityUploadSession? _uploadSession;
  String _accountName = '';
  IdentityLegalDetails? _legalDetails;
  IdentityCaptureEvidence? _frontCapture;
  IdentityCaptureEvidence? _backCapture;
  IdentityCaptureEvidence? _selfieCapture;
  String _livenessInstruction = 'Look straight at the camera';
  String? _errorMessage;
  String? _captureErrorMessage;
  String? _submissionErrorMessage;
  Map<String, String> _validationErrors = const <String, String>{};
  bool _consentConfirmed = false;
  bool _nameChangeConfirmed = false;
  bool _verifiedNameWasUpdated = false;
  bool _initialized = false;
  bool _loadInProgress = false;
  bool _captureInProgress = false;
  bool _submissionInProgress = false;
  bool _disposed = false;

  IdentityLoadStatus get loadStatus => _loadStatus;
  IdentityCaptureOperationStatus get captureStatus => _captureStatus;
  IdentitySubmissionStatus get submissionStatus => _submissionStatus;
  IdentityVerificationFlowStep get flowStep => _flowStep;
  IdentityProcessingStage get processingStage => _processingStage;
  IdentityVerification? get verification => _verification;
  String get accountName => _accountName;
  IdentityLegalDetails? get legalDetails => _legalDetails;
  String? get pendingVerificationName => _legalDetails?.fullLegalName;
  IdentityCaptureEvidence? get frontCapture => _frontCapture;
  IdentityCaptureEvidence? get backCapture => _backCapture;
  IdentityCaptureEvidence? get selfieCapture => _selfieCapture;
  String get livenessInstruction => _livenessInstruction;
  String? get errorMessage => _errorMessage;
  String? get captureErrorMessage => _captureErrorMessage;
  String? get submissionErrorMessage => _submissionErrorMessage;
  Map<String, String> get validationErrors => _validationErrors;
  bool get consentConfirmed => _consentConfirmed;
  bool get hasMeaningfulNameChange {
    final String? proposedName = pendingVerificationName;
    return proposedName != null &&
        AccountNamePolicy.meaningfullyDiffers(_accountName, proposedName);
  }

  bool get isNameChangeConfirmed => _nameChangeConfirmed;
  bool get verifiedNameWasUpdated => _verifiedNameWasUpdated;
  bool get isLoading =>
      _loadStatus == IdentityLoadStatus.loading && _verification == null;
  bool get isCapturing =>
      _captureStatus == IdentityCaptureOperationStatus.registering;
  bool get isSubmitting =>
      _submissionStatus == IdentitySubmissionStatus.creatingUploadSession ||
      _submissionStatus == IdentitySubmissionStatus.uploading ||
      _submissionStatus == IdentitySubmissionStatus.processing;

  Future<void> initialize({bool startImmediately = false}) async {
    if (_initialized) {
      if (startImmediately) {
        await startOrResumeVerification();
      }
      return;
    }
    _initialized = true;
    await _load();
    if (startImmediately) {
      await startOrResumeVerification();
    }
  }

  Future<void> retry() => _load();

  Future<bool> startOrResumeVerification() async {
    final IdentityVerificationStatus? status = _verification?.status;
    if (status == IdentityVerificationStatus.submitted ||
        status == IdentityVerificationStatus.pending) {
      _flowStep = IdentityVerificationFlowStep.result;
      _notify();
      return false;
    }
    if (status == IdentityVerificationStatus.verified) {
      return false;
    }
    try {
      final IdentityVerificationStatus? previousStatus = status;
      _verification = await _repository.startIdentityVerification();
      final IdentityVerificationProgress? progress = await _repository
          .getVerificationProgress();
      if (progress != null) {
        _applyProgress(progress);
      }
      _flowStep = previousStatus == IdentityVerificationStatus.rejected
          ? IdentityVerificationFlowStep.legalDetails
          : _legalDetails == null
          ? IdentityVerificationFlowStep.introduction
          : _firstIncompleteCaptureStep;
      _errorMessage = null;
      _notify();
      return true;
    } catch (_) {
      _errorMessage =
          'Unable to start verification. No identity documents were uploaded.';
      _notify();
      return false;
    }
  }

  void updateConsent(bool value) {
    if (_consentConfirmed == value) {
      return;
    }
    _consentConfirmed = value;
    _submissionErrorMessage = null;
    unawaited(_saveProgress());
    _notify();
  }

  bool continueFromIntroduction() {
    if (!_consentConfirmed) {
      _submissionErrorMessage =
          'Confirm your consent before continuing with verification.';
      _notify();
      return false;
    }
    _submissionErrorMessage = null;
    _flowStep = IdentityVerificationFlowStep.legalDetails;
    _notify();
    return true;
  }

  bool submitLegalDetails(IdentityLegalDetails details) {
    final IdentityLegalDetails normalizedDetails = IdentityLegalDetails(
      fullLegalName: AccountNamePolicy.normalizeForDisplay(
        details.fullLegalName,
      ),
      cnicNumber: details.cnicNumber,
      dateOfBirth: details.dateOfBirth,
      gender: details.gender,
      cnicExpiryDate: details.cnicExpiryDate,
    );
    final Map<String, String> errors =
        IdentityVerificationValidator.validateLegalDetails(normalizedDetails);
    if (errors.isNotEmpty) {
      _validationErrors = Map<String, String>.unmodifiable(errors);
      _submissionErrorMessage = errors.values.first;
      _notify();
      return false;
    }
    final bool proposedNameIsUnchanged =
        _legalDetails != null &&
        !AccountNamePolicy.meaningfullyDiffers(
          _legalDetails!.fullLegalName,
          normalizedDetails.fullLegalName,
        );
    _legalDetails = normalizedDetails;
    if (!proposedNameIsUnchanged) {
      _nameChangeConfirmed = !hasMeaningfulNameChange;
    } else if (!hasMeaningfulNameChange) {
      _nameChangeConfirmed = true;
    }
    _validationErrors = const <String, String>{};
    _submissionErrorMessage = null;
    _flowStep = _firstIncompleteCaptureStep;
    unawaited(_saveProgress());
    _notify();
    return true;
  }

  void confirmNameChange() {
    if (!hasMeaningfulNameChange || _nameChangeConfirmed) {
      return;
    }
    _nameChangeConfirmed = true;
    unawaited(_saveProgress());
    _notify();
  }

  void reviewLegalDetails() {
    if (_legalDetails == null) {
      return;
    }
    _flowStep = IdentityVerificationFlowStep.legalDetails;
    _submissionErrorMessage = null;
    _notify();
  }

  Future<bool> registerCapture(IdentityCaptureInput input) async {
    if (_captureInProgress) {
      return false;
    }
    if (!input.quality.passesFrontendChecks) {
      _captureStatus = IdentityCaptureOperationStatus.failure;
      _captureErrorMessage = input.quality.issues.first;
      _notify();
      return false;
    }
    if (input.side == IdentityCaptureSide.back &&
        input.fingerprint == _frontCapture?.fingerprint) {
      _captureStatus = IdentityCaptureOperationStatus.failure;
      _captureErrorMessage =
          'Capture the back of the CNIC separately from the front.';
      _notify();
      return false;
    }

    _captureInProgress = true;
    _captureStatus = IdentityCaptureOperationStatus.registering;
    _captureErrorMessage = null;
    _notify();
    try {
      _uploadSession ??= await _createUploadSession();
      final IdentityCaptureEvidence evidence = await _repository
          .registerCapture(_uploadSession!, input);
      switch (input.side) {
        case IdentityCaptureSide.front:
          _frontCapture = evidence;
        case IdentityCaptureSide.back:
          _backCapture = evidence;
        case IdentityCaptureSide.selfie:
          _selfieCapture = evidence;
      }
      _captureStatus = IdentityCaptureOperationStatus.success;
      await _saveProgress();
      return true;
    } catch (_) {
      _captureStatus = IdentityCaptureOperationStatus.failure;
      _captureErrorMessage =
          'Unable to secure this capture. Retake it and try again.';
      return false;
    } finally {
      _captureInProgress = false;
      _notify();
    }
  }

  bool continueAfterCapture(IdentityCaptureSide side) {
    final bool hasEvidence = switch (side) {
      IdentityCaptureSide.front => _frontCapture != null,
      IdentityCaptureSide.back => _backCapture != null,
      IdentityCaptureSide.selfie => _selfieCapture != null,
    };
    if (!hasEvidence) {
      _captureErrorMessage = 'Complete this live capture before continuing.';
      _notify();
      return false;
    }
    _captureErrorMessage = null;
    switch (side) {
      case IdentityCaptureSide.front:
        _flowStep = IdentityVerificationFlowStep.backCapture;
      case IdentityCaptureSide.back:
        _selectLivenessInstruction();
        _flowStep = IdentityVerificationFlowStep.liveness;
      case IdentityCaptureSide.selfie:
        _flowStep = IdentityVerificationFlowStep.processing;
    }
    _notify();
    return true;
  }

  Future<void> retakeCapture(IdentityCaptureSide side) async {
    final IdentityCaptureEvidence? evidence = switch (side) {
      IdentityCaptureSide.front => _frontCapture,
      IdentityCaptureSide.back => _backCapture,
      IdentityCaptureSide.selfie => _selfieCapture,
    };
    if (evidence != null) {
      await _repository.discardCapture(evidence.captureId);
    }
    switch (side) {
      case IdentityCaptureSide.front:
        _frontCapture = null;
      case IdentityCaptureSide.back:
        _backCapture = null;
      case IdentityCaptureSide.selfie:
        _selfieCapture = null;
    }
    _captureStatus = IdentityCaptureOperationStatus.idle;
    _captureErrorMessage = null;
    await _saveProgress();
    _notify();
  }

  Future<IdentityVerification?> submitVerification() async {
    if (_submissionInProgress) {
      return null;
    }
    final IdentityVerificationStatus? currentStatus = _verification?.status;
    if (currentStatus == IdentityVerificationStatus.verified ||
        currentStatus == IdentityVerificationStatus.submitted ||
        currentStatus == IdentityVerificationStatus.pending) {
      return _verification;
    }
    final IdentityLegalDetails? legalDetails = _legalDetails;
    final IdentityCaptureEvidence? front = _frontCapture;
    final IdentityCaptureEvidence? back = _backCapture;
    final IdentityCaptureEvidence? selfie = _selfieCapture;
    if (!_consentConfirmed ||
        legalDetails == null ||
        front == null ||
        back == null ||
        selfie == null) {
      _submissionStatus = IdentitySubmissionStatus.failure;
      _submissionErrorMessage =
          'Complete every verification step before submitting.';
      _notify();
      return null;
    }
    if (hasMeaningfulNameChange && !_nameChangeConfirmed) {
      _submissionStatus = IdentitySubmissionStatus.failure;
      _submissionErrorMessage =
          'Confirm the account name update before submitting.';
      _notify();
      return null;
    }

    final bool accountNameChanged = hasMeaningfulNameChange;
    _submissionInProgress = true;
    _flowStep = IdentityVerificationFlowStep.processing;
    _submissionStatus = IdentitySubmissionStatus.uploading;
    _submissionErrorMessage = null;
    _notify();
    try {
      final IdentityUploadSession session = _uploadSession ??=
          await _createUploadSession();
      for (final IdentityProcessingStage stage in <IdentityProcessingStage>[
        IdentityProcessingStage.uploadingFront,
        IdentityProcessingStage.uploadingBack,
        IdentityProcessingStage.checkingImageQuality,
        IdentityProcessingStage.verifyingIdentityDetails,
        IdentityProcessingStage.checkingLiveness,
        IdentityProcessingStage.completingVerification,
      ]) {
        _processingStage = stage;
        _submissionStatus = stage.index <= 2
            ? IdentitySubmissionStatus.uploading
            : IdentitySubmissionStatus.processing;
        _notify();
        await Future<void>.delayed(const Duration(milliseconds: 45));
      }
      final IdentityVerification result = await _repository
          .submitIdentityVerification(
            IdentityVerificationSubmission(
              uploadSession: session,
              legalDetails: legalDetails,
              front: front,
              back: back,
              selfie: selfie,
              consentConfirmed: _consentConfirmed,
              accountNameChangeConfirmed:
                  _nameChangeConfirmed || !hasMeaningfulNameChange,
            ),
          );
      _verification = result;
      _submissionStatus = IdentitySubmissionStatus.success;
      _flowStep = IdentityVerificationFlowStep.result;
      if (result.status ==
          IdentityVerificationStatus.additionalCaptureRequired) {
        await _prepareAdditionalCapture(result.additionalCaptureSide);
      } else if (result.status == IdentityVerificationStatus.verified) {
        _verifiedNameWasUpdated = accountNameChanged;
        _accountName = AccountNamePolicy.normalizeForDisplay(
          legalDetails.fullLegalName,
        );
        await _repository.clearVerificationProgress();
        _clearSensitiveDraft();
        _uploadSession = null;
      } else if (result.status == IdentityVerificationStatus.pending ||
          result.status == IdentityVerificationStatus.submitted ||
          result.status == IdentityVerificationStatus.rejected) {
        _frontCapture = null;
        _backCapture = null;
        _selfieCapture = null;
        _uploadSession = null;
      }
      return result;
    } catch (_) {
      _submissionStatus = IdentitySubmissionStatus.failure;
      _submissionErrorMessage =
          'Verification could not be completed. Your safe progress is preserved for retry.';
      _verification = _verification?.copyWith(
        status: IdentityVerificationStatus.technicalFailure,
      );
      _flowStep = IdentityVerificationFlowStep.result;
      return null;
    } finally {
      _submissionInProgress = false;
      _processingStage = IdentityProcessingStage.idle;
      _notify();
    }
  }

  Future<void> retrySubmission() async {
    if (_verification?.status == IdentityVerificationStatus.technicalFailure) {
      _flowStep = IdentityVerificationFlowStep.processing;
      await submitVerification();
    }
  }

  Future<void> cancelVerification() async {
    await _repository.cancelIdentityVerification();
    _clearSensitiveDraft();
    _uploadSession = null;
    await _load();
  }

  Future<void> _saveProgress() {
    return _repository.saveVerificationProgress(
      IdentityVerificationProgress(
        consentConfirmed: _consentConfirmed,
        nameChangeConfirmed: _nameChangeConfirmed,
        legalDetails: _legalDetails,
        front: _frontCapture,
        back: _backCapture,
        selfie: _selfieCapture,
      ),
    );
  }

  Future<IdentityUploadSession> _createUploadSession() async {
    _submissionStatus = IdentitySubmissionStatus.creatingUploadSession;
    _notify();
    return _repository.createUploadSession();
  }

  Future<void> _prepareAdditionalCapture(IdentityCaptureSide? side) async {
    final IdentityCaptureSide requiredSide = side ?? IdentityCaptureSide.front;
    await retakeCapture(requiredSide);
    _flowStep = switch (requiredSide) {
      IdentityCaptureSide.front => IdentityVerificationFlowStep.frontCapture,
      IdentityCaptureSide.back => IdentityVerificationFlowStep.backCapture,
      IdentityCaptureSide.selfie => IdentityVerificationFlowStep.liveness,
    };
  }

  IdentityVerificationFlowStep get _firstIncompleteCaptureStep {
    if (_frontCapture == null) {
      return IdentityVerificationFlowStep.frontCapture;
    }
    if (_backCapture == null) {
      return IdentityVerificationFlowStep.backCapture;
    }
    if (_selfieCapture == null) {
      return IdentityVerificationFlowStep.liveness;
    }
    return IdentityVerificationFlowStep.processing;
  }

  void _selectLivenessInstruction() {
    const List<String> instructions = <String>[
      'Look straight at the camera',
      'Blink naturally, then look straight',
      'Turn slightly left, then face forward',
      'Turn slightly right, then face forward',
    ];
    final int index =
        DateTime.now().microsecondsSinceEpoch % instructions.length;
    _livenessInstruction = instructions[index];
  }

  void _clearSensitiveDraft() {
    _legalDetails = null;
    _frontCapture = null;
    _backCapture = null;
    _selfieCapture = null;
    _nameChangeConfirmed = false;
  }

  Future<void> _load() async {
    if (_loadInProgress) {
      return;
    }
    _loadInProgress = true;
    _loadStatus = IdentityLoadStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      final (
        IdentityVerification verification,
        String accountName,
        IdentityVerificationProgress? progress,
      ) = await (
        _repository.getIdentityVerification(),
        _repository.getCanonicalAccountName(),
        _repository.getVerificationProgress(),
      ).wait;
      _verification = verification;
      _accountName = accountName;
      if (progress != null) {
        _applyProgress(progress);
      }
      _loadStatus = IdentityLoadStatus.success;
      _flowStep = IdentityVerificationFlowStep.status;
    } catch (_) {
      _loadStatus = IdentityLoadStatus.failure;
      _errorMessage = 'Unable to load identity verification.';
    } finally {
      _loadInProgress = false;
      _notify();
    }
  }

  void _applyProgress(IdentityVerificationProgress progress) {
    _consentConfirmed = progress.consentConfirmed;
    _nameChangeConfirmed = progress.nameChangeConfirmed;
    _legalDetails = progress.legalDetails;
    _frontCapture = progress.front;
    _backCapture = progress.back;
    _selfieCapture = progress.selfie;
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // The injected repository keeps an in-memory resume draft. It is cleared
    // only after terminal upload or an explicit safe cancellation.
    _clearSensitiveDraft();
    _disposed = true;
    super.dispose();
  }
}
