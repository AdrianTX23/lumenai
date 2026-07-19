import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:flutter/widgets.dart';

/// Circular avatar with a deterministic monogram fallback.
///
/// Used for merchants and accounts. The background hue is derived from the
/// label so a given merchant always gets the same color.
class LdsAvatar extends StatelessWidget {
  /// Creates an avatar for [label] (e.g. a merchant name).
  const LdsAvatar({
    required this.label,
    this.icon,
    this.size = 40,
    super.key,
  });

  /// Source text for the monogram and color hash.
  final String label;

  /// Optional icon replacing the monogram (e.g. a category glyph).
  final IconData? icon;

  /// Diameter in logical pixels.
  final double size;

  /// Deterministic palette index for [label] — same merchant, same color.
  static int colorIndexFor(String label, int paletteLength) {
    var hash = 0;
    for (final unit in label.toLowerCase().codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash % paletteLength;
  }

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final palette = lds.colors.dataViz;
    final color = palette[colorIndexFor(label, palette.length)];
    final monogram =
        label.isEmpty ? '?' : label.trim().substring(0, 1).toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Tinted fill keeps contrast with the colored glyph readable in
        // both themes.
        color: color.withValues(alpha: 0.18),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: size * 0.5, color: color)
          : Text(
              monogram,
              style: lds.typography.heading.copyWith(
                color: color,
                fontSize: size * 0.42,
              ),
            ),
    );
  }
}
