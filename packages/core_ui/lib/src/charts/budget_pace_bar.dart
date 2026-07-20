import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_motion.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/widgets.dart';

/// A budget's spent-vs-limit progress, colored by how close it is to
/// (or past) the limit: accent while on track, warning near the limit,
/// negative once over.
class BudgetPaceBar extends StatelessWidget {
  /// Creates a pace bar.
  const BudgetPaceBar({
    required this.label,
    required this.spentLabel,
    required this.limitLabel,
    required this.fraction,
    this.statusLabel,
    super.key,
  });

  /// Category name (already localized).
  final String label;

  /// Pre-formatted amount spent so far.
  final String spentLabel;

  /// Pre-formatted budget limit.
  final String limitLabel;

  /// `spent / limit`. May exceed 1 when over budget.
  final double fraction;

  /// Optional status caption (e.g. "Over budget") — localized by the
  /// caller; omitted when the budget is comfortably on track.
  final String? statusLabel;

  /// Fraction at which the bar switches from accent to warning.
  static const nearLimitThreshold = 0.85;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final over = fraction > 1;
    final near = !over && fraction >= nearLimitThreshold;
    final color = over
        ? lds.colors.negative
        : (near ? lds.colors.warning : lds.colors.accent);
    final clamped = fraction.isFinite ? fraction.clamp(0.0, 1.0) : 0.0;

    return Semantics(
      label: '$label: $spentLabel of $limitLabel, '
          '${(fraction * 100).round()} percent'
          '${statusLabel != null ? ', $statusLabel' : ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: lds.typography.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$spentLabel / $limitLabel',
                style: lds.typography.caption,
              ),
            ],
          ),
          const SizedBox(height: LdsSpacing.xxs),
          SizedBox(
            height: 8,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clamped),
              duration: reduceMotion ? Duration.zero : LdsMotion.emphasized,
              curve: LdsMotion.emphasizedEasing,
              builder: (context, value, _) => RepaintBoundary(
                child: CustomPaint(
                  // A childless CustomPaint reports zero intrinsic size
                  // and just fills whatever finite width layout gives it
                  // — unlike a FractionallySizedBox, which cannot answer
                  // an intrinsic-width query (undefined without a
                  // resolved parent width) and crashes inside
                  // golden-test harnesses that probe intrinsics to lay
                  // out scenario grids.
                  painter: _PaceBarPainter(
                    progress: value,
                    trackColor: lds.colors.borderSubtle,
                    fillColor: color,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          if (statusLabel != null) ...[
            const SizedBox(height: LdsSpacing.xxs),
            Text(
              statusLabel!,
              style: lds.typography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaceBarPainter extends CustomPainter {
  const _PaceBarPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final track = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(track, Paint()..color = trackColor);

    final fillWidth = size.width * progress.clamp(0.0, 1.0);
    if (fillWidth <= 0) return;

    canvas
      ..save()
      ..clipRRect(track)
      ..drawRect(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        Paint()..color = fillColor,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _PaceBarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}
