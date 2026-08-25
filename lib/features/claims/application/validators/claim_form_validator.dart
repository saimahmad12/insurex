import '../../domain/entities/claim_image.dart';
import '../../domain/entities/incident_details.dart';

abstract final class ClaimFormValidator {
  static const int maximumImageSizeBytes = 10 * 1024 * 1024;

  static String? validateTitle(String? value) {
    final String title = value?.trim() ?? '';
    if (title.isEmpty) {
      return 'Enter a short incident title.';
    }
    if (title.length < 3) {
      return 'Title must contain at least 3 characters.';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    final String description = value?.trim() ?? '';
    if (description.isEmpty) {
      return 'Describe what happened.';
    }
    if (description.length < 20) {
      return 'Description must contain at least 20 characters.';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Enter the incident location.';
    }
    return null;
  }

  static String? validateEstimatedLoss(String? value) {
    final String amount = (value ?? '').replaceAll(',', '').trim();
    if (amount.isEmpty) {
      return 'Enter the estimated loss amount.';
    }
    final double? parsed = double.tryParse(amount);
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid positive amount.';
    }
    return null;
  }

  static String? validateIncidentDate(DateTime? date, {DateTime? now}) {
    if (date == null) {
      return 'Select the incident date and time.';
    }
    final DateTime current = now ?? DateTime.now();
    final DateTime selectedDay = DateTime(date.year, date.month, date.day);
    final DateTime currentDay = DateTime(
      current.year,
      current.month,
      current.day,
    );
    if (selectedDay.isAfter(currentDay)) {
      return 'Incident date cannot be in the future.';
    }
    return null;
  }

  static Map<String, String> validateIncidentDetails(
    IncidentDetails details, {
    DateTime? now,
  }) {
    final Map<String, String> errors = <String, String>{};
    if (details.incidentType == null) {
      errors['incidentType'] = 'Select an incident type.';
    }
    final String? dateError = validateIncidentDate(
      details.occurredAt,
      now: now,
    );
    if (dateError != null) {
      errors['occurredAt'] = dateError;
    }
    final String? locationError = validateLocation(details.location);
    if (locationError != null) {
      errors['location'] = locationError;
    }
    final String? titleError = validateTitle(details.title);
    if (titleError != null) {
      errors['title'] = titleError;
    }
    final String? descriptionError = validateDescription(details.description);
    if (descriptionError != null) {
      errors['description'] = descriptionError;
    }
    if (details.estimatedLoss == null || details.estimatedLoss! <= 0) {
      errors['estimatedLoss'] = 'Enter a valid positive amount.';
    }
    return errors;
  }

  static String? validateImage(
    ClaimImage image,
    List<ClaimImage> existingImages,
  ) {
    final String extension = image.fileName.contains('.')
        ? image.fileName.split('.').last.toLowerCase()
        : '';
    if (!<String>{'jpg', 'jpeg', 'png'}.contains(extension)) {
      return 'Only JPG, JPEG, and PNG images are supported.';
    }
    if (image.fileSizeBytes <= 0 ||
        image.fileSizeBytes > maximumImageSizeBytes) {
      return 'Each image must be 10 MB or smaller.';
    }
    final bool duplicate = existingImages.any(
      (ClaimImage existing) =>
          existing.localPath == image.localPath ||
          (existing.fileName.toLowerCase() == image.fileName.toLowerCase() &&
              existing.fileSizeBytes == image.fileSizeBytes),
    );
    if (duplicate) {
      return 'This image has already been added.';
    }
    return null;
  }
}
