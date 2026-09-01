import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/identity_verification_controller.dart';
import '../../application/validators/identity_verification_validator.dart';
import '../../domain/entities/identity_verification.dart';
import '../../domain/entities/identity_verification_draft.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/identity_status_badge.dart';
import '../widgets/live_identity_capture_step.dart';
import '../widgets/profile_page_header.dart';
import '../widgets/profile_state_message.dart';

enum IdentityVerificationEntryPoint { account, signup }

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({
    required this.controller,
    required this.onBack,
    this.captureOverride,
    this.startImmediately = false,
    this.entryPoint = IdentityVerificationEntryPoint.account,
    super.key,
  });

  final IdentityVerificationController controller;
  final ValueChanged<IdentityVerification?> onBack;
  final IdentityCaptureOverride? captureOverride;
  final bool startImmediately;
  final IdentityVerificationEntryPoint entryPoint;

  @override
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      widget.controller.initialize(startImmediately: widget.startImmediately),
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<IdentityVerification?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, IdentityVerification? result) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GlassBackground(
          child: SafeArea(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (BuildContext context, Widget? child) => Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: ProfilePageHeader(
                        title: 'Identity Verification',
                        onBack: _close,
                      ),
                    ),
                  ),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.controller.isLoading) {
      return const Center(
        key: Key('identity_initial_loading'),
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }
    if (widget.controller.loadStatus == IdentityLoadStatus.failure ||
        widget.controller.verification == null) {
      return ProfileStateMessage(
        key: const Key('identity_load_error'),
        icon: Icons.error_outline_rounded,
        title: 'Verification unavailable',
        message: widget.controller.errorMessage ?? 'Please try again.',
        actionLabel: 'Try Again',
        onAction: widget.controller.retry,
      );
    }
    return switch (widget.controller.flowStep) {
      IdentityVerificationFlowStep.status => _status(),
      IdentityVerificationFlowStep.introduction => _introduction(),
      IdentityVerificationFlowStep.legalDetails => _LegalDetailsStep(
        accountName: widget.controller.accountName,
        initialDetails: widget.controller.legalDetails,
        helperText: widget.entryPoint == IdentityVerificationEntryPoint.signup
            ? 'Confirm that this name exactly matches your CNIC. The verified name will be used on your account, policies, claims, receipts, and official documents.'
            : 'Confirm that this name exactly matches your CNIC. It will be used on your policies and official documents after verification.',
        errors: widget.controller.validationErrors,
        onContinue: _submitLegalDetails,
      ),
      IdentityVerificationFlowStep.frontCapture => _capture(
        side: IdentityCaptureSide.front,
        title: 'CNIC Front',
        instructions: 'Place the front of your CNIC inside the guide.',
      ),
      IdentityVerificationFlowStep.backCapture => _capture(
        side: IdentityCaptureSide.back,
        title: 'CNIC Back',
        instructions: 'Place the back of your CNIC inside the guide.',
      ),
      IdentityVerificationFlowStep.liveness => _capture(
        side: IdentityCaptureSide.selfie,
        title: 'Live Selfie',
        instructions:
            '${widget.controller.livenessInstruction}. The final challenge and decision will come from a secure identity provider.',
      ),
      IdentityVerificationFlowStep.processing => _processing(),
      IdentityVerificationFlowStep.result => _status(showResult: true),
    };
  }

  Widget _introduction() => ListView(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
    children: <Widget>[
      GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.verified_user_outlined,
              color: AppColors.blue,
              size: 36,
            ),
            const SizedBox(height: 14),
            const Text(
              'Before you continue',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Identity verification is required before submitting, paying for, or receiving an insurance policy. We will collect your legal details, live CNIC front and back captures, and liveness evidence for provider verification.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Verified legal information becomes locked. Corrections require support and re-verification. Final privacy, processing, and retention text will be added after legal review.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              key: const Key('identity_consent_checkbox'),
              contentPadding: EdgeInsets.zero,
              value: widget.controller.consentConfirmed,
              onChanged: (bool? value) =>
                  widget.controller.updateConsent(value ?? false),
              title: const Text(
                'I consent to continue with identity verification.',
                style: TextStyle(color: AppColors.white, fontSize: 13),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      if (widget.controller.submissionErrorMessage != null)
        _error(widget.controller.submissionErrorMessage!),
      const SizedBox(height: 18),
      GlassActionButton(
        key: const Key('identity_intro_continue_button'),
        label: 'Continue',
        onPressed: widget.controller.consentConfirmed
            ? widget.controller.continueFromIntroduction
            : null,
      ),
      TextButton(
        onPressed: () async {
          await widget.controller.cancelVerification();
          _close();
        },
        child: const Text('Cancel Verification'),
      ),
    ],
  );

  Widget _capture({
    required IdentityCaptureSide side,
    required String title,
    required String instructions,
  }) {
    final bool registered = switch (side) {
      IdentityCaptureSide.front => widget.controller.frontCapture != null,
      IdentityCaptureSide.back => widget.controller.backCapture != null,
      IdentityCaptureSide.selfie => widget.controller.selfieCapture != null,
    };
    return Column(
      children: <Widget>[
        if (widget.controller.captureErrorMessage != null)
          _error(widget.controller.captureErrorMessage!),
        Expanded(
          child: LiveIdentityCaptureStep(
            side: side,
            title: title,
            instructions: instructions,
            hasRegisteredCapture: registered,
            isRegistering: widget.controller.isCapturing,
            captureOverride: widget.captureOverride,
            onRegister: widget.controller.registerCapture,
            onRetake: () => widget.controller.retakeCapture(side),
            onContinue: () {
              if (widget.controller.continueAfterCapture(side) &&
                  side == IdentityCaptureSide.selfie) {
                unawaited(_confirmAndSubmitVerification());
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _processing() => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (widget.controller.isSubmitting)
            const CircularProgressIndicator(color: AppColors.blue)
          else
            const Icon(
              Icons.verified_user_outlined,
              color: AppColors.blue,
              size: 44,
            ),
          const SizedBox(height: 22),
          Text(
            widget.controller.isSubmitting
                ? _processingLabel(widget.controller.processingStage)
                : 'Ready to submit verification',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your evidence is being handled through a short-lived private upload session.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          if (!widget.controller.isSubmitting) ...<Widget>[
            const SizedBox(height: 22),
            GlassActionButton(
              key: const Key('submit_identity_verification_button'),
              label: 'Submit Verification',
              onPressed: _confirmAndSubmitVerification,
            ),
          ],
        ],
      ),
    ),
  );

  Widget _status({bool showResult = false}) {
    final IdentityVerification verification = widget.controller.verification!;
    final IdentityVerificationStatus status = verification.status;
    final bool canStart =
        status == IdentityVerificationStatus.notStarted ||
        status == IdentityVerificationStatus.rejected ||
        status == IdentityVerificationStatus.expired;
    final bool canResume = status == IdentityVerificationStatus.capturing;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
      children: <Widget>[
        GlassContainer(
          key: const Key('identity_verification_card'),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IdentityStatusBadge(status: status),
              const SizedBox(height: 12),
              Text(
                showResult && status == IdentityVerificationStatus.verified
                    ? widget.controller.verifiedNameWasUpdated
                          ? 'Identity verified. Your account name has been updated to match your CNIC.'
                          : 'Identity verified successfully.'
                    : _statusMessage(status),
                key: const Key('identity_status_explanation'),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              _IdentityRow(
                label: 'Identity number',
                value: verification.maskedIdentityNumber,
              ),
              if (verification.submittedAt != null)
                _IdentityRow(
                  label: 'Submitted',
                  value: _formatDate(verification.submittedAt!),
                ),
              if (verification.verifiedAt != null)
                _IdentityRow(
                  label: 'Verified',
                  value: _formatDate(verification.verifiedAt!),
                ),
              if (verification.rejectionReason != null)
                _IdentityRow(
                  label: 'Status detail',
                  value: verification.rejectionReason!,
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'InsureX is showing a mock verification state. Document authenticity and liveness decisions require the future secure backend provider.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10.5,
            height: 1.4,
          ),
        ),
        if (widget.controller.submissionErrorMessage != null)
          _error(widget.controller.submissionErrorMessage!),
        if (canStart || canResume) ...<Widget>[
          const SizedBox(height: 18),
          GlassActionButton(
            key: const Key('start_identity_verification_button'),
            label: canResume
                ? 'Resume Verification'
                : status == IdentityVerificationStatus.rejected
                ? 'Retry Verification'
                : 'Start Verification',
            icon: Icons.verified_user_outlined,
            onPressed: widget.controller.startOrResumeVerification,
          ),
        ],
        if (status == IdentityVerificationStatus.technicalFailure) ...<Widget>[
          const SizedBox(height: 18),
          GlassActionButton(
            label: 'Try Again',
            onPressed: widget.controller.retrySubmission,
          ),
        ],
        if (status == IdentityVerificationStatus.additionalCaptureRequired)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              'A specific capture needs to be completed again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFFFC857)),
            ),
          ),
        if (showResult &&
            status == IdentityVerificationStatus.verified) ...<Widget>[
          const SizedBox(height: 18),
          GlassActionButton(label: 'Continue', onPressed: _close),
        ],
        if (status == IdentityVerificationStatus.rejected ||
            status == IdentityVerificationStatus.additionalCaptureRequired)
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Contact Support will be connected with the secure backend.',
                ),
              ),
            ),
            child: const Text('Contact Support'),
          ),
      ],
    );
  }

  Widget _error(String message) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFFFFB3BE), fontSize: 11),
    ),
  );

  Future<void> _confirmAndSubmitVerification() async {
    if (!await _confirmNameChangeIfRequired()) {
      widget.controller.reviewLegalDetails();
      return;
    }
    await widget.controller.submitVerification();
  }

  Future<bool> _submitLegalDetails(IdentityLegalDetails details) async {
    if (!widget.controller.submitLegalDetails(details)) {
      return false;
    }
    if (widget.entryPoint == IdentityVerificationEntryPoint.signup &&
        !await _confirmNameChangeIfRequired()) {
      widget.controller.reviewLegalDetails();
      return false;
    }
    return true;
  }

  Future<bool> _confirmNameChangeIfRequired() async {
    if (!widget.controller.hasMeaningfulNameChange ||
        widget.controller.isNameChangeConfirmed) {
      return true;
    }
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: Text(
              widget.entryPoint == IdentityVerificationEntryPoint.signup
                  ? 'Confirm account name'
                  : 'Confirm account name update',
            ),
            content: Text(
              '${widget.entryPoint == IdentityVerificationEntryPoint.signup ? 'Signup name' : 'Current account name'}: ${widget.controller.accountName}\n\n'
              'Name for verification: '
              '${widget.controller.pendingVerificationName}\n\n'
              '${widget.entryPoint == IdentityVerificationEntryPoint.signup ? 'If verification succeeds, this verified name will become your account name and will be used on policies and official documents.' : 'If verification succeeds, your account name will be updated and used on your profile, policies, claims, receipts, and official documents.'}',
            ),
            actions: <Widget>[
              TextButton(
                key: const Key('go_back_name_update_button'),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Go Back'),
              ),
              TextButton(
                key: const Key('confirm_name_update_button'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Confirm and Continue'),
              ),
            ],
          ),
        ) ??
        false;
    if (!mounted || !confirmed) {
      return false;
    }
    widget.controller.confirmNameChange();
    return true;
  }

  void _close() {
    if (_isClosing) return;
    _isClosing = true;
    widget.onBack(widget.controller.verification);
  }

  static String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _LegalDetailsStep extends StatefulWidget {
  const _LegalDetailsStep({
    required this.accountName,
    required this.errors,
    required this.helperText,
    required this.onContinue,
    this.initialDetails,
  });
  final String accountName;
  final IdentityLegalDetails? initialDetails;
  final Map<String, String> errors;
  final String helperText;
  final Future<bool> Function(IdentityLegalDetails details) onContinue;

  @override
  State<_LegalDetailsStep> createState() => _LegalDetailsStepState();
}

