import '../entities/seller_registration.dart';

abstract interface class SellerRegistrationRepository {
  Future<SellerRegistrationResult> submitRegistration(
    SellerRegistrationRequest request,
  );
}
