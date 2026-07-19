import 'dart:async';

import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_motion.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:core_ui/src/utils/lds_haptics.dart';
import 'package:flutter/material.dart';

/// One destination in the [LdsBottomBar].
final class LdsBottomBarItem {
  /// Creates a destination.
  const LdsBottomBarItem({required this.icon, required this.label});

  /// Destination glyph.
  final IconData icon;

  /// Localized label (also the semantics label).
  final String label;
}

/// Floating bottom navigation: rounded surface, animated selection pill.
class LdsBottomBar extends StatelessWidget {
  /// Creates the bottom bar.
  const LdsBottomBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  /// Destinations (typically 4).
  final List<LdsBottomBarItem> items;

  /// Currently selected destination.
  final int selectedIndex;

  /// Selection callback.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        LdsSpacing.md,
        0,
        LdsSpacing.md,
        LdsSpacing.xs,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: lds.colors.surfaceHigh,
          borderRadius: BorderRadius.circular(LdsRadius.lg),
          border: Border.all(color: lds.colors.borderSubtle),
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _BarItem(
                  item: items[i],
                  selected: i == selectedIndex,
                  onTap: () {
                    if (i != selectedIndex) {
                      unawaited(LdsHaptics.tap());
                      onSelected(i);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final LdsBottomBarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final color = selected ? lds.colors.accent : lds.colors.textMuted;

    return Semantics(
      label: item.label,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LdsRadius.lg),
        child: Center(
          child: AnimatedContainer(
            duration: LdsMotion.standard,
            curve: LdsMotion.standardEasing,
            padding: const EdgeInsets.symmetric(
              horizontal: LdsSpacing.sm,
              vertical: LdsSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? lds.colors.accent.withValues(alpha: 0.14)
                  : const Color(0x00000000),
              borderRadius: BorderRadius.circular(LdsRadius.full),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 22, color: color),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: lds.typography.caption.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
