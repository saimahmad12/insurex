import 'package:flutter/foundation.dart';

import '../../domain/entities/profile_field_permissions.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../validators/profile_validator.dart';

enum EditProfileSaveStatus { idle, saving, success, failure }

class EditProfileController extends ChangeNotifier {
  EditProfileController({
    required ProfileRepository repository,
    required this.originalProfile,
  }) : _repository = repository;

  final ProfileRepository _repository;
  final UserProfile originalProfile;

  EditProfileSaveStatus _saveStatus = EditProfileSaveStatus.idle;
  UserProfile? _updatedProfile;
  String? _errorMessage;
  Map<String, String> _validationErrors = const <String, String>{};
  bool _saveInProgress = false;
  bool _disposed = false;

  EditProfileSaveStatus get saveStatus => _saveStatus;
  UserProfile? get updatedProfile => _updatedProfile;
  String? get errorMessage => _errorMessage;
  Map<String, String> get validationErrors => _validationErrors;
  bool get isSaving => _saveStatus == EditProfileSaveStatus.saving;
  ProfileFieldPermissions get fieldPermissions =>
      ProfileFieldPermissions.forVerificationStatus(
        originalProfile.identityVerification.status,
      );

  Future<UserProfile?> save(ProfileUpdateRequest request) async {
    if (_saveInProgress) {
      return null;
    }
    if (!_canApply(request)) {
      _validationErrors = const <String, String>{
        'legalIdentity':
            'Verified identity information cannot be edited directly.',
      };
      _saveStatus = EditProfileSaveStatus.failure;
      _errorMessage = _validationErrors.values.first;
      _notify();
      return null;
    }
    final Map<String, String> errors = ProfileValidator.validate(request);
    if (errors.isNotEmpty) {
      _validationErrors = Map<String, String>.unmodifiable(errors);
      _saveStatus = EditProfileSaveStatus.failure;
      _errorMessage = errors.values.first;
      _notify();
      return null;
    }

    _saveInProgress = true;
    _saveStatus = EditProfileSaveStatus.saving;
    _validationErrors = const <String, String>{};
    _errorMessage = null;
    _notify();
    try {
      final UserProfile updated = await _repository.updateProfile(request);
      _updatedProfile = updated;
      _saveStatus = EditProfileSaveStatus.success;
      return updated;
    } catch (_) {
      _updatedProfile = null;
      _saveStatus = EditProfileSaveStatus.failure;
      _errorMessage =
          'Unable to save your profile. Your original details remain unchanged.';
      return null;
    } finally {
      _saveInProgress = false;
      _notify();
    }
  }

  bool _canApply(ProfileUpdateRequest request) {
    final ProfileFieldPermissions permissions = fieldPermissions;
    if (request.fullName != null && !permissions.canEditLegalName) {
      return false;
    }
    if (request.dateOfBirth != null && !permissions.canEditDateOfBirth) {
      return false;
    }
    if (request.gender != null && !permissions.canEditGender) {
      return false;
    }
    return permissions.canEditAddress;
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
