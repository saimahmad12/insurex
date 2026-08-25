import 'package:flutter/foundation.dart';

import '../../domain/entities/ai_verification_result.dart';
import '../../domain/entities/claim_image.dart';
import '../../domain/entities/claim_policy.dart';
import '../../domain/entities/claim_request.dart';
import '../../domain/entities/claim_submission_result.dart';
import '../../domain/entities/incident_details.dart';
import '../../domain/repositories/claim_image_repository.dart';
import '../../domain/repositories/claim_image_source.dart';
import '../../domain/repositories/claim_verification_repository.dart';
import '../../domain/repositories/file_claim_repository.dart';
import '../validators/claim_form_validator.dart';

enum FileClaimStep {
  selectPolicy,
  incidentDetails,
  images,
  verification,
  review,
}

enum ClaimPolicyLoadState { initial, loading, success, empty, failure }

enum AiVerificationState { idle, uploading, analysing, verified, failed }

enum VerificationProgressStage {
  idle,
  uploading,
  analysing,
  authenticity,
  manipulation,
  risk,
  completed,
}

enum ClaimSubmissionState { idle, submitting, success, failure }

class FileClaimController extends ChangeNotifier {
  FileClaimController({
    required FileClaimRepository fileClaimRepository,
    required ClaimVerificationRepository verificationRepository,
    required ClaimImageSource imageSource,
    required ClaimImageRepository imageRepository,
    this.initialPolicyId,
    DateTime Function()? now,
    this.verificationStageDelay = const Duration(milliseconds: 160),
  }) : _fileClaimRepository = fileClaimRepository,
       _verificationRepository = verificationRepository,
       _imageSource = imageSource,
       _imageRepository = imageRepository,
       _now = now ?? DateTime.now;

  final FileClaimRepository _fileClaimRepository;
  final ClaimVerificationRepository _verificationRepository;
  final ClaimImageSource _imageSource;
  final ClaimImageRepository _imageRepository;
  final DateTime Function() _now;

  final String? initialPolicyId;
  final Duration verificationStageDelay;

  FileClaimStep _currentStep = FileClaimStep.selectPolicy;
  ClaimPolicyLoadState _policyLoadState = ClaimPolicyLoadState.initial;
  AiVerificationState _verificationState = AiVerificationState.idle;
  VerificationProgressStage _verificationStage = VerificationProgressStage.idle;
  ClaimSubmissionState _submissionState = ClaimSubmissionState.idle;

  List<ClaimPolicy> _policies = <ClaimPolicy>[];
  ClaimPolicy? _selectedPolicy;
  IncidentDetails _incidentDetails = const IncidentDetails();
  List<ClaimImage> _images = <ClaimImage>[];
  AiVerificationResult? _verificationResult;
  ClaimSubmissionResult? _submissionResult;

  bool _declarationAccepted = false;
  bool _aiConsentAccepted = false;
  int _imageRevision = 0;
  bool _disposed = false;

  String? _policyErrorMessage;
  String? _stepErrorMessage;
  String? _imageErrorMessage;
  String? _verificationErrorMessage;
  String? _submissionErrorMessage;

  FileClaimStep get currentStep => _currentStep;
  ClaimPolicyLoadState get policyLoadState => _policyLoadState;
  AiVerificationState get verificationState => _verificationState;
  VerificationProgressStage get verificationStage => _verificationStage;
  ClaimSubmissionState get submissionState => _submissionState;
  List<ClaimPolicy> get policies => List<ClaimPolicy>.unmodifiable(_policies);
  List<ClaimPolicy> get eligiblePolicies => List<ClaimPolicy>.unmodifiable(
    _policies.where((ClaimPolicy policy) => policy.isEligibleAt(_now())),
  );
  ClaimPolicy? get selectedPolicy => _selectedPolicy;
  IncidentDetails get incidentDetails => _incidentDetails;
  List<ClaimImage> get images => List<ClaimImage>.unmodifiable(_images);
  AiVerificationResult? get verificationResult => _verificationResult;
  ClaimSubmissionResult? get submissionResult => _submissionResult;
  bool get declarationAccepted => _declarationAccepted;
  bool get aiConsentAccepted => _aiConsentAccepted;
  String? get policyErrorMessage => _policyErrorMessage;
  String? get stepErrorMessage => _stepErrorMessage;
  String? get imageErrorMessage => _imageErrorMessage;
  String? get verificationErrorMessage => _verificationErrorMessage;
  String? get submissionErrorMessage => _submissionErrorMessage;
  bool get isSubmitting => _submissionState == ClaimSubmissionState.submitting;
  bool get isVerifying =>
      _verificationState == AiVerificationState.uploading ||
      _verificationState == AiVerificationState.analysing;

