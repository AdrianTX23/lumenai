import 'package:core_ui/src/tokens/lds_colors.dart';
import 'package:core_ui/src/tokens/lds_typography.dart';
import 'package:flutter/material.dart';

/// The LUMEN Design System theme, attached to [ThemeData] as an extension.
///
/// Access anywhere below a `MaterialApp` via `context.lds`. Spacing, radius
/// and motion are compile-time constants (`LdsSpacing`, `LdsRadius`,
/// `LdsMotion`); colors and typography vary per theme and live here.
class LdsTheme extends ThemeExtension<LdsTheme> {
  /// Creates a theme bundle. Use [LdsTheme.dark] / [LdsTheme.light].
  const LdsTheme({required this.colors, required this.typography});

  /// Semantic colors for the active brightness.
  final LdsColors colors;

  /// Type scale colored for the active brightness.
  final LdsTypography typography;

  /// Dark bundle (primary theme).
  static final dark = LdsTheme(
    colors: LdsColors.dark,
    typography: LdsTypography.of(LdsColors.dark),
  );

  /// Light bundle (full parity).
  static final light = LdsTheme(
    colors: LdsColors.light,
    typography: LdsTypography.of(LdsColors.light),
  );

  @override
  LdsTheme copyWith({LdsColors? colors, LdsTypography? typography}) {
    return LdsTheme(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
    );
  }

  @override
  LdsTheme lerp(ThemeExtension<LdsTheme>? other, double t) {
    // Discrete swap: LDS themes are not interpolated mid-transition.
    if (other is! LdsTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Convenience accessor: `context.lds.colors.accent`.
extension LdsThemeContext on BuildContext {
  /// The [LdsTheme] of the enclosing [Theme].
  LdsTheme get lds => Theme.of(this).extension<LdsTheme>()!;
}

/// Builds the dark [ThemeData] carrying the LDS extension.
ThemeData buildLdsDarkTheme() => _buildTheme(LdsTheme.dark, Brightness.dark);

/// Builds the light [ThemeData] carrying the LDS extension.
ThemeData buildLdsLightTheme() => _buildTheme(LdsTheme.light, Brightness.light);

ThemeData _buildTheme(LdsTheme lds, Brightness brightness) {
  final c = lds.colors;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: c.surface,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.info,
      onSecondary: c.surface,
      error: c.negative,
      onError: c.surface,
      surface: c.surface,
      onSurface: c.textPrimary,
      outline: c.borderSubtle,
    ),
    dividerColor: c.borderSubtle,
    splashFactory: InkSparkle.splashFactory,
    fontFamilyFallback: const ['SF Pro Text', 'Roboto'],
    extensions: [lds],
  );
}
