import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/insurance_marketplace/application/controllers/insurance_marketplace_controller.dart';
import 'package:insurancex/features/insurance_marketplace/data/repositories/mock_insurance_marketplace_repository.dart';
import 'package:insurancex/features/insurance_marketplace/domain/entities/marketplace_query.dart';
import 'package:insurancex/features/policies/domain/entities/insurance_policy.dart';

void main() {
  group('InsuranceMarketplaceController', () {
    test('loads once and supports refresh', () async {
      final MockInsuranceMarketplaceRepository repository =
          MockInsuranceMarketplaceRepository(delay: Duration.zero);
      final InsuranceMarketplaceController controller =
          InsuranceMarketplaceController(repository: repository);

      await Future.wait(<Future<void>>[
        controller.initialize(),
        controller.initialize(),
      ]);
      expect(repository.productsCallCount, 1);
      expect(controller.products, hasLength(5));
      expect(controller.loadStatus, MarketplaceLoadStatus.success);

      await controller.refresh();
      expect(repository.productsCallCount, 2);
    });

    test('searches providers and filters categories', () async {
      final InsuranceMarketplaceController controller =
          InsuranceMarketplaceController(
            repository: MockInsuranceMarketplaceRepository(
              delay: Duration.zero,
            ),
          );
      await controller.initialize();

      await controller.updateSearch('PakShield');
      expect(controller.products, isNotEmpty);
      expect(
        controller.products.every(
          (product) => product.providerName.contains('PakShield'),
        ),
        isTrue,
      );

      await controller.updateSearch('');
      await controller.selectCategory(PolicyType.life);
      expect(controller.products, hasLength(1));
      expect(controller.products.single.category, PolicyType.life);
    });

    test('sorts, saves favourites, and limits comparison to three', () async {
      final InsuranceMarketplaceController controller =
          InsuranceMarketplaceController(
            repository: MockInsuranceMarketplaceRepository(
              delay: Duration.zero,
            ),
          );
      await controller.initialize();
      await controller.selectSort(MarketplaceSort.premiumLowToHigh);

      for (int index = 1; index < controller.products.length; index++) {
        expect(
          controller.products[index].startingPremium,
          greaterThanOrEqualTo(controller.products[index - 1].startingPremium),
        );
      }
      final String favourite = controller.products.first.id;
      controller.toggleFavourite(favourite);
      controller.toggleFavouritesOnly();
      expect(controller.products.single.id, favourite);
      controller.toggleFavouritesOnly();

      for (final product in controller.products.take(3)) {
        expect(controller.toggleComparison(product.id), isTrue);
      }
      expect(controller.toggleComparison(controller.products[3].id), isFalse);
      expect(controller.comparisonIds, hasLength(3));
    });

    test('repository exposes pagination-ready pages', () async {
      final MockInsuranceMarketplaceRepository repository =
          MockInsuranceMarketplaceRepository(delay: Duration.zero);
      final first = await repository.getProducts(
        const MarketplaceQuery(page: 1, pageSize: 2),
      );
      final second = await repository.getProducts(
        const MarketplaceQuery(page: 2, pageSize: 2),
      );
      expect(first.products, hasLength(2));
      expect(first.hasMore, isTrue);
      expect(second.products, hasLength(2));
      expect(second.page, 2);
    });

    test('filters premium, coverage, duration, and provider', () async {
      final InsuranceMarketplaceController controller =
          InsuranceMarketplaceController(
            repository: MockInsuranceMarketplaceRepository(
              delay: Duration.zero,
            ),
          );
      await controller.initialize();
      final String provider = controller.availableProviders.first;

      await controller.setMaximumPremium(10000);
      expect(
        controller.products.every(
          (product) => product.startingPremium <= 10000,
        ),
        isTrue,
      );
      await controller.setMaximumPremium(null);
      await controller.setMinimumCoverage(1000000);
      expect(
        controller.products.every(
          (product) => product.maximumCoverage >= 1000000,
        ),
        isTrue,
      );
      await controller.setMinimumCoverage(null);
      await controller.setDuration(12);
      expect(
        controller.products.every(
          (product) => product.availableDurationsMonths.contains(12),
        ),
        isTrue,
      );
      await controller.setDuration(null);
      await controller.setProvider(provider);
      expect(
        controller.products.every(
          (product) => product.providerName == provider,
        ),
        isTrue,
      );
    });
  });
}
