import 'dart:math' as math;

import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_motion.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/widgets.dart';

/// Income vs. spend for one period in a [CashflowBars] chart.
final class CashflowPoint {
  /// Creates a cashflow point.
  const CashflowPoint({
    required this.label,
    required this.income,
    required this.spend,
  });

  /// Period label (e.g. `Jul`).
  final String label;

  /// Income magnitude (positive).
  final double income;

  /// Spend magnitude (positive).
  final double spend;
}

/// Paired income/spend bars across trailing periods.
///
/// Bars scale to the largest value in the series so relative size is
/// always meaningful, and animate in on first paint.
class CashflowBars extends StatelessWidget {
  /// Creates the chart for [points], oldest first.
  const CashflowBars({
    required this.points,
    required this.incomeLabel,
    required this.spendLabel,
    this.height = 160,
    super.key,
  });

  /// Points to render, oldest first.
  final List<CashflowPoint> points;

  /// Localized legend label for the income series.
  final String incomeLabel;

  /// Localized legend label for the spend series.
  final String spendLabel;

  /// Chart height, including the axis labels.
  final double height;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final maxValue = points.fold<double>(
      0,
      (m, p) => math.max(m, math.max(p.income, p.spend)),
    );

    return Semantics(
      label: _semanticsLabel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LegendDot(color: lds.colors.positive, label: incomeLabel),
              const SizedBox(width: LdsSpacing.md),
              _LegendDot(color: lds.colors.negative, label: spendLabel),
            ],
          ),
          const SizedBox(height: LdsSpacing.sm),
          SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final point in points)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: LdsSpacing.xxs / 2,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _Bar(
                                  color: lds.colors.positive,
                                  targetFraction: maxValue <= 0
                                      ? 0
                                      : point.income / maxValue,
                                  reduceMotion: reduceMotion,
                                ),
                                const SizedBox(width: 3),
                                _Bar(
                                  color: lds.colors.negative,
                                  targetFraction: maxValue <= 0
                                      ? 0
                                      : point.spend / maxValue,
                                  reduceMotion: reduceMotion,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: LdsSpacing.xxs),
                          Text(point.label, style: lds.typography.caption),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _semanticsLabel() {
    if (points.isEmpty) return 'Cashflow, no data';
    final parts = points.map(
      (p) => '${p.label}: $incomeLabel ${p.income.round()}, '
          '$spendLabel ${p.spend.round()}',
    );
    return 'Cashflow by period: ${parts.join('; ')}';
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: LdsSpacing.xxs),
        Text(label, style: lds.typography.caption),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.color,
    required this.targetFraction,
    required this.reduceMotion,
  });

  final Color color;
  final double targetFraction;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final clamped =
        targetFraction.isFinite ? targetFraction.clamp(0.0, 1.0) : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: clamped),
      duration: reduceMotion ? Duration.zero : LdsMotion.emphasized,
      curve: LdsMotion.emphasizedEasing,
      builder: (context, value, _) => RepaintBoundary(
        child: FractionallySizedBox(
          heightFactor: value < 0.02 ? 0.02 : value,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
