import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/widgets.dart';

/// Compact ▲/▼ badge for period-over-period deltas.
///
/// Direction and goodness are independent: spending **up** is **bad**, so
/// callers state whether "up is good" and the badge picks the color.
class TrendBadge extends StatelessWidget {
  /// Creates a trend badge for [percent] (e.g. `12.5` = +12.5%).
  const TrendBadge({
    required this.percent,
    this.upIsGood = true,
    super.key,
  });

  /// Signed percentage change.
  final double percent;

  /// Whether an increase should read as positive (green).
  final bool upIsGood;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final up = percent >= 0;
    final good = up == upIsGood;
    final color = good ? lds.colors.positive : lds.colors.negative;
    final arrow = up ? '▲' : '▼';
    final value = percent.abs().toStringAsFixed(percent.abs() >= 10 ? 0 : 1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LdsSpacing.xs,
        vertical: LdsSpacing.xxs / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(LdsRadius.full),
      ),
      child: Text(
        '$arrow $value%',
        style: lds.typography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        semanticsLabel: '${up ? 'up' : 'down'} $value percent',
      ),
    );
  }
}
