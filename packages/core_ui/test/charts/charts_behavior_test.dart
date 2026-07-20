import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      theme: buildLdsDarkTheme(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('SpendDonut', () {
    testWidgets('exposes a semantics summary of every slice', (tester) async {
      await tester.pumpWidget(
        _host(
          const SpendDonut(
            slices: [
              DonutSlice(
                label: 'Groceries',
                value: 75,
                valueLabel: r'$ 75',
                color: Color(0xFF00FF00),
              ),
              DonutSlice(
                label: 'Dining',
                value: 25,
                valueLabel: r'$ 25',
                color: Color(0xFFFF0000),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(SpendDonut));
      expect(semantics.label, contains('Groceries 75 percent'));
      expect(semantics.label, contains('Dining 25 percent'));
    });

    testWidgets('renders center value and label when provided', (tester) async {
      await tester.pumpWidget(
        _host(
          const SpendDonut(
            centerValue: r'$ 100',
            centerLabel: 'this month',
            slices: [
              DonutSlice(
                label: 'Groceries',
                value: 100,
                valueLabel: r'$ 100',
                color: Color(0xFF00FF00),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'$ 100'), findsOneWidget);
      expect(find.text('this month'), findsOneWidget);
    });

    testWidgets('empty data does not throw and reports no data',
        (tester) async {
      await tester.pumpWidget(_host(const SpendDonut(slices: [])));
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(SpendDonut));
      expect(semantics.label, contains('no data'));
    });
  });

  group('SpendDonutLegend', () {
    testWidgets('shows label, amount and percentage per slice', (tester) async {
      await tester.pumpWidget(
        _host(
          const SpendDonutLegend(
            slices: [
              DonutSlice(
                label: 'Groceries',
                value: 75,
                valueLabel: r'$ 75',
                color: Color(0xFF00FF00),
              ),
              DonutSlice(
                label: 'Dining',
                value: 25,
                valueLabel: r'$ 25',
                color: Color(0xFFFF0000),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text(r'$ 75'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });
  });

  group('CashflowBars', () {
    testWidgets('renders a bar pair per point with legend', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 300,
            child: CashflowBars(
              incomeLabel: 'Income',
              spendLabel: 'Spend',
              points: [
                CashflowPoint(label: 'Jun', income: 100, spend: 60),
                CashflowPoint(label: 'Jul', income: 100, spend: 80),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jun'), findsOneWidget);
      expect(find.text('Jul'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Spend'), findsOneWidget);

      final semantics = tester.getSemantics(find.byType(CashflowBars));
      expect(semantics.label, contains('Jun'));
      expect(semantics.label, contains('Jul'));
    });

    testWidgets('empty points renders without throwing', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 300,
            child: CashflowBars(
              incomeLabel: 'Income',
              spendLabel: 'Spend',
              points: [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(CashflowBars));
      expect(semantics.label, contains('no data'));
    });
  });

  group('BudgetPaceBar', () {
    testWidgets('on-track bar carries no status label', (tester) async {
      await tester.pumpWidget(
        _host(
          const BudgetPaceBar(
            label: 'Groceries',
            spentLabel: r'$ 400.000',
            limitLabel: r'$ 800.000',
            fraction: 0.5,
          ),
        ),
      );

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.textContaining('Over'), findsNothing);
    });

    testWidgets('over-budget bar shows the supplied status label',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const BudgetPaceBar(
            label: 'Shopping',
            spentLabel: r'$ 950.000',
            limitLabel: r'$ 800.000',
            fraction: 1.19,
            statusLabel: 'Over budget',
          ),
        ),
      );

      expect(find.text('Over budget'), findsOneWidget);

      final semantics = tester.getSemantics(find.byType(BudgetPaceBar));
      expect(semantics.label, contains('119 percent'));
      expect(semantics.label, contains('Over budget'));
    });
  });
}
