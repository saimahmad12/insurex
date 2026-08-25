import '../../domain/entities/claim_image.dart';
import '../../domain/repositories/claim_image_source.dart';

class MockClaimImageSource implements ClaimImageSource {
  MockClaimImageSource({
    this.delay = const Duration(milliseconds: 250),
    this.shouldFail = false,
  });

  final Duration delay;
  final bool shouldFail;
  int _sequence = 0;

  @override
  Future<List<ClaimImage>> selectImages({
    required ClaimImageSourceType source,
    required bool allowMultiple,
  }) async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw StateError('Unable to select images.');
    }

    final int count = allowMultiple ? 2 : 1;
    return List<ClaimImage>.generate(count, (int index) {
      _sequence++;
      final String extension = _sequence.isEven ? 'png' : 'jpg';
      final String fileName =
          'incident_${_sequence.toString().padLeft(2, '0')}.$extension';

      return ClaimImage(
        id: 'mock-image-$_sequence',
        fileName: fileName,
        localPath: '/mock/claims/$fileName',
        fileSizeBytes: 1200000 + (_sequence * 17500),
        captureTimestamp: DateTime.now(),
        latitude: 31.5204,
        longitude: 74.3587,
        source: source,
      );
    });
  }
}
