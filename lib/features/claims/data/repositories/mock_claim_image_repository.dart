import '../../domain/entities/claim_image.dart';
import '../../domain/repositories/claim_image_repository.dart';

class MockClaimImageRepository implements ClaimImageRepository {
  const MockClaimImageRepository({
    this.progressDelay = const Duration(milliseconds: 100),
    this.shouldFail = false,
  });

  final Duration progressDelay;
  final bool shouldFail;

  @override
  Stream<double> uploadImage(ClaimImage image) async* {
    for (final double progress in <double>[0.2, 0.5, 0.75, 1]) {
      await Future<void>.delayed(progressDelay);
      if (shouldFail && progress >= 0.5) {
        throw StateError('Image upload failed.');
      }
      yield progress;
    }
  }
}
