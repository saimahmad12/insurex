class SecuritySettings {
  const SecuritySettings({
    required this.biometricLoginEnabled,
    required this.twoFactorAuthenticationAvailable,
    required this.twoFactorAuthenticationEnabled,
    required this.activeSessionDescription,
  });

  final bool biometricLoginEnabled;
  final bool twoFactorAuthenticationAvailable;
  final bool twoFactorAuthenticationEnabled;
  final String activeSessionDescription;

  SecuritySettings copyWith({
    bool? biometricLoginEnabled,
    bool? twoFactorAuthenticationAvailable,
    bool? twoFactorAuthenticationEnabled,
    String? activeSessionDescription,
  }) {
    return SecuritySettings(
      biometricLoginEnabled:
          biometricLoginEnabled ?? this.biometricLoginEnabled,
      twoFactorAuthenticationAvailable:
          twoFactorAuthenticationAvailable ??
          this.twoFactorAuthenticationAvailable,
      twoFactorAuthenticationEnabled:
          twoFactorAuthenticationEnabled ?? this.twoFactorAuthenticationEnabled,
      activeSessionDescription:
          activeSessionDescription ?? this.activeSessionDescription,
    );
  }
}
