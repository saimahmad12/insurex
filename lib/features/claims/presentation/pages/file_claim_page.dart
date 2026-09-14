import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../application/controllers/file_claim_controller.dart';
import '../../application/validators/claim_form_validator.dart';
import '../../domain/entities/claim_image.dart';
import '../../domain/entities/claim_submission_result.dart';
import '../../domain/entities/incident_details.dart';
import '../widgets/ai_verification_step.dart';
import '../widgets/claim_navigation_actions.dart';
import '../widgets/claim_review_step.dart';
import '../widgets/claim_step_indicator.dart';
import '../widgets/image_upload_step.dart';
import '../widgets/incident_details_step.dart';
import '../widgets/policy_selection_step.dart';

class FileClaimPage extends StatefulWidget {
  const FileClaimPage({
    required this.controller,
    required this.onBack,
    required this.onSubmitted,
    super.key,
  });

  final FileClaimController controller;
  final VoidCallback onBack;
  final ValueChanged<ClaimSubmissionResult> onSubmitted;

  @override
  State<FileClaimPage> createState() => _FileClaimPageState();
}

class _FileClaimPageState extends State<FileClaimPage> {
  final GlobalKey<FormState> _incidentFormKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _estimatedLossController =
      TextEditingController();

  bool _showIncidentDateError = false;

