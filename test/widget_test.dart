import 'package:flutter_test/flutter_test.dart';
import 'package:overlord_2/main.dart';

void main() {
  testWidgets('Overlord 2 renders expedition screen and HUD', (WidgetTester tester) async {
    await tester.pumpWidget(const Overlord2App());
    await tester.pumpAndSettle();

    // Verify Title and HUD are displayed
    expect(find.textContaining('OVERLORD 2'), findsWidgets);
    expect(find.textContaining('SCOUT:'), findsOneWidget);
    expect(find.textContaining('VITALITY'), findsOneWidget);
    expect(find.textContaining('BUILDING CROSS-SECTION'), findsOneWidget);
  });
}
