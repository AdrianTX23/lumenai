import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      theme: buildLdsDarkTheme(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('LdsMoneyFormat', () {
    test('formats minor units with grouping and decimals', () {
      expect(
        LdsMoneyFormat.format(123456, currencyCode: 'EUR'),
        '€1,234.56',
      );
    });

    test('negative amounts carry a minus sign', () {
      expect(LdsMoneyFormat.format(-1234, currencyCode: 'EUR'), '-€12.34');
    });

    test('signed mode adds explicit plus to income', () {
      expect(
        LdsMoneyFormat.format(1234, currencyCode: 'EUR', signed: true),
        '+€12.34',
      );
      expect(
        LdsMoneyFormat.format(0, currencyCode: 'EUR', signed: true),
        '€0.00',
      );
    });

    test('COP renders zero decimals with leading symbol (Colombian usage)', () {
      // intl renders the symbol gap as a non-breaking space.
      const nbsp = ' ';
      expect(
        LdsMoneyFormat.format(4200000, currencyCode: 'COP', locale: 'es_CO'),
        '\$$nbsp' '4.200.000',
      );
      expect(
        LdsMoneyFormat.format(-6500, currencyCode: 'COP', locale: 'es_CO'),
        '-\$$nbsp' '6.500',
      );
      expect(
        LdsMoneyFormat.format(
          15000,
          currencyCode: 'COP',
          locale: 'es_CO',
          signed: true,
        ),
        '+\$$nbsp' '15.000',
      );
    });

    test('compact mode drops zero decimals only', () {
      expect(
        LdsMoneyFormat.format(124000, currencyCode: 'EUR', compact: true),
        '€1,240',
      );
      expect(
        LdsMoneyFormat.format(124050, currencyCode: 'EUR', compact: true),
        '€1,240.50',
      );
    });
  });

  group('AmountText', () {
    testWidgets('income renders positive color with plus sign', (tester) async {
      await tester.pumpWidget(
        _host(const AmountText(500, currencyCode: 'EUR')),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, '+€5.00');
      expect(text.style?.color, LdsColors.dark.positive);
    });

    testWidgets('spend renders primary text color', (tester) async {
      await tester.pumpWidget(
        _host(const AmountText(-500, currencyCode: 'EUR')),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, '-€5.00');
      expect(text.style?.color, LdsColors.dark.textPrimary);
    });

    testWidgets('all amount styles use tabular figures', (tester) async {
      await tester.pumpWidget(
        _host(const AmountText(-500, currencyCode: 'EUR')),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(
        text.style?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    });
  });
}
