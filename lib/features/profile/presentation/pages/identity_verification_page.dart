import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/identity_verification_controller.dart';
import '../../domain/entities/identity_verification.dart';
import '../widgets/identity_status_badge.dart';
import '../widgets/profile_page_header.dart';
import '../widgets/profile_state_message.dart';

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({
    required this.controller,
    required this.onBack,
    super.key,
  });

  final IdentityVerificationController controller;
  final ValueChanged<IdentityVerification?> onBack;

  @override
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
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
        if (!didPop) {
          _close();
        }
      },
      child: Scaffold(
        body: GlassBackground(
          child: SafeArea(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (BuildContext context, Widget? child) {
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: ProfilePageHeader(
                            title: 'Identity Verification',
                            onBack: _close,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: _buildBody()),
                  ],
                );
              },
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
    final IdentityVerification? verification = widget.controller.verification;
    if (widget.controller.loadStatus == IdentityLoadStatus.failure ||
        verification == null) {
      return ProfileStateMessage(
        key: const Key('identity_load_error'),
        icon: Icons.error_outline_rounded,
        title: 'Verification unavailable',
        message: widget.controller.errorMessage ?? 'Please try again.',
        actionLabel: 'Try Again',
        onAction: widget.controller.retry,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                GlassContainer(
                  key: const Key('identity_verification_card'),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      IdentityStatusBadge(status: verification.status),
                      const SizedBox(height: 10),
                      Text(
                        _statusMessage(verification.status),
                        key: const Key('identity_status_explanation'),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                          height: 1.4,
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
                  'InsureX is showing a mock verification state. No real identity provider or document upload is connected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
                if (widget.controller.submissionErrorMessage !=
                    null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    widget.controller.submissionErrorMessage!,
                    key: const Key('identity_submission_error'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFB3BE),
                      fontSize: 11,
                    ),
                  ),
                ],
                if (verification.status ==
                        IdentityVerificationStatus.notStarted ||
                    verification.status ==
                        IdentityVerificationStatus.rejected) ...<Widget>[
                  const SizedBox(height: 18),
                  GlassActionButton(
                    key: const Key('start_identity_verification_button'),
                    label:
                        verification.status ==
                            IdentityVerificationStatus.rejected
                        ? 'Retry Verification'
                        : 'Start Verification',
                    icon: Icons.verified_user_outlined,
                    isLoading: widget.controller.isSubmitting,
                    onPressed: widget.controller.isSubmitting
                        ? null
                        : widget.controller.startVerification,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  static String _statusMessage(IdentityVerificationStatus status) {
    return switch (status) {
      IdentityVerificationStatus.notStarted =>
        'Start verification when you are ready to confirm your identity.',
      IdentityVerificationStatus.pending =>
        'Your identity information is pending review.',
      IdentityVerificationStatus.verified =>
        'Your identity has been verified successfully.',
      IdentityVerificationStatus.rejected =>
        'Verification was not completed. Review the reason below and try again.',
    };
  }

  void _close() {
    if (_isClosing) {
      return;
    }
    _isClosing = true;
    widget.onBack(widget.controller.verification);
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
}
