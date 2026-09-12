import '../entities/seller_dashboard.dart';

abstract interface class SellerDashboardRepository {
  Future<SellerDashboard> getDashboard({required String businessEmail});
}
