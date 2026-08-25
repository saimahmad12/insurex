import '../entities/claim_image.dart';

abstract interface class ClaimImageSource {
  Future<List<ClaimImage>> selectImages({
    required ClaimImageSourceType source,
    required bool allowMultiple,
  });
}