  List<IncidentType> get compatibleIncidentTypes {
    switch (_selectedPolicy?.type) {
      case ClaimPolicyType.vehicle:
        return const <IncidentType>[
          IncidentType.collision,
          IncidentType.theft,
          IncidentType.vehicleDamage,
          IncidentType.other,
        ];
      case ClaimPolicyType.health:
        return const <IncidentType>[
          IncidentType.medicalEmergency,
          IncidentType.hospitalization,
          IncidentType.other,
        ];
      case ClaimPolicyType.travel:
        return const <IncidentType>[
          IncidentType.baggageLoss,
          IncidentType.tripCancellation,
          IncidentType.medicalEmergency,
          IncidentType.other,
        ];
      case null:
        return const <IncidentType>[IncidentType.other];
    }
  }

  Map<String, String> get incidentValidationErrors {
    final Map<String, String> errors =
        ClaimFormValidator.validateIncidentDetails(
          _incidentDetails,
          now: _now(),
        );
    if (_incidentDetails.incidentType != null &&
        !compatibleIncidentTypes.contains(_incidentDetails.incidentType)) {
      errors['incidentType'] =
          'Select an incident type compatible with this policy.';
    }
    return errors;
  }

  Future<void> loadPolicies({bool forceRefresh = false}) async {
    if (_policyLoadState == ClaimPolicyLoadState.loading) {
      return;
    }
    if (!forceRefresh &&
        (_policyLoadState == ClaimPolicyLoadState.success ||
            _policyLoadState == ClaimPolicyLoadState.empty)) {
      return;
    }

    _policyLoadState = ClaimPolicyLoadState.loading;
    _policyErrorMessage = null;
    _notify();

    try {
      _policies = await _fileClaimRepository.loadPolicies();
      final List<ClaimPolicy> eligible = eligiblePolicies;
      _policyLoadState = eligible.isEmpty
          ? ClaimPolicyLoadState.empty
          : ClaimPolicyLoadState.success;

      if (initialPolicyId != null) {
        for (final ClaimPolicy policy in eligible) {
          if (policy.id == initialPolicyId) {
            _selectedPolicy = policy;
            break;
          }
        }
      }
    } catch (_) {
      _policyLoadState = ClaimPolicyLoadState.failure;
      _policyErrorMessage =
          'Unable to load eligible policies. Please try again.';
    }

    _notify();
  }

  Future<void> refreshPolicies() {
    return loadPolicies(forceRefresh: true);
  }

  bool selectPolicy(ClaimPolicy policy) {
    if (!policy.isEligibleAt(_now())) {
      _stepErrorMessage = 'Only active, unexpired policies can be selected.';
      _notify();
      return false;
    }

    if (_selectedPolicy?.id == policy.id) {
      return true;
    }

    _selectedPolicy = policy;
    if (_incidentDetails.incidentType != null &&
        !compatibleIncidentTypes.contains(_incidentDetails.incidentType)) {
      _incidentDetails = IncidentDetails(
        occurredAt: _incidentDetails.occurredAt,
        location: _incidentDetails.location,
        title: _incidentDetails.title,
        description: _incidentDetails.description,
        estimatedLoss: _incidentDetails.estimatedLoss,
      );
    }
    _stepErrorMessage = null;
    _notify();
    return true;
  }

  void updateIncidentDetails(IncidentDetails details) {
    _incidentDetails = details;
    _stepErrorMessage = null;
    _notify();
  }

  bool nextStep() {
    _stepErrorMessage = null;

    switch (_currentStep) {
      case FileClaimStep.selectPolicy:
        if (_selectedPolicy == null) {
          _stepErrorMessage = 'Select an active policy to continue.';
          _notify();
          return false;
        }
      case FileClaimStep.incidentDetails:
        if (incidentValidationErrors.isNotEmpty) {
          _stepErrorMessage = 'Complete all required incident details.';
          _notify();
          return false;
        }
      case FileClaimStep.images:
        if (_images.isEmpty) {
          _stepErrorMessage = 'Add at least one incident image.';
          _notify();
          return false;
        }
        if (_images.any(
          (ClaimImage image) =>
              image.uploadStatus != ClaimImageUploadStatus.uploaded,
        )) {
          _stepErrorMessage = 'Wait for every image to finish uploading.';
          _notify();
          return false;
        }
      case FileClaimStep.verification:
        if (_verificationState != AiVerificationState.verified ||
            _verificationResult == null) {
          _stepErrorMessage = 'Verify the incident images before continuing.';
          _notify();
          return false;
        }
      case FileClaimStep.review:
        return false;
    }

    _currentStep = FileClaimStep.values[_currentStep.index + 1];
    _notify();
    return true;
  }

