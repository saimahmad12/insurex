import 'package:flutter/foundation.dart';

import '../../domain/entities/identity_verification.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_session_repository.dart';
import '../../domain/repositories/profile_repository.dart';

enum ProfileLoadStatus { initial, loading, success, empty, failure }

enum ProfileRefreshStatus { idle, refreshing, failure }

enum LogoutStatus { idle, loggingOut, success, failure }

class ProfileController extends ChangeNotifier {
  ProfileController({
    required ProfileRepository profileRepository,
    required AuthSessionRepository authSessionRepository,
  }) : _profileRepository = profileRepository,
       _authSessionRepository = authSessionRepository;

  final ProfileRepository _profileRepository;
  final AuthSessionRepository _authSessionRepository;

  ProfileLoadStatus _loadStatus = ProfileLoadStatus.initial;
  ProfileRefreshStatus _refreshStatus = ProfileRefreshStatus.idle;
  LogoutStatus _logoutStatus = LogoutStatus.idle;
  UserProfile? _profile;
  String? _errorMessage;
  String? _refreshErrorMessage;
  String? _logoutErrorMessage;
  bool _initialized = false;
  bool _profileRequestInProgress = false;
  bool _logoutInProgress = false;
  bool _disposed = false;

  ProfileLoadStatus get loadStatus => _loadStatus;
  ProfileRefreshStatus get refreshStatus => _refreshStatus;
  LogoutStatus get logoutStatus => _logoutStatus;
  UserProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  String? get refreshErrorMessage => _refreshErrorMessage;
  String? get logoutErrorMessage => _logoutErrorMessage;
  bool get isInitialLoading =>
      _loadStatus == ProfileLoadStatus.loading && _profile == null;
  bool get isRefreshing => _refreshStatus == ProfileRefreshStatus.refreshing;
  bool get isLoggingOut => _logoutStatus == LogoutStatus.loggingOut;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _loadInitial();
  }

  Future<void> retry() => _loadInitial();

  Future<void> refresh() async {
    if (_profileRequestInProgress) {
      return;
    }
    _profileRequestInProgress = true;
    _refreshStatus = ProfileRefreshStatus.refreshing;
    _refreshErrorMessage = null;
    _notify();
    try {
      final UserProfile? refreshed = await _profileRepository.refreshProfile();
      if (refreshed == null) {
        _refreshStatus = ProfileRefreshStatus.failure;
        _refreshErrorMessage = 'The latest profile is unavailable.';
      } else {
        _profile = refreshed;
        _loadStatus = ProfileLoadStatus.success;
        _refreshStatus = ProfileRefreshStatus.idle;
      }
    } catch (_) {
      _refreshStatus = ProfileRefreshStatus.failure;
      _refreshErrorMessage =
          'Unable to refresh your profile. Existing information is shown.';
    } finally {
      _profileRequestInProgress = false;
      _notify();
    }
  }

  void applyUpdatedProfile(UserProfile profile) {
    _profile = profile;
    _loadStatus = ProfileLoadStatus.success;
    _notify();
  }

  void applyIdentityVerification(IdentityVerification verification) {
    final UserProfile? current = _profile;
    if (current == null) {
      return;
    }
    _profile = current.copyWith(identityVerification: verification);
    _notify();
  }

  Future<bool> logout() async {
    if (_logoutInProgress) {
      return false;
    }
    _logoutInProgress = true;
    _logoutStatus = LogoutStatus.loggingOut;
    _logoutErrorMessage = null;
    _notify();
    try {
      await _authSessionRepository.logout();
      _logoutStatus = LogoutStatus.success;
      return true;
    } catch (_) {
      _logoutStatus = LogoutStatus.failure;
      _logoutErrorMessage = 'Unable to log out. Please try again.';
      return false;
    } finally {
      _logoutInProgress = false;
      _notify();
    }
  }

  Future<void> _loadInitial() async {
    if (_profileRequestInProgress) {
      return;
    }
    _profileRequestInProgress = true;
    _loadStatus = ProfileLoadStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      _profile = await _profileRepository.getProfile();
      _loadStatus = _profile == null
          ? ProfileLoadStatus.empty
          : ProfileLoadStatus.success;
    } catch (_) {
      _loadStatus = ProfileLoadStatus.failure;
      _errorMessage = 'Unable to load your profile. Please try again.';
    } finally {
      _profileRequestInProgress = false;
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
