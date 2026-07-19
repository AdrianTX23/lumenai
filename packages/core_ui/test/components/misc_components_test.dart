import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      theme: buildLdsDarkTheme(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('LdsAvatar', () {
    test('color index is deterministic and case-insensitive', () {
      final a = LdsAvatar.colorIndexFor('Mercadona', 8);
      expect(LdsAvatar.colorIndexFor('mercadona', 8), a);
      expect(LdsAvatar.colorIndexFor('MERCADONA', 8), a);
      expect(a, inInclusiveRange(0, 7));
    });

    testWidgets('renders uppercase monogram', (tester) async {
      await tester.pumpWidget(_host(const LdsAvatar(label: 'netflix')));
      expect(find.text('N'), findsOneWidget);
    });
  });

  group('TrendBadge', () {
    testWidgets('spend increase reads negative when upIsGood is false',
        (tester) async {
      await tester.pumpWidget(
        _host(const TrendBadge(percent: 12.5, upIsGood: false)),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, '▲ 13%');
      expect(text.style?.color, LdsColors.dark.negative);
    });
  });

  group('LdsSnack', () {
    testWidgets('shows a floating snackbar with the message', (tester) async {
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => LdsButton(
              label: 'Show',
              onPressed: () => LdsSnack.show(context, 'Budget created'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(LdsMotion.standard);

      expect(find.text('Budget created'), findsOneWidget);
    });
  });

  group('showLdsSheet', () {
    testWidgets('presents content with a drag handle', (tester) async {
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => LdsButton(
              label: 'Open',
              onPressed: () => showLdsSheet<void>(
                context: context,
                builder: (_) => const Text('Sheet content'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Sheet content'), findsOneWidget);
    });
  });
}
