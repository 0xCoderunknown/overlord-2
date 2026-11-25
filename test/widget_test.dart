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
    expect(find.textContaining('SCOUT VANCE'), findsOneWidget);
    expect(find.text('REQUISITION'), findsOneWidget);
    expect(find.text('ARMORY STASH'), findsOneWidget);
    expect(find.text('MEDBAY'), findsOneWidget);

    // Tap Launch Expedition -> opens Contract Picker
    final launchButton = find.text('>> LAUNCH FACILITY EXPEDITION <<');
    expect(launchButton, findsOneWidget);
    await tester.tap(launchButton);
    await tester.pumpAndSettle();

    expect(find.text('SELECT INFILTRATION CONTRACT'), findsOneWidget);
    await tester.tap(find.text('INDUSTRIAL DEPOT'));
    await tester.pumpAndSettle();

    // Verify Expedition screen is launched with prominent Backpack dock
    expect(find.byType(ExpeditionScreen), findsOneWidget);
    expect(find.textContaining('SCOUT: VANCE'), findsOneWidget);
    expect(find.textContaining('BACKPACK (0)'), findsOneWidget);
    expect(find.textContaining('FLOOR 1'), findsOneWidget);
  });
}