  void previousStep() {
    if (_currentStep == FileClaimStep.selectPolicy || isSubmitting) {
      return;
    }
    _currentStep = FileClaimStep.values[_currentStep.index - 1];
    _stepErrorMessage = null;
    _notify();
  }

  void returnToStep(FileClaimStep step) {
    if (step.index >= _currentStep.index || isSubmitting) {
      return;
    }
    _currentStep = step;
    _stepErrorMessage = null;
    _notify();
  }

  Future<void> addImages(ClaimImageSourceType source) async {
    _imageErrorMessage = null;
    try {
      final List<ClaimImage> selected = await _imageSource.selectImages(
        source: source,
        allowMultiple: source == ClaimImageSourceType.gallery,
      );
      final List<ClaimImage> accepted = <ClaimImage>[];
      for (final ClaimImage image in selected) {
        final String? error = ClaimFormValidator.validateImage(
          image,
          <ClaimImage>[..._images, ...accepted],
        );
        if (error != null) {
          _imageErrorMessage = error;
          continue;
        }
        accepted.add(image);
      }

      if (accepted.isEmpty) {
        _notify();
        return;
      }

      _images = <ClaimImage>[..._images, ...accepted];
      _invalidateVerification();
      _notify();

      for (final ClaimImage image in accepted) {
        await _uploadImage(image.id);
      }
    } catch (_) {
      _imageErrorMessage = 'Unable to access images. Please try again.';
      _notify();
    }
  }

  Future<void> replaceImage(String imageId, ClaimImageSourceType source) async {
    _imageErrorMessage = null;
    try {
      final List<ClaimImage> selected = await _imageSource.selectImages(
        source: source,
        allowMultiple: false,
      );
      if (selected.isEmpty) {
        return;
      }

      final ClaimImage replacement = selected.first;
      final List<ClaimImage> otherImages = _images
          .where((ClaimImage image) => image.id != imageId)
          .toList();
      final String? error = ClaimFormValidator.validateImage(
        replacement,
        otherImages,
      );
      if (error != null) {
        _imageErrorMessage = error;
        _notify();
        return;
      }

      final int index = _images.indexWhere(
        (ClaimImage image) => image.id == imageId,
      );
      if (index < 0) {
        return;
      }
      _images = List<ClaimImage>.of(_images)..[index] = replacement;
      _invalidateVerification();
      _notify();
      await _uploadImage(replacement.id);
    } catch (_) {
      _imageErrorMessage = 'Unable to replace this image. Please try again.';
      _notify();
    }
  }

  void removeImage(String imageId) {
    final int previousLength = _images.length;
    _images = _images.where((ClaimImage image) => image.id != imageId).toList();
    if (_images.length == previousLength) {
      return;
    }
    _imageErrorMessage = null;
    _invalidateVerification();
    _notify();
  }

  Future<void> retryImageUpload(String imageId) async {
    _imageErrorMessage = null;
    await _uploadImage(imageId);
  }

  Future<void> _uploadImage(String imageId) async {
    int index = _indexOfImage(imageId);
    if (index < 0) {
      return;
    }

    _images[index] = _images[index].copyWith(
      uploadStatus: ClaimImageUploadStatus.uploading,
      uploadProgress: 0,
    );
    _notify();

    try {
      final ClaimImage image = _images[index];
      await for (final double progress in _imageRepository.uploadImage(image)) {
        index = _indexOfImage(imageId);
        if (index < 0 || _disposed) {
          return;
        }
        _images[index] = _images[index].copyWith(
          uploadStatus: progress >= 1
              ? ClaimImageUploadStatus.uploaded
              : ClaimImageUploadStatus.uploading,
          uploadProgress: progress.clamp(0, 1),
        );
        _notify();
      }
    } catch (_) {
      index = _indexOfImage(imageId);
      if (index < 0) {
        return;
      }
      _images[index] = _images[index].copyWith(
        uploadStatus: ClaimImageUploadStatus.failed,
      );
      _imageErrorMessage = 'An image failed to upload. Retry to continue.';
      _notify();
    }
  }

