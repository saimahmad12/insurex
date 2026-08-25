import '../entities/claim_image.dart';

abstract interface class ClaimImageRepository {
  Stream<double> uploadImage(ClaimImage image);
}
