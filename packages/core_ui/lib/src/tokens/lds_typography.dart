import 'package:core_ui/src/tokens/lds_colors.dart';
import 'package:flutter/painting.dart';

/// Type scale (1.25 ratio). Styles carry their theme text color; money
/// styles enforce tabular figures so amounts never jitter as they change.
final class LdsTypography {
  /// Builds the scale for a theme's [colors].
  factory LdsTypography.of(LdsColors colors) {
    final primary = colors.textPrimary;
    return LdsTypography._(
      displayXl: TextStyle(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: primary,
        fontFeatures: _tabular,
      ),
      display: TextStyle(
        fontSize: 34,
        height: 40 / 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: primary,
      ),
      title: TextStyle(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: primary,
      ),
      heading: TextStyle(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      body: TextStyle(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMuted: TextStyle(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: colors.textMuted,
      ),
      label: TextStyle(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: primary,
      ),
      caption: TextStyle(
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: colors.textMuted,
      ),
      moneyXl: TextStyle(
        fontSize: 34,
        height: 40 / 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: primary,
        fontFeatures: _tabular,
      ),
      money: TextStyle(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w600,
        color: primary,
        fontFeatures: _tabular,
      ),
    );
  }

  const LdsTypography._({
    required this.displayXl,
    required this.display,
    required this.title,
    required this.heading,
    required this.body,
    required this.bodyMuted,
    required this.label,
    required this.caption,
    required this.moneyXl,
    required this.money,
  });

  /// 48/56 — net-worth hero.
  final TextStyle displayXl;

  /// 34/40 — screen-level figures.
  final TextStyle display;

  /// 24/30 — screen titles.
  final TextStyle title;

  /// 18/24 — section headings, tile titles.
  final TextStyle heading;

  /// 15/22 — body copy.
  final TextStyle body;

  /// 15/22 in muted color — subtitles.
  final TextStyle bodyMuted;

  /// 13/18 medium — buttons, chips, form labels.
  final TextStyle label;

  /// 11/16 — timestamps, footnotes.
  final TextStyle caption;

  /// 34/40 tabular — hero amounts.
  final TextStyle moneyXl;

  /// 15/22 tabular — inline amounts (tiles, rows).
  final TextStyle money;

  static const _tabular = [FontFeature.tabularFigures()];
}
