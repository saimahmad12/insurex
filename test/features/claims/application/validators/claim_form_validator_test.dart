import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/application/validators/claim_form_validator.dart';
import 'package:insurancex/features/claims/domain/entities/claim_image.dart';

void main() {
  group('ClaimFormValidator', () {
    test('validates required incident text and positive loss', () {
      expect(ClaimFormValidator.validateTitle(''), isNotNull);
      expect(ClaimFormValidator.validateTitle('Crash'), isNull);
      expect(ClaimFormValidator.validateDescription('Too short'), isNotNull);
      expect(
        ClaimFormValidator.validateDescription(
          'The vehicle was damaged near the front entrance.',
        ),
        isNull,
      );
      expect(ClaimFormValidator.validateEstimatedLoss('0'), isNotNull);
      expect(ClaimFormValidator.validateEstimatedLoss('-2'), isNotNull);
      expect(ClaimFormValidator.validateEstimatedLoss('25,000'), isNull);
    });

    test('rejects a future incident date', () {
      final DateTime now = DateTime(2026, 8, 26, 12);

      expect(
        ClaimFormValidator.validateIncidentDate(
          DateTime(2026, 8, 27),
          now: now,
        ),
        isNotNull,
      );
      expect(
        ClaimFormValidator.validateIncidentDate(
          DateTime(2026, 8, 26, 23),
          now: now,
        ),
        isNull,
      );
    });

    test('validates image extension, size, and duplication', () {
      final ClaimImage valid = _image(
        id: 'one',
        fileName: 'incident.jpg',
        path: '/mock/incident.jpg',
      );

      expect(ClaimFormValidator.validateImage(valid, <ClaimImage>[]), isNull);
      expect(
        ClaimFormValidator.validateImage(
          _image(
            id: 'bad-type',
            fileName: 'incident.gif',
            path: '/mock/incident.gif',
          ),
          <ClaimImage>[],
        ),
        contains('JPG'),
      );
      expect(
        ClaimFormValidator.validateImage(
          _image(
            id: 'large',
            fileName: 'large.png',
            path: '/mock/large.png',
            size: ClaimFormValidator.maximumImageSizeBytes + 1,
          ),
          <ClaimImage>[],
        ),
        contains('10 MB'),
      );
      expect(
        ClaimFormValidator.validateImage(valid, <ClaimImage>[valid]),
        contains('already'),
      );
    });
  });
}

ClaimImage _image({
  required String id,
  required String fileName,
  required String path,
  int size = 1024,
}) {
  return ClaimImage(
    id: id,
    fileName: fileName,
    localPath: path,
    fileSizeBytes: size,
    captureTimestamp: DateTime(2026, 8, 26),
    source: ClaimImageSourceType.gallery,
  );
}
