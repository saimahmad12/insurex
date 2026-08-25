import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/validators/claim_form_validator.dart';
import '../../domain/entities/incident_details.dart';
import 'claim_formatters.dart';

class IncidentDetailsStep extends StatelessWidget {
  const IncidentDetailsStep({
    required this.formKey,
    required this.details,
    required this.incidentTypes,
    required this.locationController,
    required this.titleController,
    required this.descriptionController,
    required this.estimatedLossController,
    required this.onChanged,
    required this.showDateError,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final IncidentDetails details;
  final List<IncidentType> incidentTypes;
  final TextEditingController locationController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController estimatedLossController;
  final ValueChanged<IncidentDetails> onChanged;
  final bool showDateError;

  @override
  Widget build(BuildContext context) {
    final String? dateError = showDateError
        ? ClaimFormValidator.validateIncidentDate(details.occurredAt)
        : null;

    return Form(
      key: formKey,
      child: Column(
        key: const Key('incident_details_step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Tell us when and where the incident happened.',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(17),
            child: Column(
              children: <Widget>[
                DropdownButtonFormField<IncidentType>(
                  key: const Key('incident_type_field'),
                  initialValue: details.incidentType,
                  dropdownColor: const Color(0xFF151E42),
                  decoration: _decoration(
                    label: 'Incident type',
                    icon: Icons.category_outlined,
                  ),
                  items: incidentTypes
                      .map(
                        (IncidentType type) => DropdownMenuItem<IncidentType>(
                          value: type,
                          child: Text(ClaimFormatters.incidentType(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (IncidentType? value) {
                    if (value != null) {
                      onChanged(details.copyWith(incidentType: value));
                    }
                  },
                  validator: (IncidentType? value) =>
                      value == null ? 'Select an incident type.' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _DateTimeField(
                        key: const Key('incident_date_field'),
                        label: 'Incident date',
                        icon: Icons.calendar_today_outlined,
                        value: details.occurredAt == null
                            ? 'Select date'
                            : ClaimFormatters.date(details.occurredAt!),
                        hasError: dateError != null,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateTimeField(
                        key: const Key('incident_time_field'),
                        label: 'Incident time',
                        icon: Icons.schedule_outlined,
                        value: details.occurredAt == null
                            ? 'Select time'
                            : ClaimFormatters.time(details.occurredAt!),
                        hasError: dateError != null,
                        onTap: () => _selectTime(context),
                      ),
                    ),
                  ],
                ),
                if (dateError != null) ...<Widget>[
                  const SizedBox(height: 7),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      dateError,
                      style: const TextStyle(
                        color: Color(0xFFFFB3BE),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  key: const Key('incident_location_field'),
                  controller: locationController,
                  decoration: _decoration(
                    label: 'Incident location',
                    hint: 'Street, city, or landmark',
                    icon: Icons.location_on_outlined,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: ClaimFormValidator.validateLocation,
                  onChanged: (String value) {
                    onChanged(details.copyWith(location: value));
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const Key('incident_title_field'),
                  controller: titleController,
                  decoration: _decoration(
                    label: 'Short title',
                    hint: 'Brief incident summary',
                    icon: Icons.title_rounded,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: ClaimFormValidator.validateTitle,
                  onChanged: (String value) {
                    onChanged(details.copyWith(title: value));
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const Key('incident_description_field'),
                  controller: descriptionController,
                  minLines: 4,
                  maxLines: 7,
                  decoration: _decoration(
                    label: 'Detailed description',
                    hint: 'Describe what happened and the resulting damage',
                    icon: Icons.notes_rounded,
                    alignIconTop: true,
                  ),
                  textInputAction: TextInputAction.newline,
                  validator: ClaimFormValidator.validateDescription,
                  onChanged: (String value) {
                    onChanged(details.copyWith(description: value));
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const Key('estimated_loss_field'),
                  controller: estimatedLossController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: _decoration(
                    label: 'Estimated loss amount',
                    hint: 'Rs. 0',
                    icon: Icons.payments_outlined,
                  ),
                  validator: ClaimFormValidator.validateEstimatedLoss,
                  onChanged: (String value) {
                    final double? amount = double.tryParse(
                      value.replaceAll(',', '').trim(),
                    );
                    onChanged(
                      details.copyWith(
                        estimatedLoss: amount,
                        clearEstimatedLoss: amount == null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initial = details.occurredAt ?? now;
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (selected == null) {
      return;
    }
    final DateTime current = details.occurredAt ?? now;
    onChanged(
      details.copyWith(
        occurredAt: DateTime(
          selected.year,
          selected.month,
          selected.day,
          current.hour,
          current.minute,
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final DateTime current = details.occurredAt ?? DateTime.now();
    final TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (selected == null) {
      return;
    }
    onChanged(
      details.copyWith(
        occurredAt: DateTime(
          current.year,
          current.month,
          current.day,
          selected.hour,
          selected.minute,
        ),
      ),
    );
  }

  static InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? hint,
    bool alignIconTop = false,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: alignIconTop,
      prefixIcon: Padding(
        padding: EdgeInsets.only(bottom: alignIconTop ? 74 : 0),
        child: Icon(icon, color: AppColors.textSecondary, size: 21),
      ),
      filled: true,
      fillColor: AppColors.white.withValues(alpha: 0.075),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
      enabledBorder: border(AppColors.white.withValues(alpha: 0.22)),
      focusedBorder: border(AppColors.blue.withValues(alpha: 0.88), 1.35),
      errorBorder: border(const Color(0xFFFF8A9B)),
      focusedErrorBorder: border(const Color(0xFFFF8A9B), 1.35),
      errorStyle: const TextStyle(color: Color(0xFFFFB3BE), fontSize: 11.5),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.icon,
    required this.value,
    required this.hasError,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final String value;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: hasError
                ? const Color(0xFFFF8A9B)
                : AppColors.white.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: AppColors.textSecondary, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.72),
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
