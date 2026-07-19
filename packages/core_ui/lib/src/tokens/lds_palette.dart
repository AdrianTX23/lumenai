import 'dart:ui';

/// Primitive color tokens — raw values only.
///
/// NEVER use these directly in components or screens: they exist solely to
/// feed the semantic tokens in `LdsColors`. See docs/03-design-system.md §2.
abstract final class LdsPalette {
  // ── Neutral scale (dark → light). True-dark base, lightness steps —
  // elevation in dark mode is a lighter surface, never a drop shadow.
  /// Deepest background.
  static const neutral950 = Color(0xFF070A0F);

  /// Near-base dark.
  static const neutral900 = Color(0xFF0B0F16);

  /// Elevated dark surface.
  static const neutral850 = Color(0xFF10151F);

  /// High dark surface (sheets, dialogs).
  static const neutral800 = Color(0xFF151B28);

  /// Subtle borders on dark.
  static const neutral700 = Color(0xFF1C2333);

  /// Strong borders on dark.
  static const neutral600 = Color(0xFF242C3F);

  /// Faint text on dark.
  static const neutral500 = Color(0xFF39435A);

  /// Disabled elements.
  static const neutral400 = Color(0xFF566079);

  /// Muted text on dark.
  static const neutral300 = Color(0xFF7A8499);

  /// Muted text on light.
  static const neutral200 = Color(0xFFA5ADBF);

  /// Subtle borders on light.
  static const neutral100 = Color(0xFFD2D7E1);

  /// Primary text on dark.
  static const neutral50 = Color(0xFFF2F5F9);

  /// Lightest background.
  static const neutral0 = Color(0xFFFBFCFE);

  // ── Accent — "Lumen glow". Reserved for money-positive & focal moments.
  /// Gradient start (mint).
  static const mint = Color(0xFFB8FFD9);

  /// Core accent (electric teal).
  static const teal = Color(0xFF38E1C6);

  /// Gradient end (cyan).
  static const cyan = Color(0xFF22B8CF);

  /// Accent for light surfaces (AA contrast).
  static const tealDeep = Color(0xFF0B8A7A);

  /// Ink for text/icons sitting on accent fills.
  static const tealInk = Color(0xFF04241F);

  // ── Semantic hues. Spend is a warm coral — calm, not alarm-red.
  /// Positive / income (dark surfaces).
  static const green = Color(0xFF3EE6A8);

  /// Positive / income (light surfaces).
  static const greenDeep = Color(0xFF0E8F63);

  /// Negative / spend (dark surfaces).
  static const coral = Color(0xFFFF7A6B);

  /// Negative / spend (light surfaces).
  static const coralDeep = Color(0xFFC94B3D);

  /// Warning (dark surfaces).
  static const amber = Color(0xFFFFC24D);

  /// Warning (light surfaces).
  static const amberDeep = Color(0xFF9A6A0F);

  /// Info (dark surfaces).
  static const blue = Color(0xFF6BA6FF);

  /// Info (light surfaces).
  static const blueDeep = Color(0xFF2E5FC7);

  // ── Categorical data-viz hues, contrast-checked per theme.
  /// Eight-hue categorical palette for dark surfaces.
  static const dataVizDark = [
    Color(0xFF38E1C6),
    Color(0xFF6BA6FF),
    Color(0xFFB49CFF),
    Color(0xFFFF8FB8),
    Color(0xFFFFC24D),
    Color(0xFFFF7A6B),
    Color(0xFFA8E05F),
    Color(0xFF4FC3E8),
  ];

  /// Eight-hue categorical palette for light surfaces.
  static const dataVizLight = [
    Color(0xFF0B8A7A),
    Color(0xFF2E5FC7),
    Color(0xFF6D4FC9),
    Color(0xFFB93A6C),
    Color(0xFF9A6A0F),
    Color(0xFFC94B3D),
    Color(0xFF5C8A14),
    Color(0xFF177FA3),
  ];
}
