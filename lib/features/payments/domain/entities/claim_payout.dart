import '../../../claims/domain/entities/blockchain_claim_record.dart';
import '../../../claims/domain/entities/claim_payment.dart';
import '../../../claims/domain/entities/claim_submission_result.dart';
import '../../../claims/domain/entities/insurance_claim.dart';
import 'payout_method.dart';

enum ClaimPayoutStatus {
  notAvailable,
  actionRequired,
  verificationPending,
  ready,
  processing,
  paid,
  failed,
  reversed,
}

class ClaimPayout {
  const ClaimPayout({
    required this.id,
    required this.claimId,
    required this.policyName,
    required this.amount,
    required this.status,
    required this.method,
    required this.idempotencyKey,
    required this.requestedAt,
    this.reference,
    this.processingAt,
    this.paidAt,
    this.failureMessage,
    this.blockchainRecord,
  });

  final String id;
  final String claimId;
  final String policyName;
  final double amount;
  final ClaimPayoutStatus status;
  final PayoutMethod method;
  final String idempotencyKey;
  final String? reference;
  final DateTime requestedAt;
  final DateTime? processingAt;
  final DateTime? paidAt;
  final String? failureMessage;
  final BlockchainClaimRecord? blockchainRecord;

  bool get isTerminal =>
      status == ClaimPayoutStatus.paid || status == ClaimPayoutStatus.reversed;

  ClaimPayout copyWith({
    ClaimPayoutStatus? status,
    String? reference,
    DateTime? processingAt,
    DateTime? paidAt,
    String? failureMessage,
    bool clearFailureMessage = false,
    BlockchainClaimRecord? blockchainRecord,
  }) {
    return ClaimPayout(
      id: id,
      claimId: claimId,
      policyName: policyName,
      amount: amount,
      status: status ?? this.status,
      method: method,
      idempotencyKey: idempotencyKey,
      reference: reference ?? this.reference,
      requestedAt: requestedAt,
      processingAt: processingAt ?? this.processingAt,
      paidAt: paidAt ?? this.paidAt,
      failureMessage: clearFailureMessage
          ? null
          : failureMessage ?? this.failureMessage,
      blockchainRecord: blockchainRecord ?? this.blockchainRecord,
    );
  }

  ClaimPayment toClaimPayment() {
    return ClaimPayment(
      status: switch (status) {
        ClaimPayoutStatus.notAvailable ||
        ClaimPayoutStatus.actionRequired => ClaimPaymentStatus.notStarted,
        ClaimPayoutStatus.verificationPending =>
          ClaimPaymentStatus.verificationPending,
        ClaimPayoutStatus.ready => ClaimPaymentStatus.ready,
        ClaimPayoutStatus.processing => ClaimPaymentStatus.processing,
        ClaimPayoutStatus.paid => ClaimPaymentStatus.paid,
        ClaimPayoutStatus.failed => ClaimPaymentStatus.failed,
        ClaimPayoutStatus.reversed => ClaimPaymentStatus.reversed,
      },
      amount: amount,
      method: method.displayName,
      maskedDestination: method.maskedAccount,
      transactionReference: reference,
      requestedAt: requestedAt,
      processingAt: processingAt,
      paidAt: paidAt,
      failureMessage: failureMessage,
    );
  }
}

bool isClaimEligibleForPayout(InsuranceClaim claim) {
  return claim.belongsToCurrentUser &&
      claim.status == ClaimStatus.approved &&
      (claim.approvedAmount ?? 0) > 0 &&
      claim.payment?.status != ClaimPaymentStatus.processing &&
      claim.payment?.status != ClaimPaymentStatus.paid &&
      claim.payment?.status != ClaimPaymentStatus.reversed;
}
