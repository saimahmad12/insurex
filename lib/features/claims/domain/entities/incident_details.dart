enum IncidentType {
  collision,
  theft,
  vehicleDamage,
  medicalEmergency,
  hospitalization,
  baggageLoss,
  tripCancellation,
  other,
}

class IncidentDetails {
  const IncidentDetails({
    this.incidentType,
    this.occurredAt,
    this.location = '',
    this.title = '',
    this.description = '',
    this.estimatedLoss,
  });

  final IncidentType? incidentType;
  final DateTime? occurredAt;
  final String location;
  final String title;
  final String description;
  final double? estimatedLoss;

  IncidentDetails copyWith({
    IncidentType? incidentType,
    bool clearIncidentType = false,
    DateTime? occurredAt,
    String? location,
    String? title,
    String? description,
    double? estimatedLoss,
    bool clearEstimatedLoss = false,
  }) {
    return IncidentDetails(
      incidentType: clearIncidentType
          ? null
          : incidentType ?? this.incidentType,
      occurredAt: occurredAt ?? this.occurredAt,
      location: location ?? this.location,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedLoss: clearEstimatedLoss
          ? null
          : estimatedLoss ?? this.estimatedLoss,
    );
  }
}
