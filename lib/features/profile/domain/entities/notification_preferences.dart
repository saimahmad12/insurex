enum NotificationPreference {
  claimStatusUpdates,
  aiAnalysisCompletion,
  additionalEvidenceRequests,
  claimDecisions,
  paymentUpdates,
  policyExpiryReminders,
  securityAlerts,
  promotionalNotifications,
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.claimStatusUpdates,
    required this.aiAnalysisCompletion,
    required this.additionalEvidenceRequests,
    required this.claimDecisions,
    required this.paymentUpdates,
    required this.policyExpiryReminders,
    required this.securityAlerts,
    required this.promotionalNotifications,
  });

  final bool claimStatusUpdates;
  final bool aiAnalysisCompletion;
  final bool additionalEvidenceRequests;
  final bool claimDecisions;
  final bool paymentUpdates;
  final bool policyExpiryReminders;
  final bool securityAlerts;
  final bool promotionalNotifications;

  bool valueFor(NotificationPreference preference) {
    return switch (preference) {
      NotificationPreference.claimStatusUpdates => claimStatusUpdates,
      NotificationPreference.aiAnalysisCompletion => aiAnalysisCompletion,
      NotificationPreference.additionalEvidenceRequests =>
        additionalEvidenceRequests,
      NotificationPreference.claimDecisions => claimDecisions,
      NotificationPreference.paymentUpdates => paymentUpdates,
      NotificationPreference.policyExpiryReminders => policyExpiryReminders,
      NotificationPreference.securityAlerts => securityAlerts,
      NotificationPreference.promotionalNotifications =>
        promotionalNotifications,
    };
  }

  NotificationPreferences withPreference(
    NotificationPreference preference,
    bool value,
  ) {
    return NotificationPreferences(
      claimStatusUpdates:
          preference == NotificationPreference.claimStatusUpdates
          ? value
          : claimStatusUpdates,
      aiAnalysisCompletion:
          preference == NotificationPreference.aiAnalysisCompletion
          ? value
          : aiAnalysisCompletion,
      additionalEvidenceRequests:
          preference == NotificationPreference.additionalEvidenceRequests
          ? value
          : additionalEvidenceRequests,
      claimDecisions: preference == NotificationPreference.claimDecisions
          ? value
          : claimDecisions,
      paymentUpdates: preference == NotificationPreference.paymentUpdates
          ? value
          : paymentUpdates,
      policyExpiryReminders:
          preference == NotificationPreference.policyExpiryReminders
          ? value
          : policyExpiryReminders,
      securityAlerts: preference == NotificationPreference.securityAlerts
          ? value
          : securityAlerts,
      promotionalNotifications:
          preference == NotificationPreference.promotionalNotifications
          ? value
          : promotionalNotifications,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationPreferences &&
        other.claimStatusUpdates == claimStatusUpdates &&
        other.aiAnalysisCompletion == aiAnalysisCompletion &&
        other.additionalEvidenceRequests == additionalEvidenceRequests &&
        other.claimDecisions == claimDecisions &&
        other.paymentUpdates == paymentUpdates &&
        other.policyExpiryReminders == policyExpiryReminders &&
        other.securityAlerts == securityAlerts &&
        other.promotionalNotifications == promotionalNotifications;
  }

  @override
  int get hashCode => Object.hash(
    claimStatusUpdates,
    aiAnalysisCompletion,
    additionalEvidenceRequests,
    claimDecisions,
    paymentUpdates,
    policyExpiryReminders,
    securityAlerts,
    promotionalNotifications,
  );
}
