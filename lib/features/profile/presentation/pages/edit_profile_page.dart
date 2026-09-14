import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../application/controllers/edit_profile_controller.dart';
import '../../application/validators/profile_validator.dart';
import '../../domain/entities/identity_verification.dart';
import '../../domain/entities/profile_field_permissions.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/entities/user_address.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/profile_page_header.dart';
import '../widgets/profile_read_only_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    required this.controller,
    required this.onBack,
    required this.onSaved,
    required this.onRequestEmailChange,
    required this.onRequestMobileChange,
    required this.onRequestIdentityCorrection,
    super.key,
  });

  final EditProfileController controller;
  final VoidCallback onBack;
  final ValueChanged<UserProfile> onSaved;
  final VoidCallback onRequestEmailChange;
  final VoidCallback onRequestMobileChange;
  final VoidCallback onRequestIdentityCorrection;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dateController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late DateTime _dateOfBirth;
  late ProfileGender _gender;
  late final ProfileFieldPermissions _permissions;

  @override
  void initState() {
    super.initState();
    final UserProfile profile = widget.controller.originalProfile;
    _permissions = widget.controller.fieldPermissions;
    _nameController = TextEditingController(text: profile.fullName);
    _dateOfBirth = profile.dateOfBirth;
    _dateController = TextEditingController(text: _formatDate(_dateOfBirth));
    _gender = profile.gender;
    _addressController = TextEditingController(
      text: profile.address.residentialAddress,
    );
    _cityController = TextEditingController(text: profile.address.city);
    _countryController = TextEditingController(text: profile.address.country);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (BuildContext context, Widget? child) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                children: <Widget>[
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ProfilePageHeader(
                            title: 'Personal Information',
                            onBack: widget.onBack,
                          ),
                          const SizedBox(height: 20),
                          GlassContainer(
                            padding: const EdgeInsets.all(18),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  if (_permissions.canEditLegalName)
                                    AuthTextField(
                                      key: const Key('edit_profile_name'),
                                      controller: _nameController,
                                      label: 'Full legal name',
                                      hintText: 'Enter your full legal name',
                                      prefixIcon: Icons.person_outline_rounded,
                                      validator:
                                          ProfileValidator.validateFullName,
                                      textInputAction: TextInputAction.next,
                                    )
                                  else
                                    ProfileReadOnlyField(
                                      key: const Key('edit_profile_name'),
                                      value: _nameController.text,
                                      label: 'Full legal name',
                                      prefixIcon: Icons.person_outline_rounded,
                                      statusLabel: _identityFieldStatusLabel,
                                    ),
                                  const SizedBox(height: 13),
                                  ProfileReadOnlyField(
                                    key: const Key('edit_profile_email'),
                                    value: widget
                                        .controller
                                        .originalProfile
                                        .emailAddress,
                                    label: 'Email address',
                                    prefixIcon: Icons.email_outlined,
                                    actionLabel: 'Change Email',
                                    actionKey: const Key(
                                      'request_email_change_button',
                                    ),
                                    onAction: _permissions.canRequestEmailChange
                                        ? widget.onRequestEmailChange
                                        : null,
                                  ),
                                  const SizedBox(height: 13),
                                  ProfileReadOnlyField(
                                    key: const Key('edit_profile_mobile'),
                                    value: widget
                                        .controller
                                        .originalProfile
                                        .mobileNumber,
                                    label: 'Mobile number',
                                    prefixIcon: Icons.phone_outlined,
                                    actionLabel: 'Change Mobile',
                                    actionKey: const Key(
                                      'request_mobile_change_button',
                                    ),
                                    onAction:
                                        _permissions.canRequestMobileChange
                                        ? widget.onRequestMobileChange
                                        : null,
                                  ),
                                  const SizedBox(height: 13),
                                  if (_permissions.canEditDateOfBirth)
                                    TextFormField(
                                      key: const Key('edit_profile_dob'),
                                      controller: _dateController,
                                      readOnly: true,
                                      onTap: _pickDate,
                                      validator: (_) =>
                                          ProfileValidator.validateDateOfBirth(
                                            _dateOfBirth,
                                          ),
                                      decoration: const InputDecoration(
                                        labelText: 'Date of birth',
                                        prefixIcon: Icon(
                                          Icons.calendar_today_outlined,
                                        ),
                                      ),
                                    )
                                  else
                                    ProfileReadOnlyField(
                                      key: const Key('edit_profile_dob'),
                                      value: _dateController.text,
                                      label: 'Date of birth',
                                      prefixIcon: Icons.calendar_today_outlined,
                                      statusLabel: _identityFieldStatusLabel,
                                    ),
                                  const SizedBox(height: 13),
                                  if (_permissions.canEditGender)
                                    DropdownButtonFormField<ProfileGender>(
                                      key: const Key('edit_profile_gender'),
                                      initialValue: _gender,
                                      decoration: const InputDecoration(
                                        labelText: 'Gender',
                                        prefixIcon: Icon(Icons.people_outline),
                                      ),
                                      dropdownColor: const Color(0xFF151E42),
                                      items: ProfileGender.values
                                          .map(
                                            (ProfileGender gender) =>
                                                DropdownMenuItem<ProfileGender>(
                                                  value: gender,
                                                  child: Text(
                                                    _genderLabel(gender),
                                                    style: const TextStyle(
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ),
                                          )
                                          .toList(),
                                      onChanged: widget.controller.isSaving
                                          ? null
                                          : (ProfileGender? value) {
                                              if (value != null) {
                                                _gender = value;
                                              }
                                            },
                                    )
                                  else
                                    ProfileReadOnlyField(
                                      key: const Key('edit_profile_gender'),
                                      value: _genderLabel(_gender),
                                      label: 'Gender',
                                      prefixIcon: Icons.people_outline,
                                      statusLabel: _identityFieldStatusLabel,
                                    ),
                                  const SizedBox(height: 13),
                                  ProfileReadOnlyField(
                                    key: const Key('edit_profile_identity'),
                                    value: widget
                                        .controller
                                        .originalProfile
                                        .maskedIdentityNumber,
                                    label: 'CNIC / identity number',
                                    prefixIcon: Icons.badge_outlined,
                                    actionLabel: _identityCorrectionActionLabel,
                                    actionKey: const Key(
                                      'request_identity_correction_button',
                                    ),
                                    onAction:
                                        _permissions
                                            .canRequestIdentityCorrection
                                        ? widget.onRequestIdentityCorrection
                                        : null,
                                  ),
                                  const SizedBox(height: 7),
                                  const Text(
                                    'Verified identity information cannot be edited directly. Contact support if a correction is required.',
                                    key: Key('verified_identity_lock_message'),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                  const SizedBox(height: 13),
                                  AuthTextField(
                                    key: const Key('edit_profile_address'),
                                    controller: _addressController,
                                    label: 'Residential address',
                                    hintText: 'Enter your address',
                                    prefixIcon: Icons.home_outlined,
                                    validator: ProfileValidator.validateAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 13),
                                  AuthTextField(
                                    key: const Key('edit_profile_city'),
                                    controller: _cityController,
                                    label: 'City',
                                    hintText: 'Enter your city',
                                    prefixIcon: Icons.location_city_outlined,
                                    validator: (String? value) =>
                                        ProfileValidator.validateRequiredLocation(
                                          value,
                                          'city',
                                        ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 13),
                                  AuthTextField(
                                    key: const Key('edit_profile_country'),
                                    controller: _countryController,
                                    label: 'Country',
                                    hintText: 'Enter your country',
                                    prefixIcon: Icons.public_outlined,
                                    validator: (String? value) =>
                                        ProfileValidator.validateRequiredLocation(
                                          value,
                                          'country',
                                        ),
                                    textInputAction: TextInputAction.done,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.controller.errorMessage !=
                              null) ...<Widget>[
                            const SizedBox(height: 12),
                            Text(
                              widget.controller.errorMessage!,
                              key: const Key('edit_profile_save_error'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFB3261E),
                                fontSize: 11,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          GlassActionButton(
                            key: const Key('save_profile_button'),
                            label: 'Save Changes',
                            icon: Icons.save_outlined,
                            isLoading: widget.controller.isSaving,
                            onPressed: widget.controller.isSaving
                                ? null
                                : _save,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _dateOfBirth = selected;
      _dateController.text = _formatDate(selected);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final UserProfile? updated = await widget.controller.save(
      ProfileUpdateRequest(
        fullName: _permissions.canEditLegalName ? _nameController.text : null,
        dateOfBirth: _permissions.canEditDateOfBirth ? _dateOfBirth : null,
        gender: _permissions.canEditGender ? _gender : null,
        address: UserAddress(
          residentialAddress: _addressController.text,
          city: _cityController.text,
          country: _countryController.text,
        ),
      ),
    );
    if (updated == null || !mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    widget.onSaved(updated);
  }

  static String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  static String _genderLabel(ProfileGender gender) {
    return switch (gender) {
      ProfileGender.female => 'Female',
      ProfileGender.male => 'Male',
      ProfileGender.other => 'Other',
      ProfileGender.preferNotToSay => 'Prefer not to say',
    };
  }

  String get _identityFieldStatusLabel {
    return switch (widget
        .controller
        .originalProfile
        .identityVerification
        .status) {
      IdentityVerificationStatus.notStarted => 'Identity verification',
      IdentityVerificationStatus.capturing => 'Verification in progress',
      IdentityVerificationStatus.submitted ||
      IdentityVerificationStatus.pending => 'Verification pending',
      IdentityVerificationStatus.verified => 'Verified',
      IdentityVerificationStatus.rejected => 'Use Identity Verification',
      IdentityVerificationStatus.expired => 'Re-verification required',
      IdentityVerificationStatus.additionalCaptureRequired =>
        'Additional capture required',
      IdentityVerificationStatus.technicalFailure => 'Verification unavailable',
    };
  }

  String get _identityCorrectionActionLabel {
    return switch (widget
        .controller
        .originalProfile
        .identityVerification
        .status) {
      IdentityVerificationStatus.notStarted => 'Verify Identity',
      IdentityVerificationStatus.capturing => 'Resume Verification',
      IdentityVerificationStatus.rejected ||
      IdentityVerificationStatus.expired ||
      IdentityVerificationStatus.additionalCaptureRequired ||
      IdentityVerificationStatus.technicalFailure => 'Retry Verification',
      IdentityVerificationStatus.submitted ||
      IdentityVerificationStatus.pending ||
      IdentityVerificationStatus.verified => 'Contact Support',
    };
  }
}