class _LegalDetailsStepState extends State<_LegalDetailsStep> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _cnic = TextEditingController();
  final FocusNode _cnicFocusNode = FocusNode();
  DateTime? _birthDate;
  DateTime? _expiryDate;
  ProfileGender _gender = ProfileGender.preferNotToSay;
  String? _localCnicError;
  bool _showControllerCnicError = false;

  @override
  void initState() {
    super.initState();
    final IdentityLegalDetails? initialDetails = widget.initialDetails;
    _name.text = initialDetails?.fullLegalName ?? widget.accountName;
    _cnic.text = IdentityVerificationValidator.formatCnic(
      initialDetails?.cnicNumber,
    );
    _birthDate = initialDetails?.dateOfBirth;
    _expiryDate = initialDetails?.cnicExpiryDate;
    _gender = initialDetails?.gender ?? ProfileGender.preferNotToSay;
    _cnicFocusNode.addListener(_validateCnicAfterFocusLoss);
  }

  @override
  void dispose() {
    _name.dispose();
    _cnicFocusNode
      ..removeListener(_validateCnicAfterFocusLoss)
      ..dispose();
    _cnic.clear();
    _cnic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
    children: <Widget>[
      const Text(
        'Enter Legal Details',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Enter these details exactly as shown on your CNIC. The secure backend remains authoritative.',
        style: TextStyle(color: AppColors.textSecondary, height: 1.45),
      ),
      const SizedBox(height: 18),
      TextField(
        key: const Key('verification_full_name_field'),
        controller: _name,
        decoration: InputDecoration(
          labelText: 'Full name as shown on your CNIC',
          helperText: widget.helperText,
          errorText: widget.errors['fullLegalName'],
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        key: const Key('verification_cnic_field'),
        controller: _cnic,
        keyboardType: TextInputType.number,
        focusNode: _cnicFocusNode,
        inputFormatters: const <TextInputFormatter>[_CnicInputFormatter()],
        onChanged: _handleCnicChanged,
        decoration: InputDecoration(
          labelText: 'CNIC number',
          hintText: '12345-1234567-1',
          errorText:
              _localCnicError ??
              (_showControllerCnicError ? widget.errors['cnicNumber'] : null),
        ),
      ),
      const SizedBox(height: 12),
      _DateTile(
        label: 'Date of birth',
        value: _birthDate,
        error: widget.errors['dateOfBirth'],
        onTap: () => _pickDate(isExpiry: false),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<ProfileGender>(
        initialValue: _gender,
        decoration: const InputDecoration(labelText: 'Gender'),
        items: ProfileGender.values
            .map(
              (ProfileGender value) => DropdownMenuItem<ProfileGender>(
                value: value,
                child: Text(_genderLabel(value)),
              ),
            )
            .toList(),
        onChanged: (ProfileGender? value) {
          if (value != null) setState(() => _gender = value);
        },
      ),
      const SizedBox(height: 12),
      _DateTile(
        label: 'CNIC expiry date',
        value: _expiryDate,
        error: widget.errors['cnicExpiryDate'],
        onTap: () => _pickDate(isExpiry: true),
      ),
      const SizedBox(height: 20),
      GlassActionButton(
        key: const Key('legal_details_continue_button'),
        label: 'Continue to Live Capture',
        onPressed: _continue,
      ),
    ],
  );

  Future<void> _continue() async {
    final DateTime now = DateTime.now();
    setState(() {
      _showControllerCnicError = true;
      _localCnicError = IdentityVerificationValidator.validateCnic(_cnic.text);
    });
    await widget.onContinue(
      IdentityLegalDetails(
        fullLegalName: _name.text,
        cnicNumber: _cnic.text,
        dateOfBirth: _birthDate ?? now.add(const Duration(days: 1)),
        gender: _gender,
        cnicExpiryDate: _expiryDate ?? now.subtract(const Duration(days: 1)),
      ),
    );
  }

  void _handleCnicChanged(String value) {
    final int digitCount = IdentityVerificationValidator.normalizeCnicDigits(
      value,
    ).length;
    setState(() {
      _showControllerCnicError = false;
      _localCnicError =
          digitCount == IdentityVerificationValidator.cnicDigitCount
          ? IdentityVerificationValidator.validateCnic(value)
          : null;
    });
  }

  void _validateCnicAfterFocusLoss() {
    if (_cnicFocusNode.hasFocus || _cnic.text.isEmpty || !mounted) {
      return;
    }
    setState(() {
      _showControllerCnicError = false;
      _localCnicError = IdentityVerificationValidator.validateCnic(_cnic.text);
    });
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final DateTime now = DateTime.now();
    final DateTime? value = await showDatePicker(
      context: context,
      initialDate: isExpiry ? DateTime(now.year + 5) : DateTime(now.year - 25),
      firstDate: isExpiry ? now : DateTime(1900),
      lastDate: isExpiry ? DateTime(now.year + 30) : now,
    );
    if (value != null) {
      setState(() {
        if (isExpiry) {
          _expiryDate = value;
        } else {
          _birthDate = value;
        }
      });
    }
  }
}

class _CnicInputFormatter extends TextInputFormatter {
  const _CnicInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String formatted = IdentityVerificationValidator.formatCnic(
      newValue.text,
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.error,
  });
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      child: Text(
        value == null
            ? 'Select date'
            : '${value!.day}/${value!.month}/${value!.year}',
        style: const TextStyle(color: AppColors.white),
      ),
    ),
  );
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

