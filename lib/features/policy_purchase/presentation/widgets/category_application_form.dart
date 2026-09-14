import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../policies/domain/entities/insurance_policy.dart';
import '../../domain/entities/policy_application_details.dart';

class CategoryApplicationForm extends StatelessWidget {
  const CategoryApplicationForm({
    required this.category,
    required this.onSubmitted,
    super.key,
  });

  final PolicyType category;
  final ValueChanged<PolicyApplicationDetails> onSubmitted;

  @override
  Widget build(BuildContext context) => switch (category) {
    PolicyType.vehicle => VehicleApplicationForm(onSubmitted: onSubmitted),
    PolicyType.health => HealthApplicationForm(onSubmitted: onSubmitted),
    PolicyType.travel => TravelApplicationForm(onSubmitted: onSubmitted),
    PolicyType.life => LifeApplicationForm(onSubmitted: onSubmitted),
    PolicyType.property => PropertyApplicationForm(onSubmitted: onSubmitted),
  };
}

class VehicleApplicationForm extends StatefulWidget {
  const VehicleApplicationForm({required this.onSubmitted, super.key});
  final ValueChanged<VehiclePolicyApplication> onSubmitted;
  @override
  State<VehicleApplicationForm> createState() => _VehicleApplicationFormState();
}

class _VehicleApplicationFormState extends State<VehicleApplicationForm> {
  final List<TextEditingController> _fields =
      List<TextEditingController>.generate(8, (_) => TextEditingController());

