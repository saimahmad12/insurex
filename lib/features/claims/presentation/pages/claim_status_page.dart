import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/claim_status_controller.dart';
import '../../domain/entities/ai_verification_result.dart';
import '../../domain/entities/insurance_claim.dart';
import '../widgets/additional_evidence_request_card.dart';
import '../widgets/ai_verification_summary_card.dart';
import '../widgets/claim_blockchain_status_card.dart';
import '../widgets/claim_decision_card.dart';
import '../widgets/claim_evidence_preview.dart';
import '../widgets/claim_payment_status_card.dart';
import '../widgets/claim_progress_timeline.dart';
import '../widgets/claim_status_action_button.dart';
import '../widgets/claim_status_header.dart';
import '../widgets/claim_status_summary_card.dart';
import '../widgets/fraud_risk_score_gauge.dart';

class ClaimStatusPage extends StatefulWidget {
  const ClaimStatusPage({
    required this.controller,
    required this.onBack,
    required this.onFileClaim,
    required this.onContextualAction,
    this.claimId,
    this.invalidArgument = false,
    super.key,
  });

  final ClaimStatusController controller;
  final String? claimId;
  final bool invalidArgument;
  final VoidCallback onBack;
  final VoidCallback onFileClaim;
  final ValueChanged<ClaimStatusAction> onContextualAction;

  @override
  State<ClaimStatusPage> createState() => _ClaimStatusPageState();
}

class _ClaimStatusPageState extends State<ClaimStatusPage> {
  @override
  void initState() {
    super.initState();
    if (!widget.invalidArgument) {
      widget.controller.initialize(claimId: widget.claimId);
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (BuildContext context, Widget? child) {
              final InsuranceClaim? claim = widget.controller.claim;

              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: ClaimStatusHeader(
                          onBack: widget.onBack,
                          onRefresh: claim == null
                              ? null
                              : widget.controller.refresh,
                          isRefreshing: widget.controller.isRefreshing,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _buildBody(claim)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(InsuranceClaim? claim) {
    if (widget.invalidArgument) {
      return _ClaimStatusMessage(
        key: const Key('claim_status_invalid_argument'),
        icon: Icons.error_outline_rounded,
        title: 'Claim information is unavailable',
        message: 'Open Claim Status from a valid claim or from the Dashboard.',
        actionLabel: 'Go Back',
        onAction: widget.onBack,
      );
    }

    if (widget.controller.isInitialLoading) {
      return const Center(
        key: Key('claim_status_initial_loading'),
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }

    if (widget.controller.loadState == ClaimStatusLoadState.failure &&
        claim == null) {
      return _ClaimStatusMessage(
        key: const Key('claim_status_error'),
        icon: Icons.error_outline_rounded,
        title: 'Unable to load claim status',
        message:
            widget.controller.errorMessage ?? 'Please try again in a moment.',
        actionLabel: 'Try Again',
        onAction: widget.controller.retry,
      );
    }

    if (widget.controller.loadState == ClaimStatusLoadState.notFound) {
      return _ClaimStatusMessage(
        key: const Key('claim_status_not_found'),
        icon: Icons.search_off_rounded,
        title: 'Claim not found',
        message: 'The requested claim could not be found.',
        actionLabel: 'Go Back',
        onAction: widget.onBack,
      );
    }

    if (widget.controller.loadState == ClaimStatusLoadState.empty ||
        claim == null) {
      return _ClaimStatusMessage(
        key: const Key('claim_status_empty'),
        icon: Icons.assignment_outlined,
        title: 'No active claims',
        message: 'You have not submitted a claim yet.',
        actionLabel: 'File a Claim',
        onAction: widget.onFileClaim,
      );
    }

    final AiVerificationResult? aiResult = claim.aiVerificationResult;
    final ClaimStatusAction? action = widget.controller.contextualAction;

    return RefreshIndicator(
      key: const Key('claim_status_refresh_indicator'),
      color: AppColors.blue,
      onRefresh: widget.controller.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (widget.controller.refreshErrorMessage !=
                      null) ...<Widget>[
                    _RefreshError(
                      message: widget.controller.refreshErrorMessage!,
                      onRetry: widget.controller.refresh,
                    ),
                    const SizedBox(height: 14),
                  ],
                  ClaimStatusSummaryCard(claim: claim),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Claim Progress'),
                  const SizedBox(height: 12),
                  ClaimProgressTimeline(events: widget.controller.timeline),
                  const SizedBox(height: 24),
                  FraudRiskScoreGauge(
                    score: aiResult?.fraudRiskScore.toDouble(),
                    riskLevel: widget.controller.fraudRiskLevel,
                    analysisCompleted:
                        claim.aiAnalysisStatus == AiAnalysisStatus.completed &&
                        aiResult != null,
                  ),
                  const SizedBox(height: 24),
                  AiVerificationSummaryCard(
                    claim: claim,
                    requiresManualReview:
                        widget.controller.requiresManualReview,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Submitted Incident Images'),
                  const SizedBox(height: 12),
                  ClaimEvidencePreview(
                    images: claim.evidenceImages,
                    analysedImageCount: aiResult?.analysedImageCount ?? 0,
                    onImagePressed: (int index) {
                      _showEvidencePreview(claim, index);
                    },
                  ),
                  if (claim.additionalEvidenceRequest != null) ...<Widget>[
                    const SizedBox(height: 24),
                    AdditionalEvidenceRequestCard(
                      request: claim.additionalEvidenceRequest!,
                      onUploadEvidence: () {
                        widget.onContextualAction(
                          ClaimStatusAction.uploadEvidence,
                        );
                      },
                    ),
                  ],
                  if (claim.decision != null) ...<Widget>[
                    const SizedBox(height: 24),
                    ClaimDecisionCard(
                      decision: claim.decision!,
                      onContactSupport: () {
                        widget.onContextualAction(
                          ClaimStatusAction.contactSupport,
                        );
                      },
                    ),
                  ],
                  if (widget.controller.showPaymentCard) ...<Widget>[
                    const SizedBox(height: 24),
                    ClaimPaymentStatusCard(
                      payment: widget.controller.payment!,
                      action: action == null
                          ? null
                          : ClaimStatusActionButton(
                              action: action,
                              onPressed: () {
                                widget.onContextualAction(action);
                              },
                            ),
                    ),
                  ],
                  if (claim.blockchainRecord != null) ...<Widget>[
                    const SizedBox(height: 24),
                    ClaimBlockchainStatusCard(
                      record: claim.blockchainRecord!,
                      onCopyTransactionHash: _copyTransactionHash,
                    ),
                  ],
                  if (action != null &&
                      !widget.controller.showPaymentCard) ...<Widget>[
                    const SizedBox(height: 28),
                    ClaimStatusActionButton(
                      action: action,
                      onPressed: () {
                        widget.onContextualAction(action);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEvidencePreview(InsuranceClaim claim, int initialIndex) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ClaimEvidencePreviewDialog(
          images: claim.evidenceImages,
          initialIndex: initialIndex,
        );
      },
    );
  }

  Future<void> _copyTransactionHash(String transactionHash) async {
    await Clipboard.setData(ClipboardData(text: transactionHash));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Transaction hash copied.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RefreshError extends StatelessWidget {
  const _RefreshError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('claim_status_refresh_error'),
      padding: const EdgeInsets.fromLTRB(14, 10, 7, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF718A).withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFF718A).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFFFB3BE),
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _ClaimStatusMessage extends StatelessWidget {
  const _ClaimStatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, color: AppColors.blue, size: 44),
                const SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.67),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                GlassActionButton(label: actionLabel, onPressed: onAction),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