String _genderLabel(ProfileGender value) => switch (value) {
  ProfileGender.female => 'Female',
  ProfileGender.male => 'Male',
  ProfileGender.other => 'Other',
  ProfileGender.preferNotToSay => 'Prefer not to say',
};

String _processingLabel(IdentityProcessingStage stage) => switch (stage) {
  IdentityProcessingStage.idle => 'Preparing secure verification',
  IdentityProcessingStage.uploadingFront => 'Uploading CNIC front',
  IdentityProcessingStage.uploadingBack => 'Uploading CNIC back',
  IdentityProcessingStage.checkingImageQuality => 'Checking image quality',
  IdentityProcessingStage.verifyingIdentityDetails =>
    'Verifying identity details',
  IdentityProcessingStage.checkingLiveness => 'Checking liveness',
  IdentityProcessingStage.completingVerification => 'Completing verification',
};

String _statusMessage(IdentityVerificationStatus status) => switch (status) {
  IdentityVerificationStatus.notStarted =>
    'Start verification when you are ready to confirm your identity.',
  IdentityVerificationStatus.capturing =>
    'Verification capture is in progress and can be resumed.',
  IdentityVerificationStatus.submitted || IdentityVerificationStatus.pending =>
    'Your identity information is pending provider review. Duplicate submissions are disabled.',
  IdentityVerificationStatus.verified =>
    'Your identity has been verified successfully.',
  IdentityVerificationStatus.rejected =>
    'Verification was not completed. Review the general reason and retry safely.',
  IdentityVerificationStatus.expired =>
    'Your previous verification has expired. Re-verification is required.',
  IdentityVerificationStatus.additionalCaptureRequired =>
    'The provider needs one capture to be completed again.',
  IdentityVerificationStatus.technicalFailure =>
    'A technical problem interrupted verification. Safe progress is preserved for retry.',
};
