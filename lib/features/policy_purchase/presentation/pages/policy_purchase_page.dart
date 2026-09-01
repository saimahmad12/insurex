import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../insurance_marketplace/domain/entities/insurance_product.dart';
import '../../../insurance_marketplace/presentation/widgets/insurance_product_card.dart';
import '../../../policies/domain/entities/insurance_policy.dart';
import '../../../profile/domain/entities/identity_verification.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/widgets/profile_page_header.dart';
import '../../application/controllers/policy_application_controller.dart';
import '../../application/controllers/policy_purchase_controller.dart';
import '../../application/controllers/policy_quote_controller.dart';
import '../../application/controllers/premium_payment_controller.dart';
import '../../domain/entities/policy_application.dart';
import '../../domain/entities/policy_application_details.dart';
import '../../domain/entities/policy_configuration.dart';
import '../../domain/entities/policy_eligibility.dart';
import '../../domain/entities/policy_issuance.dart';
import '../../domain/entities/policy_quote.dart';
import '../../domain/entities/premium_payment.dart';
import '../widgets/beneficiary_form.dart';
import '../widgets/category_application_form.dart';
import '../widgets/coverage_configuration_card.dart';

class PolicyPurchasePage extends StatefulWidget {
  const PolicyPurchasePage({
    required this.purchaseController,
    required this.quoteController,
    required this.applicationController,
    required this.paymentController,
    required this.onBack,
    required this.onVerifyIdentity,
    required this.onViewPolicy,
    required this.onViewPaymentReceipt,
    required this.onMyPolicies,
    required this.onDashboard,
    required this.onDownloadDocument,
    super.key,
  });

  final PolicyPurchaseController purchaseController;
  final PolicyQuoteController quoteController;
  final PolicyApplicationController applicationController;
  final PremiumPaymentController paymentController;
  final VoidCallback onBack;
  final Future<IdentityVerification?> Function() onVerifyIdentity;
  final ValueChanged<InsurancePolicy> onViewPolicy;
  final ValueChanged<PremiumPayment> onViewPaymentReceipt;
  final VoidCallback onMyPolicies;
  final VoidCallback onDashboard;
  final VoidCallback onDownloadDocument;

  @override
  State<PolicyPurchasePage> createState() => _PolicyPurchasePageState();
}

class _PolicyPurchasePageState extends State<PolicyPurchasePage> {
  late final Listenable _listenable;

  @override
  void initState() {
    super.initState();
    _listenable = Listenable.merge(<Listenable>[
      widget.purchaseController,
      widget.quoteController,
      widget.applicationController,
      widget.paymentController,
    ]);
    widget.purchaseController.initialize();
  }

