import '../../domain/entities/ai_verification_result.dart';
import '../../domain/entities/blockchain_claim_record.dart';
import '../../domain/entities/claim_payment.dart';
import '../../domain/entities/claim_submission_result.dart';
import '../../domain/entities/fraud_risk_level.dart';
import '../../domain/entities/incident_details.dart';

abstract final class ClaimFormatters {
  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String date(DateTime value) {
    return '${value.day} ${_months[value.month - 1]} ${value.year}';
  }

  static String time(DateTime value) {
    final int hour = value.hour == 0
        ? 12
        : (value.hour > 12 ? value.hour - 12 : value.hour);
    final String minute = value.minute.toString().padLeft(2, '0');
    final String suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  static String dateTime(DateTime value) => '${date(value)}, ${time(value)}';

  static String amount(double value) {
    final String whole = value.toStringAsFixed(0);
    final String grouped = whole.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
    return 'Rs. $grouped';
  }

  static String fileSize(int bytes) {
    final double megabytes = bytes / (1024 * 1024);
    return '${megabytes.toStringAsFixed(1)} MB';
  }

  static String incidentType(IncidentType type) {
    switch (type) {
      case IncidentType.collision:
        return 'Vehicle collision';
      case IncidentType.theft:
        return 'Theft';
      case IncidentType.vehicleDamage:
        return 'Vehicle damage';
      case IncidentType.medicalEmergency:
        return 'Medical emergency';
      case IncidentType.hospitalization:
        return 'Hospitalization';
      case IncidentType.baggageLoss:
        return 'Baggage loss';
      case IncidentType.tripCancellation:
        return 'Trip cancellation';
      case IncidentType.other:
        return 'Other';
    }
  }

  static String evidenceClassification(EvidenceClassification value) {
    switch (value) {
      case EvidenceClassification.authentic:
        return 'Verification completed';
      case EvidenceClassification.manipulated:
      case EvidenceClassification.aiGenerated:
        return 'Submitted for manual review';
      case EvidenceClassification.inconclusive:
        return 'Additional evidence required';
    }
  }

  static String claimStatus(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.aiAnalysisPending:
        return 'AI Analysis Pending';
      case ClaimStatus.aiAnalysisCompleted:
        return 'AI Analysis Completed';
      case ClaimStatus.underReview:
        return 'Under Review';
      case ClaimStatus.additionalEvidenceRequired:
        return 'Evidence Required';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.paymentProcessing:
        return 'Payment Processing';
      case ClaimStatus.settled:
        return 'Settled';
    }
  }

  static String aiAnalysisStatus(AiAnalysisStatus status) {
    switch (status) {
      case AiAnalysisStatus.pending:
        return 'Pending';
      case AiAnalysisStatus.analysing:
        return 'Analysing';
      case AiAnalysisStatus.completed:
        return 'Completed';
      case AiAnalysisStatus.failed:
        return 'Needs attention';
    }
  }

  static String fraudRiskLevel(FraudRiskLevel riskLevel) {
    switch (riskLevel) {
      case FraudRiskLevel.pending:
        return 'Analysis Pending';
      case FraudRiskLevel.low:
        return 'Low Risk';
      case FraudRiskLevel.medium:
        return 'Medium Risk';
      case FraudRiskLevel.high:
        return 'High Risk';
    }
  }

  static String paymentStatus(ClaimPaymentStatus status) {
    switch (status) {
      case ClaimPaymentStatus.notStarted:
        return 'Not Started';
      case ClaimPaymentStatus.processing:
        return 'Processing';
      case ClaimPaymentStatus.paid:
        return 'Paid';
      case ClaimPaymentStatus.failed:
        return 'Needs Attention';
    }
  }

  static String blockchainStatus(BlockchainRecordStatus status) {
    switch (status) {
      case BlockchainRecordStatus.pendingIntegration:
        return 'Pending Integration';
      case BlockchainRecordStatus.verificationPending:
        return 'Verification Pending';
      case BlockchainRecordStatus.secured:
        return 'Secured';
      case BlockchainRecordStatus.failed:
        return 'Needs Attention';
    }
  }
}
