import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/app.dart';


void main() {
  testWidgets(
    'Splash screen displays primary content',
        (WidgetTester tester) async {
      await tester.pumpWidget(const InsureXApp());
      await tester.pumpAndSettle();

      expect(find.text('InsureX'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    },
  );
}