  @override
  void dispose() {
    for (final TextEditingController field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _FormCard(
    title: 'Vehicle Information',
    children: <Widget>[
      _text(_fields[0], 'Registration number'),
      _text(_fields[1], 'Make'),
      _text(_fields[2], 'Model'),
      _text(_fields[3], 'Manufacturing year', numeric: true),
      _text(_fields[4], 'Vehicle value', numeric: true),
      _text(_fields[5], 'Chassis number'),
      _text(_fields[6], 'Usage type'),
      _text(_fields[7], 'Existing damage declaration', maxLines: 3),
      _continue(() {
        widget.onSubmitted(
          VehiclePolicyApplication(
            registrationNumber: _fields[0].text,
            make: _fields[1].text,
            model: _fields[2].text,
            manufacturingYear: int.tryParse(_fields[3].text) ?? 0,
            vehicleValue: double.tryParse(_fields[4].text) ?? 0,
            chassisNumber: _fields[5].text,
            usageType: _fields[6].text,
            existingDamageDeclaration: _fields[7].text,
          ),
        );
      }),
    ],
  );
}

class HealthApplicationForm extends StatefulWidget {
  const HealthApplicationForm({required this.onSubmitted, super.key});
  final ValueChanged<HealthPolicyApplication> onSubmitted;
  @override
  State<HealthApplicationForm> createState() => _HealthApplicationFormState();
}

class _HealthApplicationFormState extends State<HealthApplicationForm> {
  final List<_PersonDraft> _members = <_PersonDraft>[_PersonDraft()];
  final TextEditingController _requirements = TextEditingController();
  final TextEditingController _declaration = TextEditingController();

  @override
  void dispose() {
    for (final _PersonDraft member in _members) {
      member.dispose();
    }
    _requirements.dispose();
    _declaration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _FormCard(
    title: 'Health Information',
    children: <Widget>[
      for (int index = 0; index < _members.length; index++)
        _personFields(
          _members[index],
          title: 'Insured member ${index + 1}',
          showRelationship: true,
          onRemove: _members.length == 1
              ? null
              : () => setState(() {
                  _members.removeAt(index).dispose();
                }),
        ),
      TextButton.icon(
        onPressed: () => setState(() => _members.add(_PersonDraft())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Insured Member'),
      ),
      _text(_requirements, 'Coverage requirements', maxLines: 2),
      _text(_declaration, 'Relevant health declaration', maxLines: 3),
      _continue(() {
        widget.onSubmitted(
          HealthPolicyApplication(
            members: _members
                .map(
                  (_PersonDraft value) => HealthInsuredMember(
                    legalName: value.name.text,
                    relationship: value.relationship.text,
                    dateOfBirth: value.dateOfBirth ?? DateTime.now(),
                  ),
                )
                .toList(),
            coverageRequirements: _requirements.text,
            healthDeclaration: _declaration.text,
          ),
        );
      }),
    ],
  );
}

class TravelApplicationForm extends StatefulWidget {
  const TravelApplicationForm({required this.onSubmitted, super.key});
  final ValueChanged<TravelPolicyApplication> onSubmitted;
  @override
  State<TravelApplicationForm> createState() => _TravelApplicationFormState();
}

class _TravelApplicationFormState extends State<TravelApplicationForm> {
  final TextEditingController _destination = TextEditingController();
  final TextEditingController _purpose = TextEditingController();
  final TextEditingController _region = TextEditingController();
  final List<_PersonDraft> _travellers = <_PersonDraft>[_PersonDraft()];
  DateTime? _departure;
  DateTime? _return;

  @override
  void dispose() {
    _destination.dispose();
    _purpose.dispose();
    _region.dispose();
    for (final _PersonDraft traveller in _travellers) {
      traveller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _FormCard(
    title: 'Travel Information',
    children: <Widget>[
      _text(_destination, 'Destination'),
      _date(
        'Departure date',
        _departure,
        (DateTime value) => setState(() => _departure = value),
      ),
      _date(
        'Return date',
        _return,
        (DateTime value) => setState(() => _return = value),
      ),
      _text(_purpose, 'Trip purpose'),
      _text(_region, 'Coverage region'),
      for (int index = 0; index < _travellers.length; index++)
        _personFields(
          _travellers[index],
          title: 'Traveller ${index + 1}',
          showRelationship: false,
          onRemove: _travellers.length == 1
              ? null
              : () => setState(() {
                  _travellers.removeAt(index).dispose();
                }),
        ),
      TextButton.icon(
        onPressed: () => setState(() => _travellers.add(_PersonDraft())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Traveller'),
      ),
      _continue(() {
        widget.onSubmitted(
          TravelPolicyApplication(
            destination: _destination.text,
            departureDate:
                _departure ?? DateTime.now().subtract(const Duration(days: 1)),
            returnDate:
                _return ?? DateTime.now().subtract(const Duration(days: 1)),
            travellers: _travellers
                .map(
                  (_PersonDraft value) => TravelTraveller(
                    legalName: value.name.text,
                    dateOfBirth: value.dateOfBirth ?? DateTime.now(),
                  ),
                )
                .toList(),
            tripPurpose: _purpose.text,
            coverageRegion: _region.text,
          ),
        );
      }),
    ],
  );
}

class LifeApplicationForm extends StatefulWidget {
  const LifeApplicationForm({required this.onSubmitted, super.key});
  final ValueChanged<LifePolicyApplication> onSubmitted;
  @override
  State<LifeApplicationForm> createState() => _LifeApplicationFormState();
}

class _LifeApplicationFormState extends State<LifeApplicationForm> {
  final TextEditingController _coverage = TextEditingController();
  final TextEditingController _occupation = TextEditingController();
  @override
  void dispose() {
    _coverage.dispose();
    _occupation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _FormCard(
    title: 'Life Insurance Information',
    children: <Widget>[
      _text(_coverage, 'Coverage amount', numeric: true),
      _text(_occupation, 'Occupation'),
      _continue(
        () => widget.onSubmitted(
          LifePolicyApplication(
            coverageAmount: double.tryParse(_coverage.text) ?? 0,
            occupation: _occupation.text,
          ),
        ),
      ),
    ],
  );
}

class PropertyApplicationForm extends StatefulWidget {
  const PropertyApplicationForm({required this.onSubmitted, super.key});
  final ValueChanged<PropertyPolicyApplication> onSubmitted;
  @override
  State<PropertyApplicationForm> createState() =>
      _PropertyApplicationFormState();
}

class _PropertyApplicationFormState extends State<PropertyApplicationForm> {
  final List<TextEditingController> _fields =
      List<TextEditingController>.generate(5, (_) => TextEditingController());
  @override
  void dispose() {
    for (final TextEditingController field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _FormCard(
    title: 'Property Information',
    children: <Widget>[
      _text(_fields[0], 'Property type'),
      _text(_fields[1], 'Property address', maxLines: 2),
      _text(_fields[2], 'Estimated value', numeric: true),
      _text(_fields[3], 'Ownership status'),
      _text(_fields[4], 'Coverage type'),
      _continue(
        () => widget.onSubmitted(
          PropertyPolicyApplication(
            propertyType: _fields[0].text,
            address: _fields[1].text,
            estimatedValue: double.tryParse(_fields[2].text) ?? 0,
            ownershipStatus: _fields[3].text,
            coverageType: _fields[4].text,
          ),
        ),
      ),
    ],
  );
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => GlassContainer(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

Widget _text(
  TextEditingController controller,
  String label, {
  bool numeric = false,
  int maxLines = 1,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: TextField(
    controller: controller,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    maxLines: maxLines,
    decoration: InputDecoration(labelText: label),
  ),
);

Widget _continue(VoidCallback onPressed) => Padding(
  padding: const EdgeInsets.only(top: 8),
  child: GlassActionButton(
    key: const Key('category_application_continue_button'),
    label: 'Continue',
    onPressed: onPressed,
  ),
);

Widget _personFields(
  _PersonDraft person, {
  required String title,
  required bool showRelationship,
  required VoidCallback? onRemove,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
        ],
      ),
      _text(person.name, 'Legal name'),
      if (showRelationship) _text(person.relationship, 'Relationship'),
      _date(
        'Date of birth',
        person.dateOfBirth,
        (DateTime value) => person.dateOfBirth = value,
      ),
    ],
  ),
);

Widget _date(String label, DateTime? value, ValueChanged<DateTime> onChanged) =>
    Builder(
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime? selected = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: DateTime(1900),
              lastDate: DateTime(now.year + 10),
            );
            if (selected != null) onChanged(selected);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            child: Text(
              value == null
                  ? 'Select date'
                  : '${value.day}/${value.month}/${value.year}',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ),
    );

class _PersonDraft {
  final TextEditingController name = TextEditingController();
  final TextEditingController relationship = TextEditingController();
  DateTime? dateOfBirth;
  void dispose() {
    name.dispose();
    relationship.dispose();
  }
}
