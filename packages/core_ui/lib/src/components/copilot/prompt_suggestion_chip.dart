import 'dart:async';

import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:core_ui/src/utils/lds_haptics.dart';
import 'package:flutter/material.dart';

/// A tappable starter question shown before the first message.
class PromptSuggestionChip extends StatelessWidget {
  /// Creates a suggestion chip for [label].
  const PromptSuggestionChip({
    required this.label,
    required this.onTap,
    super.key,
  });

  /// Localized question text.
  final String label;

  /// Fires when tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(LdsRadius.full),
      side: BorderSide(color: lds.colors.borderSubtle),
    );
    return Material(
      color: lds.colors.surfaceElevated,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          unawaited(LdsHaptics.tap());
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LdsSpacing.md,
            vertical: LdsSpacing.sm,
          ),
          child: Text(label, style: lds.typography.label),
        ),
      ),
    );
  }
}