  Future<bool> verifyImages() async {
    if (isVerifying) {
      return false;
    }
    if (_images.isEmpty ||
        _images.any(
          (ClaimImage image) =>
              image.uploadStatus != ClaimImageUploadStatus.uploaded,
        )) {
      _verificationErrorMessage =
          'Upload at least one incident image before verification.';
      _verificationState = AiVerificationState.failed;
      _notify();
      return false;
    }

    final int revision = _imageRevision;
    _verificationErrorMessage = null;
    _verificationResult = null;
    _verificationState = AiVerificationState.uploading;
    _verificationStage = VerificationProgressStage.uploading;
    _notify();

    try {
      await _waitForStage(revision);
      if (revision != _imageRevision) {
        return false;
      }

      _verificationState = AiVerificationState.analysing;
      for (final VerificationProgressStage stage in <VerificationProgressStage>[
        VerificationProgressStage.analysing,
        VerificationProgressStage.authenticity,
        VerificationProgressStage.manipulation,
        VerificationProgressStage.risk,
      ]) {
        _verificationStage = stage;
        _notify();
        await _waitForStage(revision);
        if (revision != _imageRevision) {
          return false;
        }
      }

      final AiVerificationResult result = await _verificationRepository
          .verifyImages(List<ClaimImage>.unmodifiable(_images));
      if (revision != _imageRevision) {
        return false;
      }
      _verificationResult = result;
      _verificationState = AiVerificationState.verified;
      _verificationStage = VerificationProgressStage.completed;
      _notify();
      return true;
    } catch (_) {
      if (revision != _imageRevision) {
        return false;
      }
      _verificationState = AiVerificationState.failed;
      _verificationStage = VerificationProgressStage.idle;
      _verificationErrorMessage =
          'Image could not be verified. Please retry verification.';
      _notify();
      return false;
    }
  }

  Future<void> _waitForStage(int revision) async {
    if (verificationStageDelay > Duration.zero) {
      await Future<void>.delayed(verificationStageDelay);
    }
  }

  void _invalidateVerification() {
    _imageRevision++;
    _verificationResult = null;
    _verificationState = AiVerificationState.idle;
    _verificationStage = VerificationProgressStage.idle;
    _verificationErrorMessage = null;
    _stepErrorMessage = null;
  }

  void setDeclarationAccepted(bool accepted) {
    if (_declarationAccepted == accepted) {
      return;
    }
    _declarationAccepted = accepted;
    _submissionErrorMessage = null;
    _notify();
  }

  void setAiConsentAccepted(bool accepted) {
    if (_aiConsentAccepted == accepted) {
      return;
    }
    _aiConsentAccepted = accepted;
    _submissionErrorMessage = null;
    _notify();
  }

  Future<ClaimSubmissionResult?> submitClaim() async {
    if (isSubmitting) {
      return null;
    }
    if (_selectedPolicy == null || incidentValidationErrors.isNotEmpty) {
      _submissionErrorMessage = 'Review the policy and incident information.';
      _notify();
      return null;
    }
    if (_images.isEmpty ||
        _images.any(
          (ClaimImage image) =>
              image.uploadStatus != ClaimImageUploadStatus.uploaded,
        )) {
      _submissionErrorMessage = 'Every incident image must be uploaded.';
      _notify();
      return null;
    }
    if (_verificationResult == null ||
        _verificationState != AiVerificationState.verified) {
      _submissionErrorMessage = 'AI image verification is required.';
      _notify();
      return null;
    }
    if (!_declarationAccepted || !_aiConsentAccepted) {
      _submissionErrorMessage =
          'Accept the declaration and AI analysis consent to submit.';
      _notify();
      return null;
    }

    _submissionState = ClaimSubmissionState.submitting;
    _submissionErrorMessage = null;
    _notify();

    try {
      final ClaimRequest request = ClaimRequest(
        policy: _selectedPolicy!,
        incidentDetails: _incidentDetails,
        images: List<ClaimImage>.unmodifiable(_images),
        verificationResult: _verificationResult!,
        declarationAccepted: _declarationAccepted,
        aiAnalysisConsentAccepted: _aiConsentAccepted,
      );
      _submissionResult = await _fileClaimRepository.submitClaim(request);
      _submissionState = ClaimSubmissionState.success;
      _notify();
      return _submissionResult;
    } catch (_) {
      _submissionState = ClaimSubmissionState.failure;
      _submissionErrorMessage =
          'Your claim could not be submitted. Please try again.';
      _notify();
      return null;
    }
  }

  int _indexOfImage(String imageId) {
    return _images.indexWhere((ClaimImage image) => image.id == imageId);
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
