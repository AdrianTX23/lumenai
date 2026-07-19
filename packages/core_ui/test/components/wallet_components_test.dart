import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      theme: buildLdsDarkTheme(),
      home: Scaffold(body: Center(child: child)),
    );

const _items = [
  CardStackItem(
    accountName: 'Current',
    last4: '4821',
    network: 'Visa',
    skinIndex: 0,
    balanceMinorUnits: 100000,
  ),
  CardStackItem(
    accountName: 'Savings',
    last4: '7710',
    network: 'Visa',
    skinIndex: 1,
    balanceMinorUnits: 800000,
  ),
];

void main() {
  group('CardStack', () {
    testWidgets('tapping a background card brings it to front', (tester) async {
      int? selected;
      await tester.pumpWidget(
        _host(CardStack(items: _items, onSelected: (i) => selected = i)),
      );

      // Only the front card shows its balance.
      expect(find.text('€1,000'), findsOneWidget);
      expect(find.text('€8,000'), findsNothing);

      await tester.tap(find.text('Savings'));
      await tester.pumpAndSettle();

      expect(selected, 1);
      expect(find.text('€8,000'), findsOneWidget);
      expect(find.text('€1,000'), findsNothing);
    });

    testWidgets('vertical fling cycles selection', (tester) async {
      int? selected;
      await tester.pumpWidget(
        _host(CardStack(items: _items, onSelected: (i) => selected = i)),
      );

      await tester.fling(
        find.byType(CardStack),
        const Offset(0, -80),
        800,
      );
      await tester.pumpAndSettle();

      expect(selected, 1);
    });
  });

  group('AnimatedAmount', () {
    testWidgets('settles on the exact target value', (tester) async {
      await tester.pumpWidget(
        _host(const AnimatedAmount(1224065, currencyCode: 'EUR')),
      );
      await tester.pumpAndSettle();

      expect(find.text('€12,240.65'), findsOneWidget);
    });

    testWidgets('reduced motion jumps straight to the target', (tester) async {
      await tester.pumpWidget(
        _host(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (_) => const AnimatedAmount(50000, currencyCode: 'EUR'),
            ),
          ),
        ),
      );
      await tester.pump();

      // Hero emphasis uses compact formatting (zero decimals dropped).
      expect(find.text('€500'), findsOneWidget);
    });
  });

  group('LdsBottomBar', () {
    testWidgets('reports taps and marks selection semantics', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        _host(
          LdsBottomBar(
            selectedIndex: 0,
            onSelected: (i) => tapped = i,
            items: const [
              LdsBottomBarItem(icon: Icons.home_rounded, label: 'Home'),
              LdsBottomBarItem(
                icon: Icons.receipt_long_rounded,
                label: 'Activity',
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Activity'));
      expect(tapped, 1);

      // Tapping the current selection is a no-op.
      tapped = null;
      await tester.tap(find.text('Home'));
      expect(tapped, isNull);
    });
  });

  group('LdsSearchField', () {
    testWidgets('emits changes and clears via the suffix button',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final changes = <String>[];

      await tester.pumpWidget(
        _host(
          LdsSearchField(
            hint: 'Search',
            controller: controller,
            onChanged: changes.add,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'uber');
      await tester.pump();
      expect(changes, ['uber']);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(changes, ['uber', '']);
    });
  });
}
