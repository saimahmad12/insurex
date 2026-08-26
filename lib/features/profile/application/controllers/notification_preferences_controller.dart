import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_preferences_repository.dart';

enum NotificationPreferencesLoadStatus { initial, loading, success, failure }

enum NotificationPreferenceUpdateStatus { idle, saving, failure }

class NotificationPreferencesController extends ChangeNotifier {
  NotificationPreferencesController({
    required NotificationPreferencesRepository repository,
  }) : _repository = repository;

  final NotificationPreferencesRepository _repository;
  NotificationPreferencesLoadStatus _loadStatus =
      NotificationPreferencesLoadStatus.initial;
  NotificationPreferenceUpdateStatus _updateStatus =
      NotificationPreferenceUpdateStatus.idle;
  NotificationPreferences? _preferences;
  NotificationPreference? _savingPreference;
  String? _errorMessage;
  String? _updateErrorMessage;
  bool _initialized = false;
  bool _loadInProgress = false;
  bool _updateInProgress = false;
  bool _disposed = false;

  NotificationPreferencesLoadStatus get loadStatus => _loadStatus;
  NotificationPreferenceUpdateStatus get updateStatus => _updateStatus;
  NotificationPreferences? get preferences => _preferences;
  NotificationPreference? get savingPreference => _savingPreference;
  String? get errorMessage => _errorMessage;
  String? get updateErrorMessage => _updateErrorMessage;
  bool get isLoading =>
      _loadStatus == NotificationPreferencesLoadStatus.loading &&
      _preferences == null;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _load();
  }

  Future<void> retry() => _load();

  bool isSaving(NotificationPreference preference) {
    return _updateStatus == NotificationPreferenceUpdateStatus.saving &&
        _savingPreference == preference;
  }

  Future<bool> updatePreference(
    NotificationPreference preference,
    bool enabled,
  ) async {
    final NotificationPreferences? current = _preferences;
    if (current == null ||
        current.valueFor(preference) == enabled ||
        _updateInProgress) {
      return false;
    }
    _updateInProgress = true;
    _updateStatus = NotificationPreferenceUpdateStatus.saving;
    _savingPreference = preference;
    _updateErrorMessage = null;
    final NotificationPreferences proposed = current.withPreference(
      preference,
      enabled,
    );
    _preferences = proposed;
    _notify();
    try {
      _preferences = await _repository.updatePreferences(proposed);
      _updateStatus = NotificationPreferenceUpdateStatus.idle;
      return true;
    } catch (_) {
      _preferences = current;
      _updateStatus = NotificationPreferenceUpdateStatus.failure;
      _updateErrorMessage =
          'Unable to save this preference. Your previous setting was restored.';
      return false;
    } finally {
      _savingPreference = null;
      _updateInProgress = false;
      _notify();
    }
  }

  Future<void> _load() async {
    if (_loadInProgress) {
      return;
    }
    _loadInProgress = true;
    _loadStatus = NotificationPreferencesLoadStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      _preferences = await _repository.getPreferences();
      _loadStatus = NotificationPreferencesLoadStatus.success;
    } catch (_) {
      _loadStatus = NotificationPreferencesLoadStatus.failure;
      _errorMessage = 'Unable to load notification settings.';
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
