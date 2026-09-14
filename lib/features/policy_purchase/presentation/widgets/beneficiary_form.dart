import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/beneficiary.dart';

class BeneficiaryForm extends StatefulWidget {
  const BeneficiaryForm({required this.onSubmitted, super.key});
  final ValueChanged<List<PolicyBeneficiary>> onSubmitted;
  @override
  State<BeneficiaryForm> createState() => _BeneficiaryFormState();
}

class _BeneficiaryFormState extends State<BeneficiaryForm> {
  final List<_BeneficiaryDraft> _entries = <_BeneficiaryDraft>[
    _BeneficiaryDraft(),
  ];

  @override
  void dispose() {
    for (final _BeneficiaryDraft entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GlassContainer(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'Beneficiary Information',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Allocation across all beneficiaries must total exactly 100%.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 14),
        for (int index = 0; index < _entries.length; index++) _entry(index),
        TextButton.icon(
          onPressed: () => setState(() => _entries.add(_BeneficiaryDraft())),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add Beneficiary'),
        ),
        const SizedBox(height: 10),
        GlassActionButton(
          key: const Key('beneficiary_continue_button'),
          label: 'Continue',
          onPressed: () => widget.onSubmitted(
            _entries
                .map(
                  (_BeneficiaryDraft value) => PolicyBeneficiary(
                    legalName: value.name.text,
                    relationship: value.relationship.text,
                    dateOfBirth: value.dateOfBirth ?? DateTime.now(),
                    contactDetails: value.contact.text,
                    allocationPercentage:
                        double.tryParse(value.allocation.text) ?? 0,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );

  Widget _entry(int index) {
    final _BeneficiaryDraft entry = _entries[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Beneficiary ${index + 1}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_entries.length > 1)
                IconButton(
                  onPressed: () =>
                      setState(() => _entries.removeAt(index).dispose()),
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
            ],
          ),
          TextField(
            controller: entry.name,
            decoration: const InputDecoration(labelText: 'Legal name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: entry.relationship,
            decoration: const InputDecoration(labelText: 'Relationship'),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final DateTime now = DateTime.now();
              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: entry.dateOfBirth ?? DateTime(now.year - 20),
                firstDate: DateTime(1900),
                lastDate: now,
              );
              if (date != null) setState(() => entry.dateOfBirth = date);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date of birth'),
              child: Text(
                entry.dateOfBirth == null
                    ? 'Select date'
                    : '${entry.dateOfBirth!.day}/${entry.dateOfBirth!.month}/${entry.dateOfBirth!.year}',
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: entry.contact,
            decoration: const InputDecoration(labelText: 'Contact details'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: entry.allocation,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Allocation percentage',
            ),
          ),
        ],
      ),
    );
  }
}

class _BeneficiaryDraft {
  final TextEditingController name = TextEditingController();
  final TextEditingController relationship = TextEditingController();
  final TextEditingController contact = TextEditingController();
  final TextEditingController allocation = TextEditingController();
  DateTime? dateOfBirth;
  void dispose() {
    name.dispose();
    relationship.dispose();
    contact.dispose();
    allocation.dispose();
  }
}
