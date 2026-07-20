import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../helpers/golden_helpers.dart';

void main() {
  ldsGoldenPair(
    fileName: 'spend_donut',
    constraints: const BoxConstraints(maxWidth: 260, maxHeight: 260),
    scenarios: {
      'with data': Builder(
        builder: (context) {
          final c = context.lds.colors.dataViz;
          return SpendDonut(
            centerValue: r'$ 1.240.000',
            centerLabel: 'this month',
            slices: [
              DonutSlice(
                label: 'Groceries',
                value: 620000,
                valueLabel: r'$ 620.000',
                color: c[0],
              ),
              DonutSlice(
                label: 'Dining',
                value: 340000,
                valueLabel: r'$ 340.000',
                color: c[1],
              ),
              DonutSlice(
                label: 'Transport',
                value: 180000,
                valueLabel: r'$ 180.000',
                color: c[2],
              ),
              DonutSlice(
                label: 'Other',
                value: 100000,
                valueLabel: r'$ 100.000',
                color: c[3],
              ),
            ],
          );
        },
      ),
      'empty': const SpendDonut(slices: []),
    },
  );

  ldsGoldenPair(
    fileName: 'spend_donut_legend',
    scenarios: {
      'rows': Builder(
        builder: (context) {
          final c = context.lds.colors.dataViz;
          return SpendDonutLegend(
            slices: [
              DonutSlice(
                label: 'Groceries',
                value: 620000,
                valueLabel: r'$ 620.000',
                color: c[0],
              ),
              DonutSlice(
                label: 'Dining',
                value: 340000,
                valueLabel: r'$ 340.000',
                color: c[1],
              ),
            ],
          );
        },
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'cashflow_bars',
    constraints: const BoxConstraints(maxWidth: 420, maxHeight: 240),
    scenarios: {
      'six months': const CashflowBars(
        incomeLabel: 'Income',
        spendLabel: 'Spend',
        points: [
          CashflowPoint(label: 'Feb', income: 4200000, spend: 3100000),
          CashflowPoint(label: 'Mar', income: 4200000, spend: 3400000),
          CashflowPoint(label: 'Apr', income: 4200000, spend: 2900000),
          CashflowPoint(label: 'May', income: 4200000, spend: 3900000),
          CashflowPoint(label: 'Jun', income: 4200000, spend: 3200000),
          CashflowPoint(label: 'Jul', income: 4200000, spend: 3050000),
        ],
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'budget_pace_bar',
    scenarios: {
      'on track': const BudgetPaceBar(
        label: 'Groceries',
        spentLabel: r'$ 420.000',
        limitLabel: r'$ 800.000',
        fraction: 0.52,
      ),
      'near limit': const BudgetPaceBar(
        label: 'Dining',
        spentLabel: r'$ 340.000',
        limitLabel: r'$ 400.000',
        fraction: 0.9,
        statusLabel: 'Near limit',
      ),
      'over budget': const BudgetPaceBar(
        label: 'Shopping',
        spentLabel: r'$ 950.000',
        limitLabel: r'$ 800.000',
        fraction: 1.19,
        statusLabel: 'Over budget',
      ),
    },
  );
}