  @override
  void dispose() {
    widget.purchaseController.dispose();
    widget.quoteController.dispose();
    widget.applicationController.dispose();
    widget.paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      onPopInvokedWithResult: (bool didPop, void result) {
        if (!didPop) _back();
      },
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GlassBackground(
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _listenable,
              builder: (BuildContext context, Widget? child) {
                if (widget.purchaseController.isInitialLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      key: Key('policy_purchase_initial_loader'),
                    ),
                  );
                }
                if (widget.purchaseController.loadStatus ==
                    PolicyPurchaseLoadStatus.failure) {
                  return _failure(
                    widget.purchaseController.errorMessage ??
                        'Policy purchase is unavailable.',
                    widget.purchaseController.retry,
                  );
                }
                final InsuranceProduct? product =
                    widget.purchaseController.product;
                if (product == null) return const SizedBox.shrink();
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                      child: ProfilePageHeader(
                        title: _title(widget.purchaseController.step),
                        onBack: _back,
                      ),
                    ),
                    Expanded(child: _step(product)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _step(InsuranceProduct product) =>
      switch (widget.purchaseController.step) {
        PolicyPurchaseStep.configure => _configure(product),
        PolicyPurchaseStep.application => _application(product),
        PolicyPurchaseStep.beneficiaries => _beneficiaries(),
        PolicyPurchaseStep.quote => _quote(product),
        PolicyPurchaseStep.review => _review(product),
        PolicyPurchaseStep.providerReview => _providerReview(),
        PolicyPurchaseStep.payment => _payment(),
        PolicyPurchaseStep.issuing => _issuing(),
        PolicyPurchaseStep.success => _success(),
      };

  Widget _configure(InsuranceProduct product) {
    final PolicyConfiguration configuration =
        widget.purchaseController.configuration!;
    return ListView(
      key: const PageStorageKey<String>('policy_coverage_configuration'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
      children: <Widget>[
        Text(
          product.name,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          product.providerName,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        CoverageConfigurationCard(
          product: product,
          configuration: configuration,
          onChanged: (PolicyConfiguration value) {
            widget.purchaseController.updateConfiguration(value);
            widget.quoteController.invalidate();
          },
        ),
        if (widget.purchaseController.validationErrors.isNotEmpty)
          _error(widget.purchaseController.validationErrors.values.first),
        if (widget.purchaseController.draftMessage != null)
          _notice(widget.purchaseController.draftMessage!),
        const SizedBox(height: 18),
        GlassActionButton(
          key: const Key('configure_buy_now_button'),
          label: 'Buy Now',
          icon: Icons.arrow_forward_rounded,
          onPressed: _continueFromConfiguration,
        ),
        TextButton(
          onPressed:
              widget.purchaseController.draftSaveStatus ==
                  DraftSaveStatus.saving
              ? null
              : widget.purchaseController.saveDraft,
          child: const Text('Save Draft'),
        ),
        if (widget.purchaseController.applicationDetails != null)
          TextButton(
            onPressed: widget.purchaseController.deleteDraft,
            child: const Text('Delete Draft'),
          ),
      ],
    );
  }

  Future<void> _continueFromConfiguration() async {
    if (!widget.purchaseController.validateConfiguration()) return;
    await widget.purchaseController.saveDraft();
    switch (widget.purchaseController.identityAction) {
      case PolicyPurchaseIdentityAction.verificationPending:
        _show('Identity verification is pending. Your policy draft is saved.');
        return;
      case PolicyPurchaseIdentityAction.startVerification ||
          PolicyPurchaseIdentityAction.resumeVerification:
        await widget.onVerifyIdentity();
        await widget.purchaseController.refreshProfile();
        if (!widget.purchaseController.isIdentityVerified) {
          _show(
            'Complete identity verification before continuing. Your draft is saved.',
          );
          return;
        }
      case PolicyPurchaseIdentityAction.continuePurchase:
        break;
    }
    if (!widget.purchaseController.isIdentityVerified) {
      _show(
        'Complete identity verification before continuing. Your draft is saved.',
      );
      return;
    }
    widget.purchaseController.goTo(PolicyPurchaseStep.application);
  }

  Widget _application(InsuranceProduct product) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
    children: <Widget>[
      CategoryApplicationForm(
        category: product.category,
        onSubmitted: (PolicyApplicationDetails details) async {
          widget.purchaseController.updateApplicationDetails(details);
          if (!widget.purchaseController.validateApplication()) return;
          await widget.purchaseController.saveDraft();
          final PolicyEligibilityResult? eligibility = await widget
              .purchaseController
              .checkEligibility();
          if (eligibility?.decision == EligibilityDecision.eligible) {
            widget.purchaseController.goTo(
              product.requiresBeneficiaries
                  ? PolicyPurchaseStep.beneficiaries
                  : PolicyPurchaseStep.quote,
            );
          }
        },
      ),
      if (widget.purchaseController.eligibilityStatus ==
          EligibilityCheckStatus.checking)
        const Padding(
          padding: EdgeInsets.all(18),
          child: Center(child: CircularProgressIndicator()),
        ),
      if (widget.purchaseController.validationErrors.isNotEmpty)
        _error(widget.purchaseController.validationErrors.values.first),
      if (widget.purchaseController.eligibility != null &&
          widget.purchaseController.eligibility!.decision !=
              EligibilityDecision.eligible)
        _error(
          widget.purchaseController.eligibility!.reason ??
              widget.purchaseController.eligibility!.requiredInformation.join(
                ', ',
              ),
        ),
    ],
  );

  Widget _beneficiaries() => ListView(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
    children: <Widget>[
      BeneficiaryForm(
        onSubmitted: (value) async {
          widget.purchaseController.updateBeneficiaries(value);
          if (!widget.purchaseController.validateBeneficiaries()) return;
          await widget.purchaseController.saveDraft();
          widget.purchaseController.goTo(PolicyPurchaseStep.quote);
        },
      ),
      if (widget.purchaseController.validationErrors.isNotEmpty)
        _error(widget.purchaseController.validationErrors.values.first),
    ],
  );

  Widget _quote(InsuranceProduct product) {
    final PolicyQuote? quote = widget.quoteController.quote;
    if (widget.quoteController.status == PolicyQuoteStatus.idle) {
      return _centerAction(
        icon: Icons.calculate_outlined,
        title: 'Generate Final Quote',
        message:
            'The provider mock backend will calculate the authoritative premium.',
        label: 'Generate Quote',
        onPressed: () => widget.quoteController.generate(
          product: product,
          configuration: widget.purchaseController.configuration!,
        ),
      );
    }
    if (widget.quoteController.status == PolicyQuoteStatus.calculating) {
      return const Center(child: CircularProgressIndicator());
    }
    if (quote == null ||
        widget.quoteController.status == PolicyQuoteStatus.unavailable) {
      return _failure(
        widget.quoteController.errorMessage ?? 'Quote unavailable.',
        () => widget.quoteController.generate(
          product: product,
          configuration: widget.purchaseController.configuration!,
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
      children: <Widget>[
        _QuoteCard(quote: quote),
        const SizedBox(height: 18),
        GlassActionButton(
          label: 'Review Application',
          onPressed: () {
            if (widget.quoteController.ensureCurrent()) {
              widget.purchaseController.goTo(PolicyPurchaseStep.review);
            }
          },
        ),
        TextButton(
          onPressed: () => widget.quoteController.generate(
            product: product,
            configuration: widget.purchaseController.configuration!,
          ),
          child: const Text('Recalculate'),
        ),
      ],
    );
  }

  Widget _review(InsuranceProduct product) {
    final UserProfile profile = widget.purchaseController.profile!;
    final PolicyQuote quote = widget.quoteController.quote!;
    final PolicyApplicationDetails details =
        widget.purchaseController.applicationDetails!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
      children: <Widget>[
        _ReviewCard(
          product: product,
          profile: profile,
          details: details,
          quote: quote,
          beneficiaries: widget.purchaseController.beneficiaries
              .map(
                (value) =>
                    '${value.legalName} (${value.allocationPercentage.toStringAsFixed(0)}%)',
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        _declaration(
          key: 'accurate_declaration',
          value: widget.applicationController.informationAccurate,
          text: 'I confirm the submitted information is accurate.',
          onChanged: (bool value) => widget.applicationController
              .updateDeclarations(informationAccurate: value),
        ),
        _declaration(
          key: 'coverage_declaration',
          value: widget.applicationController.coverageReviewed,
          text: 'I reviewed the coverage, exclusions, premium, and terms.',
          onChanged: (bool value) => widget.applicationController
              .updateDeclarations(coverageReviewed: value),
        ),
        _declaration(
          key: 'processing_declaration',
          value: widget.applicationController.processingConsent,
          text: 'I authorize the provider to process this application.',
          onChanged: (bool value) => widget.applicationController
              .updateDeclarations(processingConsent: value),
        ),
        if (widget.applicationController.errorMessage != null)
          _error(widget.applicationController.errorMessage!),
        const SizedBox(height: 14),
        GlassActionButton(
          key: const Key('submit_policy_application_button'),
          label: 'Submit Application',
          isLoading:
              widget.applicationController.operationStatus ==
              PolicyApplicationOperationStatus.submitting,
          onPressed: !widget.applicationController.declarationsAccepted
              ? null
              : () => _submitApplication(product, profile, details, quote),
        ),
      ],
    );
  }

  Future<void> _submitApplication(
    InsuranceProduct product,
    UserProfile profile,
    PolicyApplicationDetails details,
    PolicyQuote quote,
  ) async {
    if (!widget.quoteController.ensureCurrent()) {
      widget.purchaseController.goTo(PolicyPurchaseStep.quote);
      return;
    }
    final PolicyApplication? application = await widget.applicationController
        .submit(
          PolicyApplicationSubmissionRequest(
            product: product,
            configuration: widget.purchaseController.configuration!,
            details: details,
            beneficiaries: widget.purchaseController.beneficiaries,
            quote: quote,
            applicantId: profile.id,
            applicantName: profile.fullName,
            maskedIdentityNumber: profile.maskedIdentityNumber,
          ),
        );
    if (application?.status == PolicyApplicationStatus.underReview ||
        application?.status ==
            PolicyApplicationStatus.additionalInformationRequired) {
      widget.purchaseController.goTo(PolicyPurchaseStep.providerReview);
    } else if (application?.status == PolicyApplicationStatus.approved) {
      widget.purchaseController.goTo(PolicyPurchaseStep.payment);
    }
  }

  Widget _providerReview() {
    final PolicyApplication application =
        widget.applicationController.application!;
    final bool needsInformation =
        application.status ==
        PolicyApplicationStatus.additionalInformationRequired;
    final bool rejected =
        application.status == PolicyApplicationStatus.rejected;
    return _centerAction(
      icon: Icons.fact_check_outlined,
      title: _applicationStatusLabel(application.status),
      message:
          application.generalReason ??
          'The verified insurance provider is reviewing this application before payment.',
      label: needsInformation
          ? 'Update Application'
          : rejected
          ? 'Contact Support'
          : 'Refresh Status',
      onPressed: () async {
        if (needsInformation) {
          widget.purchaseController.goTo(PolicyPurchaseStep.application);
          return;
        }
        if (rejected) {
          _show(
            'Policy application support will be connected with the provider backend.',
          );
          return;
        }
        final PolicyApplication? updated = await widget.applicationController
            .refreshReview();
        if (updated?.status == PolicyApplicationStatus.approved) {
          widget.purchaseController.goTo(PolicyPurchaseStep.payment);
        }
      },
    );
  }

  Widget _payment() {
    final PolicyQuote quote = widget.quoteController.quote!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
      children: <Widget>[
        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Premium Payment',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                marketplaceMoney(quote.totalPremium),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              RadioGroup<PremiumPaymentMethod>(
                groupValue: widget.paymentController.selectedMethod,
                onChanged: (PremiumPaymentMethod? value) {
                  if (value != null) {
                    widget.paymentController.selectMethod(value);
                  }
                },
                child: Column(
                  children: <Widget>[
                    for (final PremiumPaymentMethod method
                        in PremiumPaymentMethod.values)
                      RadioListTile<PremiumPaymentMethod>(
                        key: ValueKey<String>(
                          'premium_payment_method_${method.name}',
                        ),
                        value: method,
                        title: Text(
                          _paymentMethod(method),
                          style: const TextStyle(color: AppColors.white),
                        ),
                        subtitle: const Text(
                          'Secure provider-hosted integration placeholder',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Text(
                'No PIN, OTP, CVV, password, or provider credentials are collected in this mock flow.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (widget.paymentController.errorMessage != null)
          _error(widget.paymentController.errorMessage!),
        if (widget.paymentController.payment != null &&
            widget.paymentController.payment!.status !=
                PremiumPaymentStatus.paid)
          _notice(
            'Payment status: ${widget.paymentController.payment!.status.name}',
          ),
        const SizedBox(height: 18),
        GlassActionButton(
          key: const Key('pay_premium_button'),
          label: 'Pay Premium',
          isLoading:
              widget.paymentController.operationStatus ==
              PremiumPaymentOperationStatus.processing,
          onPressed: _pay,
        ),
      ],
    );
  }

  Future<void> _pay() async {
    if (!widget.quoteController.ensureCurrent()) {
      widget.purchaseController.goTo(PolicyPurchaseStep.quote);
      return;
    }
    final PolicyApplication application =
        widget.applicationController.application!;
    final PolicyQuote quote = widget.quoteController.quote!;
    final PremiumPayment? payment = await widget.paymentController.pay(
      applicationId: application.id,
      quoteId: quote.id,
      amount: quote.totalPremium,
    );
    if (payment?.status == PremiumPaymentStatus.paid) {
      await widget.purchaseController.issuePolicy(
        application: application,
        payment: payment!,
        quote: quote,
      );
    }
  }

  Widget _issuing() {
    if (widget.purchaseController.issuanceStatus ==
        PolicyIssuanceStatus.failure) {
      return _failure(
        widget.purchaseController.errorMessage ?? 'Policy issuance failed.',
        _pay,
      );
    }
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Issuing your policy securely…',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _success() {
    final PolicyIssuanceResult issuance =
        widget.purchaseController.issuanceResult!;
    final InsurancePolicy policy = issuance.policy;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
      children: <Widget>[
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF49E6A4),
          size: 72,
        ),
        const SizedBox(height: 16),
        const Text(
          'Policy Purchased Successfully',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: <Widget>[
              _row('Policy number', policy.policyNumber),
              _row('Provider', policy.providerName ?? 'Insurance provider'),
              _row(
                'Status',
                policy.status == PolicyStatus.active ? 'Active' : 'Pending',
              ),
              _row('Coverage start', _date(policy.startDate!)),
              _row('Expiry date', _date(policy.validTill)),
              _row('Blockchain record', issuance.blockchainRecordStatus),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GlassActionButton(
          label: 'View Policy',
          onPressed: () => widget.onViewPolicy(policy),
        ),
        const SizedBox(height: 10),
        GlassActionButton(
          label: 'View Payment Receipt',
          variant: GlassButtonVariant.secondary,
          onPressed: () =>
              widget.onViewPaymentReceipt(widget.paymentController.payment!),
        ),
        TextButton.icon(
          onPressed: widget.onDownloadDocument,
          icon: const Icon(Icons.download_outlined),
          label: const Text('Download Policy Document'),
        ),
        TextButton(
          onPressed: widget.onMyPolicies,
          child: const Text('Return to My Policies'),
        ),
        TextButton(
          onPressed: widget.onDashboard,
          child: const Text('Return to Dashboard'),
        ),
      ],
    );
  }

  Widget _declaration({
    required String key,
    required bool value,
    required String text,
    required ValueChanged<bool> onChanged,
  }) => CheckboxListTile(
    key: Key(key),
    contentPadding: EdgeInsets.zero,
    value: value,
    onChanged: (bool? selected) => onChanged(selected ?? false),
    title: Text(
      text,
      style: const TextStyle(color: AppColors.white, fontSize: 12),
    ),
    controlAffinity: ListTileControlAffinity.leading,
  );

  Widget _centerAction({
    required IconData icon,
    required String title,
    required String message,
    required String label,
    required VoidCallback onPressed,
  }) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Icon(icon, color: AppColors.blue, size: 55),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 22),
          GlassActionButton(label: label, onPressed: onPressed),
        ],
      ),
    ),
  );

  Widget _failure(String message, VoidCallback onRetry) => _centerAction(
    icon: Icons.error_outline_rounded,
    title: 'Unable to Continue',
    message: message,
    label: 'Try Again',
    onPressed: onRetry,
  );
  Widget _error(String message) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFFFFB3BE)),
    ),
  );
  Widget _notice(String message) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFF49E6A4), fontSize: 11),
    ),
  );
  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  void _back() {
    final PolicyPurchaseStep step = widget.purchaseController.step;
    if (step == PolicyPurchaseStep.configure ||
        step == PolicyPurchaseStep.success) {
      widget.onBack();
      return;
    }
    final PolicyPurchaseStep previous = switch (step) {
      PolicyPurchaseStep.application => PolicyPurchaseStep.configure,
      PolicyPurchaseStep.beneficiaries => PolicyPurchaseStep.application,
      PolicyPurchaseStep.quote =>
        widget.purchaseController.product!.requiresBeneficiaries
            ? PolicyPurchaseStep.beneficiaries
            : PolicyPurchaseStep.application,
      PolicyPurchaseStep.review => PolicyPurchaseStep.quote,
      PolicyPurchaseStep.providerReview => PolicyPurchaseStep.review,
      PolicyPurchaseStep.payment => PolicyPurchaseStep.review,
      PolicyPurchaseStep.issuing => PolicyPurchaseStep.payment,
      PolicyPurchaseStep.configure ||
      PolicyPurchaseStep.success => PolicyPurchaseStep.configure,
    };
    widget.purchaseController.goTo(previous);
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});
  final PolicyQuote quote;
  @override
  Widget build(BuildContext context) => GlassContainer(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          quote.id,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 6),
        Text(
          quote.productName,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 15),
        _row('Provider', quote.providerName),
        _row('Coverage', marketplaceMoney(quote.configuration.coverageAmount)),
        _row('Duration', '${quote.configuration.durationMonths} months'),
        _row('Deductible', marketplaceMoney(quote.configuration.deductible)),
        _row(
          'Add-ons',
          quote.configuration.addOns.isEmpty
              ? 'None'
              : quote.configuration.addOns.join(', '),
        ),
        const Divider(),
        _row('Base premium', marketplaceMoney(quote.basePremium)),
        _row('Taxes', marketplaceMoney(quote.taxes)),
        _row('Fees', marketplaceMoney(quote.fees)),
        _row('Discounts', '-${marketplaceMoney(quote.discounts)}'),
        _row('Total premium', marketplaceMoney(quote.totalPremium)),
        _row('Effective date', _date(quote.effectiveDate)),
        _row('Quote expires', _dateTime(quote.expiresAt)),
      ],
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.product,
    required this.profile,
    required this.details,
    required this.quote,
    required this.beneficiaries,
  });
  final InsuranceProduct product;
  final UserProfile profile;
  final PolicyApplicationDetails details;
  final PolicyQuote quote;
  final List<String> beneficiaries;
  @override
  Widget build(BuildContext context) => GlassContainer(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'Application Review',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        _row('Provider', product.providerName),
        _row('Product', product.name),
        _row('Verified applicant', profile.fullName),
        _row('CNIC', profile.maskedIdentityNumber),
        for (final MapEntry<String, String> value in details.summary.entries)
          _row(value.key, value.value),
        if (beneficiaries.isNotEmpty)
          _row('Beneficiaries', beneficiaries.join(', ')),
        _row('Coverage', marketplaceMoney(quote.configuration.coverageAmount)),
        _row(
          'Add-ons',
          quote.configuration.addOns.isEmpty
              ? 'None'
              : quote.configuration.addOns.join(', '),
        ),
        _row('Premium', marketplaceMoney(quote.totalPremium)),
        _row('Effective date', _date(quote.effectiveDate)),
        _row('Exclusions', product.exclusions.join(', ')),
        _row('Terms', product.termsSummary),
      ],
    ),
  );
}

