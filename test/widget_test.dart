import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roman_henri_charles/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows each main operations area', (tester) async {
    await tester.pumpWidget(const OperationsApp());
    await tester.pumpAndSettle();

    expect(find.text(appName), findsOneWidget);
    expect(find.text('Daily operations command'), findsOneWidget);

    await tapDestination(tester, 'Inventory');
    await tester.pumpAndSettle();
    expect(find.text('Stock lines'), findsOneWidget);

    await tapDestination(tester, 'Work');
    await tester.pumpAndSettle();
    expect(find.text('Work queue'), findsOneWidget);

    await tapDestination(tester, 'Reports');
    await tester.pumpAndSettle();
    expect(find.text('Operational summaries'), findsOneWidget);

    await tapDestination(tester, 'Settings');
    await tester.pumpAndSettle();
    expect(find.text('No account or cloud sync'), findsOneWidget);
  });

  testWidgets('creates a local work record', (tester) async {
    await tester.pumpWidget(const OperationsApp());
    await tester.pumpAndSettle();

    await tapDestination(tester, 'Work');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add work record'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Inspect compressor',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Facilities team');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Check pressure log.',
    );
    await tester.tap(find.text('Save record'));
    await tester.pumpAndSettle();

    expect(find.text('Inspect compressor'), findsOneWidget);
    expect(find.textContaining('Facilities team'), findsOneWidget);
  });

  testWidgets('creates a local inventory item', (tester) async {
    await tester.pumpWidget(const OperationsApp());
    await tester.pumpAndSettle();

    await tapDestination(tester, 'Inventory');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add inventory item'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Valve kit');
    await tester.enterText(find.byType(TextFormField).at(1), '14');
    await tester.enterText(find.byType(TextFormField).at(2), '6');
    await tester.enterText(find.byType(TextFormField).at(3), 'Workshop drawer');
    await tester.tap(find.text('Save item'));
    await tester.pumpAndSettle();

    expect(find.text('Valve kit'), findsOneWidget);
    expect(find.textContaining('Workshop drawer'), findsOneWidget);
  });
}

Future<void> tapDestination(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(NavigationDestination, label));
  await tester.pumpAndSettle();
}
