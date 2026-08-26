import 'package:flutter/foundation.dart';

import '../../domain/entities/security_settings.dart';
import '../../domain/repositories/auth_session_repository.dart';
import '../../domain/repositories/security_repository.dart';
import '../validators/password_validator.dart';

enum SecurityLoadStatus { initial, loading, success, failure }

enum SecuritySettingUpdateStatus { idle, saving, failure }

enum PasswordChangeStatus { idle, saving, success, failure }

enum SecurityLogoutStatus { idle, loggingOut, success, failure }

class SecuritySettingsController extends ChangeNotifier {
  SecuritySettingsController({
    required SecurityRepository repository,
    required AuthSessionRepository authSessionRepository,
  }) : _repository = repository,
       _authSessionRepository = authSessionRepository;

  final SecurityRepository _repository;
  final AuthSessionRepository _authSessionRepository;
  SecurityLoadStatus _loadStatus = SecurityLoadStatus.initial;
  SecuritySettingUpdateStatus _settingUpdateStatus =
      SecuritySettingUpdateStatus.idle;
  PasswordChangeStatus _passwordChangeStatus = PasswordChangeStatus.idle;
  SecurityLogoutStatus _logoutStatus = SecurityLogoutStatus.idle;
  SecuritySettings? _settings;
  String? _errorMessage;
  String? _settingErrorMessage;
  String? _passwordErrorMessage;
  String? _logoutErrorMessage;
  Map<String, String> _passwordValidationErrors = const <String, String>{};
  bool _initialized = false;
  bool _loadInProgress = false;
  bool _settingUpdateInProgress = false;
  bool _passwordChangeInProgress = false;
  bool _logoutInProgress = false;
  bool _disposed = false;

  SecurityLoadStatus get loadStatus => _loadStatus;
  SecuritySettingUpdateStatus get settingUpdateStatus => _settingUpdateStatus;
  PasswordChangeStatus get passwordChangeStatus => _passwordChangeStatus;
  SecurityLogoutStatus get logoutStatus => _logoutStatus;
  SecuritySettings? get settings => _settings;
  String? get errorMessage => _errorMessage;
  String? get settingErrorMessage => _settingErrorMessage;
  String? get passwordErrorMessage => _passwordErrorMessage;
  String? get logoutErrorMessage => _logoutErrorMessage;
  Map<String, String> get passwordValidationErrors => _passwordValidationErrors;
  bool get isLoading =>
      _loadStatus == SecurityLoadStatus.loading && _settings == null;
  bool get isUpdatingSetting =>
      _settingUpdateStatus == SecuritySettingUpdateStatus.saving;
  bool get isChangingPassword =>
      _passwordChangeStatus == PasswordChangeStatus.saving;
  bool get isLoggingOut => _logoutStatus == SecurityLogoutStatus.loggingOut;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _load();
  }

  Future<void> retry() => _load();

  Future<bool> updateBiometricLogin(bool enabled) async {
    final SecuritySettings? current = _settings;
    if (current == null ||
        current.biometricLoginEnabled == enabled ||
        _settingUpdateInProgress) {
      return false;
    }
    _settingUpdateInProgress = true;
    _settingUpdateStatus = SecuritySettingUpdateStatus.saving;
    _settingErrorMessage = null;
    final SecuritySettings proposed = current.copyWith(
      biometricLoginEnabled: enabled,
    );
    _settings = proposed;
    _notify();
    try {
      _settings = await _repository.updateSecuritySettings(proposed);
      _settingUpdateStatus = SecuritySettingUpdateStatus.idle;
      return true;
    } catch (_) {
      _settings = current;
      _settingUpdateStatus = SecuritySettingUpdateStatus.failure;
      _settingErrorMessage =
          'Unable to update biometric login. Your previous setting was restored.';
      return false;
    } finally {
      _settingUpdateInProgress = false;
      _notify();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_passwordChangeInProgress) {
      return false;
    }
    final Map<String, String> errors = PasswordValidator.validate(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    if (errors.isNotEmpty) {
      _passwordValidationErrors = Map<String, String>.unmodifiable(errors);
      _passwordChangeStatus = PasswordChangeStatus.failure;
      _passwordErrorMessage = errors.values.first;
      _notify();
      return false;
    }

    _passwordChangeInProgress = true;
    _passwordChangeStatus = PasswordChangeStatus.saving;
    _passwordValidationErrors = const <String, String>{};
    _passwordErrorMessage = null;
    _notify();
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _passwordChangeStatus = PasswordChangeStatus.success;
      return true;
    } catch (_) {
      _passwordChangeStatus = PasswordChangeStatus.failure;
      _passwordErrorMessage =
          'Unable to change your password. Please verify your current password.';
      return false;
    } finally {
      _passwordChangeInProgress = false;
      _notify();
    }
  }

  void resetPasswordOperation() {
    _passwordChangeStatus = PasswordChangeStatus.idle;
    _passwordErrorMessage = null;
    _passwordValidationErrors = const <String, String>{};
    _notify();
  }

  Future<bool> logout() async {
    if (_logoutInProgress) {
      return false;
    }
    _logoutInProgress = true;
    _logoutStatus = SecurityLogoutStatus.loggingOut;
    _logoutErrorMessage = null;
    _notify();
    try {
      await _authSessionRepository.logout();
      _logoutStatus = SecurityLogoutStatus.success;
      return true;
    } catch (_) {
      _logoutStatus = SecurityLogoutStatus.failure;
      _logoutErrorMessage = 'Unable to log out. Please try again.';
      return false;
    } finally {
      _logoutInProgress = false;
      _notify();
    }
  }

  Future<void> _load() async {
    if (_loadInProgress) {
      return;
    }
    _loadInProgress = true;
    _loadStatus = SecurityLoadStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      _settings = await _repository.getSecuritySettings();
      _loadStatus = SecurityLoadStatus.success;
    } catch (_) {
      _loadStatus = SecurityLoadStatus.failure;
      _errorMessage = 'Unable to load security settings.';
    } finally {
      _loadInProgress = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
