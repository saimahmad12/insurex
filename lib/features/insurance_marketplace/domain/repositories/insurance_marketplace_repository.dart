import '../entities/insurance_product.dart';
import '../entities/marketplace_query.dart';

abstract interface class InsuranceMarketplaceRepository {
  Future<MarketplacePageResult> getProducts(MarketplaceQuery query);

  Future<InsuranceProduct?> getProductById(String productId);
}
