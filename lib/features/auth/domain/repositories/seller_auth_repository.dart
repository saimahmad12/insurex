import '../entities/seller_authentication.dart';

abstract interface class SellerAuthRepository {
  Future<SellerAuthenticationResult> login(SellerLoginCredentials credentials);
}
