import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/widgets.dart';

/// Compact colored chip identifying a spending category.
///
/// Receives display data only (label + palette index) — mapping from domain
/// `Category` to index/label happens in the feature layer.
class CategoryChip extends StatelessWidget {
  /// Creates a category chip.
  const CategoryChip({
    required this.label,
    required this.paletteIndex,
    this.icon,
    super.key,
  });

  /// Localized category name.
  final String label;

  /// Index into the data-viz palette (stable per category).
  final int paletteIndex;

  /// Optional category glyph.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final palette = lds.colors.dataViz;
    final color = palette[paletteIndex % palette.length];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LdsSpacing.xs + 2,
        vertical: LdsSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(LdsRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: LdsSpacing.xxs),
          ],
          Text(
            label,
            style: lds.typography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
