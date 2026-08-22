import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_background.dart';
import '../../application/controllers/policy_details_controller.dart';
import '../../domain/entities/insurance_policy.dart';
import '../../domain/entities/policy_details.dart';
import '../widgets/activate_claim_button.dart';
import '../widgets/blockchain_status_card.dart';
import '../widgets/policy_details_header.dart';
import '../widgets/policy_information_card.dart';
import '../widgets/policy_summary_card.dart';

class PolicyDetailsPage extends StatefulWidget {
  const PolicyDetailsPage({
    required this.policy,
    required this.controller,
    required this.onBack,
    required this.onActivateClaim,
    super.key,
  });

  final InsurancePolicy policy;

  final PolicyDetailsController controller;

  final VoidCallback onBack;

  final ValueChanged<InsurancePolicy>
  onActivateClaim;

  @override
  State<PolicyDetailsPage> createState() =>
      _PolicyDetailsPageState();
}

class _PolicyDetailsPageState
    extends State<PolicyDetailsPage> {
  @override
  void initState() {
    super.initState();

    widget.controller.loadPolicyDetails(
      widget.policy,
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (
                BuildContext context,
                Widget? child,
                ) {
              if (widget.controller.isLoading &&
                  widget.controller.details ==
                      null) {
                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              }

              if (widget.controller.status ==
                  PolicyDetailsStatus.failure &&
                  widget.controller.details ==
                      null) {
                return _ErrorView(
                  message:
                  widget.controller.errorMessage ??
                      'Unable to load policy.',
                  onRetry: () {
                    widget.controller
                        .loadPolicyDetails(
                      widget.policy,
                    );
                  },
                  onBack: widget.onBack,
                );
              }

              final PolicyDetails? details =
                  widget.controller.details;

              if (details == null) {
                return const SizedBox.shrink();
              }

              return SingleChildScrollView(
                padding:
                const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  30,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(
                      maxWidth: 430,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: <Widget>[
                        PolicyDetailsHeader(
                          onBack:
                          widget.onBack,
                        ),

                        const SizedBox(height: 24),

                        PolicySummaryCard(
                          policy:
                          details.policy,
                        ),

                        const SizedBox(height: 25),

                        const _SectionTitle(
                          title:
                          'Policy Information',
                        ),

                        const SizedBox(height: 12),

                        PolicyInformationCard(
                          details: details,
                        ),

                        const SizedBox(height: 25),

                        const _SectionTitle(
                          title:
                          'Blockchain Verification',
                        ),

                        const SizedBox(height: 12),

                        BlockchainStatusCard(
                          verified: details
                              .isStoredOnBlockchain,
                          transactionHash:
                          details
                              .transactionHash,
                        ),

                        const SizedBox(height: 28),

                        ActivateClaimButton(
                          enabled:
                          details.policy.status ==
                              PolicyStatus.active,
                          onPressed: () {
                            widget
                                .onActivateClaim(
                              details.policy,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFFF718A),
                size: 44,
              ),

              const SizedBox(height: 16),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton(
                onPressed: onRetry,
                child:
                const Text('Try Again'),
              ),

              TextButton(
                onPressed: onBack,
                child:
                const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}