Widget _row(String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
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

String _title(PolicyPurchaseStep step) => switch (step) {
  PolicyPurchaseStep.configure => 'Configure Coverage',
  PolicyPurchaseStep.application => 'Policy Application',
  PolicyPurchaseStep.beneficiaries => 'Beneficiaries',
  PolicyPurchaseStep.quote => 'Final Quote',
  PolicyPurchaseStep.review => 'Review Application',
  PolicyPurchaseStep.providerReview => 'Provider Review',
  PolicyPurchaseStep.payment => 'Premium Payment',
  PolicyPurchaseStep.issuing => 'Policy Issuance',
  PolicyPurchaseStep.success => 'Purchase Confirmation',
};

String _paymentMethod(PremiumPaymentMethod value) => switch (value) {
  PremiumPaymentMethod.bankTransfer => 'Bank Transfer',
  PremiumPaymentMethod.easypaisa => 'Easypaisa',
  PremiumPaymentMethod.jazzCash => 'JazzCash',
};

String _applicationStatusLabel(PolicyApplicationStatus status) =>
    switch (status) {
      PolicyApplicationStatus.underReview => 'Application Under Review',
      PolicyApplicationStatus.additionalInformationRequired =>
        'Additional Information Required',
      PolicyApplicationStatus.approved => 'Application Approved',
      PolicyApplicationStatus.rejected => 'Application Not Approved',
      _ => 'Application Submitted',
    };

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
String _dateTime(DateTime value) =>
    '${_date(value)} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