  @override
  void initState() {
    super.initState();
    final IncidentDetails details = widget.controller.incidentDetails;
    _locationController.text = details.location;
    _titleController.text = details.title;
    _descriptionController.text = details.description;
    if (details.estimatedLoss != null) {
      _estimatedLossController.text = details.estimatedLoss!.toStringAsFixed(0);
    }
    widget.controller.loadPolicies();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedLossController.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  void _handleBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.controller.currentStep == FileClaimStep.selectPolicy) {
      widget.onBack();
      return;
    }
    widget.controller.previousStep();
  }

  Future<void> _handleContinue() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final FileClaimStep step = widget.controller.currentStep;

    if (step == FileClaimStep.incidentDetails) {
      setState(() {
        _showIncidentDateError = true;
      });
      final bool formValid = _incidentFormKey.currentState?.validate() ?? false;
      final bool dateValid =
          ClaimFormValidator.validateIncidentDate(
            widget.controller.incidentDetails.occurredAt,
          ) ==
          null;
      if (!formValid || !dateValid) {
        widget.controller.nextStep();
        return;
      }
    }

    if (step == FileClaimStep.review) {
      final ClaimSubmissionResult? result = await widget.controller
          .submitClaim();
      if (mounted && result != null) {
        widget.onSubmitted(result);
      }
      return;
    }

    widget.controller.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GlassBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (BuildContext context, Widget? child) {
              final FileClaimStep step = widget.controller.currentStep;

              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Column(
                          children: <Widget>[
                            _ClaimHeader(onBack: _handleBack),
                            const SizedBox(height: 14),
                            ClaimStepIndicator(
                              currentStep: step.index + 1,
                              totalSteps: FileClaimStep.values.length,
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _stepTitle(step),
                                key: const Key('file_claim_step_title'),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      key: PageStorageKey<String>('claim-${step.name}'),
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        18,
                        14,
                        18,
                        18 + MediaQuery.viewInsetsOf(context).bottom * 0.08,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: KeyedSubtree(
                              key: ValueKey<FileClaimStep>(step),
                              child: _buildStep(step),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 11, 18, 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101936).withValues(alpha: 0.92),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (widget.controller.stepErrorMessage !=
                                null) ...<Widget>[
                              Text(
                                widget.controller.stepErrorMessage!,
                                key: const Key('claim_step_error'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFB3BE),
                                  fontSize: 11.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            ClaimNavigationActions(
                              onBack: widget.controller.isSubmitting
                                  ? null
                                  : _handleBack,
                              onContinue: _canContinue(step)
                                  ? _handleContinue
                                  : null,
                              continueLabel: step == FileClaimStep.review
                                  ? 'Submit Claim'
                                  : 'Continue',
                              isLoading: widget.controller.isSubmitting,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _canContinue(FileClaimStep step) {
    if (widget.controller.isSubmitting || widget.controller.isVerifying) {
      return false;
    }
    if (step == FileClaimStep.selectPolicy) {
      return widget.controller.policyLoadState == ClaimPolicyLoadState.success;
    }
    return true;
  }

  Widget _buildStep(FileClaimStep step) {
    switch (step) {
      case FileClaimStep.selectPolicy:
        return PolicySelectionStep(
          loadState: widget.controller.policyLoadState,
          policies: widget.controller.eligiblePolicies,
          selectedPolicy: widget.controller.selectedPolicy,
          errorMessage: widget.controller.policyErrorMessage,
          onSelected: widget.controller.selectPolicy,
          onRetry: widget.controller.loadPolicies,
        );
      case FileClaimStep.incidentDetails:
        return IncidentDetailsStep(
          formKey: _incidentFormKey,
          details: widget.controller.incidentDetails,
          incidentTypes: widget.controller.compatibleIncidentTypes,
          locationController: _locationController,
          titleController: _titleController,
          descriptionController: _descriptionController,
          estimatedLossController: _estimatedLossController,
          showDateError: _showIncidentDateError,
          onChanged: widget.controller.updateIncidentDetails,
        );
      case FileClaimStep.images:
        return ImageUploadStep(
          images: widget.controller.images,
          errorMessage: widget.controller.imageErrorMessage,
          onCamera: () {
            widget.controller.addImages(ClaimImageSourceType.camera);
          },
          onGallery: () {
            widget.controller.addImages(ClaimImageSourceType.gallery);
          },
          onRemove: widget.controller.removeImage,
          onReplace: (String imageId) {
            widget.controller.replaceImage(
              imageId,
              ClaimImageSourceType.gallery,
            );
          },
          onRetry: widget.controller.retryImageUpload,
        );
      case FileClaimStep.verification:
        return AiVerificationStep(
          state: widget.controller.verificationState,
          stage: widget.controller.verificationStage,
          imageCount: widget.controller.images.length,
          result: widget.controller.verificationResult,
          errorMessage: widget.controller.verificationErrorMessage,
          onVerify: widget.controller.verifyImages,
          onRetry: widget.controller.verifyImages,
        );
      case FileClaimStep.review:
        return ClaimReviewStep(
          policy: widget.controller.selectedPolicy!,
          incidentDetails: widget.controller.incidentDetails,
          images: widget.controller.images,
          verificationResult: widget.controller.verificationResult!,
          declarationAccepted: widget.controller.declarationAccepted,
          aiConsentAccepted: widget.controller.aiConsentAccepted,
          errorMessage: widget.controller.submissionErrorMessage,
          onDeclarationChanged: widget.controller.setDeclarationAccepted,
          onAiConsentChanged: widget.controller.setAiConsentAccepted,
          onEditPolicy: () {
            widget.controller.returnToStep(FileClaimStep.selectPolicy);
          },
          onEditIncident: () {
            widget.controller.returnToStep(FileClaimStep.incidentDetails);
          },
          onEditImages: () {
            widget.controller.returnToStep(FileClaimStep.images);
          },
        );
    }
  }

  static String _stepTitle(FileClaimStep step) {
    switch (step) {
      case FileClaimStep.selectPolicy:
        return 'Select Policy';
      case FileClaimStep.incidentDetails:
        return 'Incident Details';
      case FileClaimStep.images:
        return 'Upload Incident Images';
      case FileClaimStep.verification:
        return 'AI Image Verification';
      case FileClaimStep.review:
        return 'Review and Submit';
    }
  }
}

class _ClaimHeader extends StatelessWidget {
  const _ClaimHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Back',
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white.withValues(alpha: 0.08),
            side: BorderSide(color: AppColors.white.withValues(alpha: 0.16)),
          ),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Text(
            'File a Claim',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: <Color>[AppColors.blue, AppColors.blue],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.3),
                blurRadius: 15,
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: AppColors.white,
            size: 22,
          ),
        ),
      ],
    );
  }
}
