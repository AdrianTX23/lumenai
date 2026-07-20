import 'dart:math' as math;

import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_motion.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/widgets.dart';

/// One category's magnitude in a [SpendDonut].
///
/// Plain display data: [value] drives proportions, [valueLabel] is the
/// already-formatted amount to show — core_ui never formats money
/// itself outside `AmountText`/`LdsMoneyFormat`.
final class DonutSlice {
  /// Creates a slice.
  const DonutSlice({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.color,
  });

  /// Category name (already localized).
  final String label;

  /// Magnitude (positive) driving the slice's proportion of the ring.
  final double value;

  /// Pre-formatted amount for display.
  final String valueLabel;

  /// Slice color — callers pass a stable data-viz palette color.
  final Color color;
}

/// Ring chart of category spend with an animated entry sweep.
///
/// Renders through a single [CustomPainter]; proportions are exact
/// (fractions of [DonutSlice.value] over the total), animation only
/// reveals the ring — it never distorts the underlying data.
class SpendDonut extends StatelessWidget {
  /// Creates a spend donut for [slices].
  const SpendDonut({
    required this.slices,
    this.diameter = 168,
    this.strokeWidth = 22,
    this.centerLabel,
    this.centerValue,
    super.key,
  });

  /// Slices to render, any order.
  final List<DonutSlice> slices;

  /// Overall chart diameter.
  final double diameter;

  /// Ring thickness.
  final double strokeWidth;

  /// Optional caption under the center value (e.g. "this month").
  final String? centerLabel;

  /// Optional center headline (e.g. the total spend).
  final String? centerValue;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: _semanticsLabel(),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: reduceMotion ? Duration.zero : LdsMotion.celebratory,
        curve: LdsMotion.emphasizedEasing,
        builder: (context, progress, _) => RepaintBoundary(
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: CustomPaint(
              painter: _DonutPainter(
                slices: slices,
                progress: progress,
                strokeWidth: strokeWidth,
                trackColor: lds.colors.borderSubtle,
              ),
              child: centerLabel == null && centerValue == null
                  ? null
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (centerValue != null)
                            Text(centerValue!, style: lds.typography.heading),
                          if (centerLabel != null)
                            Text(centerLabel!, style: lds.typography.caption),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticsLabel() {
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return 'Spending breakdown, no data';
    final parts = slices.map((s) {
      final pct = (s.value / total * 100).round();
      return '${s.label} $pct percent, ${s.valueLabel}';
    });
    return 'Spending breakdown: ${parts.join(', ')}';
  }
}

/// Color-dot legend rows for a [SpendDonut]'s slices.
class SpendDonutLegend extends StatelessWidget {
  /// Creates a legend for [slices].
  const SpendDonutLegend({required this.slices, super.key});

  /// The same slices passed to the paired [SpendDonut].
  final List<DonutSlice> slices;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final slice in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: LdsSpacing.xxs / 2),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: slice.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: LdsSpacing.xs),
                Expanded(
                  child: Text(slice.label, style: lds.typography.body),
                ),
                Text(
                  slice.valueLabel,
                  style: lds.typography.money,
                ),
                if (total > 0) ...[
                  const SizedBox(width: LdsSpacing.xs),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(slice.value / total * 100).round()}%',
                      textAlign: TextAlign.end,
                      style: lds.typography.caption,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.slices,
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
  });

  final List<DonutSlice> slices;
  final double progress;
  final double strokeWidth;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    const start = -math.pi / 2;
    final revealAngle = 2 * math.pi * progress;
    var cursor = 0.0;
    for (final slice in slices) {
      final sweep = slice.value / total * 2 * math.pi;
      final visible = cursor + sweep <= revealAngle
          ? sweep
          : (cursor < revealAngle ? revealAngle - cursor : 0.0);
      if (visible > 0) {
        canvas.drawArc(
          rect,
          start + cursor,
          visible,
          false,
          Paint()
            ..color = slice.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.butt,
        );
      }
      cursor += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.slices != slices ||
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.trackColor != trackColor;
}
