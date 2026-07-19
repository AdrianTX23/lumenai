import 'dart:ui';

import 'package:core_ui/src/tokens/lds_palette.dart';

/// Semantic color tokens. Components reference these — never the palette.
///
/// Both themes expose the same fields, so a component written once renders
/// correctly in dark and light. Dark is the primary theme (finance apps
/// live in dark mode); light has full parity.
enum LdsColors {
  /// Dark theme semantic mapping (primary theme).
  dark(
    surface: LdsPalette.neutral950,
    surfaceElevated: LdsPalette.neutral850,
    surfaceHigh: LdsPalette.neutral800,
    borderSubtle: LdsPalette.neutral700,
    borderStrong: LdsPalette.neutral600,
    textPrimary: LdsPalette.neutral50,
    textMuted: LdsPalette.neutral300,
    textFaint: LdsPalette.neutral500,
    accent: LdsPalette.teal,
    onAccent: LdsPalette.tealInk,
    accentGradient: [LdsPalette.mint, LdsPalette.teal, LdsPalette.cyan],
    positive: LdsPalette.green,
    negative: LdsPalette.coral,
    warning: LdsPalette.amber,
    info: LdsPalette.blue,
    dataViz: LdsPalette.dataVizDark,
    scrim: Color(0xB3070A0F),
  ),

  /// Light theme semantic mapping (full parity).
  light(
    surface: Color(0xFFF5F7FB),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFE3E8F0),
    borderStrong: LdsPalette.neutral100,
    textPrimary: Color(0xFF0B1220),
    textMuted: Color(0xFF5A6478),
    textFaint: Color(0xFF9AA3B5),
    accent: LdsPalette.tealDeep,
    onAccent: Color(0xFFFFFFFF),
    accentGradient: [
      LdsPalette.tealDeep,
      Color(0xFF0FA995),
      Color(0xFF177FA3),
    ],
    positive: LdsPalette.greenDeep,
    negative: LdsPalette.coralDeep,
    warning: LdsPalette.amberDeep,
    info: LdsPalette.blueDeep,
    dataViz: LdsPalette.dataVizLight,
    scrim: Color(0x66242C3F),
  );

  const LdsColors({
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHigh,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textPrimary,
    required this.textMuted,
    required this.textFaint,
    required this.accent,
    required this.onAccent,
    required this.accentGradient,
    required this.positive,
    required this.negative,
    required this.warning,
    required this.info,
    required this.dataViz,
    required this.scrim,
  });

  /// Base background.
  final Color surface;

  /// Cards and tiles: one elevation step up.
  final Color surfaceElevated;

  /// Sheets, dialogs, popovers: two steps up.
  final Color surfaceHigh;

  /// Hairline borders and dividers.
  final Color borderSubtle;

  /// Emphasized borders (focus, selected).
  final Color borderStrong;

  /// Primary text and icons.
  final Color textPrimary;

  /// Secondary text (subtitles, captions).
  final Color textMuted;

  /// Tertiary text (placeholders, disabled).
  final Color textFaint;

  /// The Lumen glow — reserved for money-positive and focal moments.
  final Color accent;

  /// Text/icons on accent fills.
  final Color onAccent;

  /// Mint → teal → cyan gradient stops for hero moments.
  final List<Color> accentGradient;

  /// Gains and income.
  final Color positive;

  /// Spend and destructive actions — warm coral, deliberately not red.
  final Color negative;

  /// Caution states (budget near limit, stale data).
  final Color warning;

  /// Informational accents.
  final Color info;

  /// Categorical palette for charts (8 hues, colorblind-safe ordering).
  final List<Color> dataViz;

  /// Overlay behind sheets and dialogs.
  final Color scrim;
}
