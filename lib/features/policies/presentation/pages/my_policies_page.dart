import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_background.dart';
import '../../application/controllers/policies_controller.dart';
import '../../domain/entities/insurance_policy.dart';
import '../widgets/buy_policy_button.dart';
import '../widgets/policies_header.dart';
import '../widgets/policy_card.dart';
import '../widgets/policy_filter_tabs.dart';

class MyPoliciesPage extends StatefulWidget {
  const MyPoliciesPage({
    required this.controller,
    required this.onBack,
    required this.onPolicyPressed,
    required this.onBuyPolicy,
    required this.onSearch,
    super.key,
  });

  final PoliciesController controller;

  final VoidCallback onBack;

  final ValueChanged<InsurancePolicy> onPolicyPressed;

  final VoidCallback onBuyPolicy;

  final VoidCallback onSearch;

  @override
  State<MyPoliciesPage> createState() => _MyPoliciesPageState();
}

class _MyPoliciesPageState extends State<MyPoliciesPage> {
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (BuildContext context, Widget? child) {
              return RefreshIndicator(
                onRefresh: widget.controller.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          PoliciesHeader(
                            onBack: widget.onBack,
                            onSearch: widget.onSearch,
                          ),

                          const SizedBox(height: 24),

                          PolicyFilterTabs(
                            selectedFilter: widget.controller.selectedFilter,
                            onFilterChanged: widget.controller.changeFilter,
                          ),

                          const SizedBox(height: 24),

                          _buildContent(),

                          const SizedBox(height: 26),

                          BuyPolicyButton(onPressed: widget.onBuyPolicy),
                        ],
                      ),
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

  Widget _buildContent() {
    if (widget.controller.isLoading && widget.controller.policies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.controller.status == PoliciesStatus.failure &&
        widget.controller.policies.isEmpty) {
      return _PoliciesError(
        message: widget.controller.errorMessage ?? 'Something went wrong.',
        onRetry: widget.controller.loadPolicies,
      );
    }

    final List<InsurancePolicy> policies = widget.controller.filteredPolicies;

    if (policies.isEmpty) {
      return const _EmptyPolicies();
    }

    return Column(
      children: policies.map((InsurancePolicy policy) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: PolicyCard(
            policy: policy,
            onTap: () {
              widget.onPolicyPressed(policy);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyPolicies extends StatelessWidget {
  const _EmptyPolicies();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.white.withValues(alpha: 0.5),
              size: 32,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No policies found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'There are no policies in this category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PoliciesError extends StatelessWidget {
  const _PoliciesError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF718A),
            size: 40,
          ),

          const SizedBox(height: 14),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),

          const SizedBox(height: 16),

          TextButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
