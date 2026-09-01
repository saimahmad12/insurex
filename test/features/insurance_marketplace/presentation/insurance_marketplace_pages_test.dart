import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/insurance_marketplace/application/controllers/insurance_marketplace_controller.dart';
import 'package:insurancex/features/insurance_marketplace/application/controllers/insurance_product_controller.dart';
import 'package:insurancex/features/insurance_marketplace/data/repositories/mock_insurance_marketplace_repository.dart';
import 'package:insurancex/features/insurance_marketplace/domain/entities/insurance_product.dart';
import 'package:insurancex/features/insurance_marketplace/domain/entities/marketplace_query.dart';
import 'package:insurancex/features/insurance_marketplace/presentation/pages/insurance_marketplace_page.dart';
import 'package:insurancex/features/insurance_marketplace/presentation/pages/insurance_product_details_page.dart';

void main() {
  testWidgets('marketplace renders products, search, save, and comparison', (
    WidgetTester tester,
  ) async {
    final InsuranceMarketplaceController controller =
        InsuranceMarketplaceController(
          repository: MockInsuranceMarketplaceRepository(delay: Duration.zero),
        );
    final List<InsuranceProduct> opened = <InsuranceProduct>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: InsuranceMarketplacePage(
          controller: controller,
          onBack: () {},
          onProductPressed: opened.add,
          onCompare: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Insurance Marketplace'), findsOneWidget);
    expect(find.byKey(const Key('marketplace_search_field')), findsOneWidget);
    expect(find.text('Drive Secure Comprehensive'), findsOneWidget);
    expect(find.text('Worldwide Travel Protect'), findsOneWidget);
    expect(find.text('Recommended'), findsNothing);
    expect(find.text('Premium: Low to High'), findsNothing);
    expect(find.text('Coverage: High to Low'), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byType(FilterChip), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(DropdownButton<MarketplaceSort>), findsNothing);
    expect(
      find.byKey(const Key('marketplace_provider_filter')),
      findsOneWidget,
    );
    expect(find.text('Any Provider'), findsOneWidget);
    expect(controller.query.sort, MarketplaceSort.none);
    expect(controller.products.first.name, 'Drive Secure Comprehensive');
    expect(find.textContaining('Verified provider'), findsNothing);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await tester.pump();
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.tap(find.text('Add to Compare').first);
    await tester.pump();
    expect(find.text('Compare (1)'), findsOneWidget);
  });

  testWidgets('product details is distinct from owned Policy Details', (
    WidgetTester tester,
  ) async {
    final MockInsuranceMarketplaceRepository repository =
        MockInsuranceMarketplaceRepository(delay: Duration.zero);
    InsuranceProduct? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: InsuranceProductDetailsPage(
          controller: InsuranceProductController(
            productId: 'vehicle-comprehensive-01',
            repository: repository,
          ),
          onBack: () {},
          onBuyNow: (InsuranceProduct value) => selected = value,
          onCompare: (_) {},
          onContactSupport: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('Coverage & Benefits'), findsOneWidget);
    await tester.fling(find.byType(ListView), const Offset(0, -2400), 1200);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product_buy_now_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('product_buy_now_button')));
    expect(selected?.id, 'vehicle-comprehensive-01');
  });
}
