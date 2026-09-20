import 'package:flutter/foundation.dart';

import '../../domain/entities/seller_registration.dart';
import '../../domain/repositories/seller_registration_repository.dart';
import '../validators/seller_auth_validator.dart';

class SellerRegistrationController extends ChangeNotifier {
  SellerRegistrationController({
    required SellerRegistrationRepository repository,
    required SellerAuthValidator validator,
  }) : _repository = repository,
       _validator = validator;

  final SellerRegistrationRepository _repository;
  final SellerAuthValidator _validator;

  SellerRegistrationStatus _status = SellerRegistrationStatus.draft;
  RepresentativeDesignation? _designation;
  final Set<InsuranceCategory> _selectedCategories = <InsuranceCategory>{};
  Map<SellerRegistrationField, String> _fieldErrors =
      <SellerRegistrationField, String>{};
  bool _acceptedTerms = false;
  bool _confirmedDeclarations = false;
  String? _errorMessage;
  SellerRegistrationResult? _result;

  SellerRegistrationStatus get status => _status;
  RepresentativeDesignation? get designation => _designation;
  Set<InsuranceCategory> get selectedCategories =>
      Set<InsuranceCategory>.unmodifiable(_selectedCategories);
  bool get acceptedTerms => _acceptedTerms;
  bool get confirmedDeclarations => _confirmedDeclarations;
  String? get errorMessage => _errorMessage;
  SellerRegistrationResult? get result => _result;
  bool get isSubmitting => _status == SellerRegistrationStatus.submitting;

  String? errorFor(SellerRegistrationField field) => _fieldErrors[field];

  void selectDesignation(RepresentativeDesignation? designation) {
    if (_designation == designation || isSubmitting) {
      return;
    }
    _designation = designation;
    _clearFieldError(
      SellerRegistrationField.authorizedRepresentativeDesignation,
    );
    _notify();
  }

  void toggleCategory(InsuranceCategory category) {
    if (isSubmitting) {
      return;
    }
    if (!_selectedCategories.add(category)) {
      _selectedCategories.remove(category);
    }
    _clearFieldError(SellerRegistrationField.supportedCategories);
    _notify();
  }

  void setTermsAccepted(bool value) {
    if (_acceptedTerms == value || isSubmitting) {
      return;
    }
    _acceptedTerms = value;
    _clearFieldError(SellerRegistrationField.terms);
    _notify();
  }

  void setDeclarationsConfirmed(bool value) {
    if (_confirmedDeclarations == value || isSubmitting) {
      return;
    }
    _confirmedDeclarations = value;
    _clearFieldError(SellerRegistrationField.declarations);
    _notify();
  }

  void clearFieldError(SellerRegistrationField field) {
    if (_fieldErrors.containsKey(field) || _errorMessage != null) {
      _clearFieldError(field);
      _errorMessage = null;
      if (_status != SellerRegistrationStatus.submitting) {
        _status = SellerRegistrationStatus.draft;
      }
      _notify();
    }
  }

  Future<SellerRegistrationResult?> submit({
    required String registeredCompanyName,
    required String businessEmail,
    required String businessPhoneNumber,
    required String companyRegistrationNumber,
    required String insuranceLicenseNumber,
    required String officeAddress,
    required String authorizedRepresentativeName,
    required String password,
    required String confirmPassword,
  }) async {
    if (isSubmitting) {
      return null;
    }

    _fieldErrors = _validator.validateRegistration(
      registeredCompanyName: registeredCompanyName,
      businessEmail: businessEmail,
      businessPhoneNumber: businessPhoneNumber,
      companyRegistrationNumber: companyRegistrationNumber,
      insuranceLicenseNumber: insuranceLicenseNumber,
      officeAddress: officeAddress,
      authorizedRepresentativeName: authorizedRepresentativeName,
      authorizedRepresentativeDesignation: _designation,
      supportedCategories: _selectedCategories,
      password: password,
      confirmPassword: confirmPassword,
      acceptedTerms: _acceptedTerms,
      confirmedDeclarations: _confirmedDeclarations,
    );
    _errorMessage = null;
    _result = null;
    if (_fieldErrors.isNotEmpty) {
      _status = SellerRegistrationStatus.draft;
      _notify();
      return null;
    }

    final SellerRegistrationRequest request = SellerRegistrationRequest(
      registeredCompanyName: registeredCompanyName.trim(),
      businessEmail: businessEmail.trim().toLowerCase(),
      businessPhoneNumber: businessPhoneNumber.trim(),
      companyRegistrationNumber: companyRegistrationNumber.trim(),
      insuranceLicenseNumber: insuranceLicenseNumber.trim(),
      officeAddress: officeAddress.trim(),
      authorizedRepresentativeName: authorizedRepresentativeName.trim(),
      authorizedRepresentativeDesignation: _designation!,
      supportedCategories: _selectedCategories,
      password: password,
      acceptedTerms: _acceptedTerms,
      confirmedDeclarations: _confirmedDeclarations,
    );

    _status = SellerRegistrationStatus.submitting;
    _notify();
    try {
      final SellerRegistrationResult result = await _repository
          .submitRegistration(request);
      _status = result.status;
      if (result.status == SellerRegistrationStatus.pendingApproval) {
        _result = result;
        return result;
      }

      _errorMessage = switch (result.status) {
        SellerRegistrationStatus.rejected =>
          'Registration could not be accepted. Review the details and try again.',
        SellerRegistrationStatus.suspended =>
          'Registration is unavailable for this company. Contact support.',
        SellerRegistrationStatus.approved =>
          'This company is already approved. Return to Login to continue.',
        _ => 'Unable to submit registration. Please try again.',
      };
      return null;
    } catch (_) {
      _status = SellerRegistrationStatus.technicalFailure;
      _errorMessage =
          'Unable to submit company registration. Please try again.';
      return null;
    } finally {
      _notify();
    }
  }

  void _clearFieldError(SellerRegistrationField field) {
    if (!_fieldErrors.containsKey(field)) {
      return;
    }
    _fieldErrors = Map<SellerRegistrationField, String>.of(_fieldErrors)
      ..remove(field);
  }

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
