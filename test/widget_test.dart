import 'package:flutter_test/flutter_test.dart';
import 'package:overlord_2/main.dart';
import 'package:overlord_2/presentation/bunker/overseer_screen.dart';
import 'package:overlord_2/presentation/screens/expedition_screen.dart';

void main() {
  testWidgets('Overlord 2 renders Overseer Command Deck and launches expedition', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Overlord2App());
    await tester.pumpAndSettle();

    // Verify Overseer Hub is displayed
    expect(find.byType(OverseerScreen), findsOneWidget);
    expect(find.textContaining('VAULT COMMAND CENTER'), findsOneWidget);
    expect(find.text('CHARACTERS'), findsOneWidget);
    expect(find.text('WEAPONS'), findsOneWidget);
    expect(find.text('CHALLENGES'), findsOneWidget);
    expect(find.text('MEDBAY'), findsOneWidget);

    // Open Quest Board -> Select Location -> Select Scout -> Deploy
    await tester.ensureVisible(find.text('>> QUEST BOARD <<'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('>> QUEST BOARD <<'));
    await tester.pumpAndSettle();

    expect(find.text('QUEST BOARD'), findsOneWidget);
    expect(find.text('HAUNTED HOME'), findsOneWidget);

    await tester.tap(find.text('INDUSTRIAL DEPOT'));
    await tester.pumpAndSettle();

    expect(find.text('SELECT SCOUT TO DEPLOY'), findsOneWidget);
    await tester.tap(find.text('Shina'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('>> DEPLOY SHINA <<'));
    await tester.pumpAndSettle();

    // Verify Expedition screen is launched with Shina and prominent Backpack dock
    expect(find.byType(ExpeditionScreen), findsOneWidget);
    expect(find.text('SHINA'), findsOneWidget);
    expect(find.textContaining('BACKPACK (0)'), findsOneWidget);
    expect(find.textContaining('FLOOR 1'), findsOneWidget);
  });
}
