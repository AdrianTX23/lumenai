import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/material.dart';

/// Snackbar variants.
enum LdsSnackVariant {
  /// Neutral information.
  info,

  /// Confirmation of a completed action.
  success,

  /// Recoverable failure (pairs with a retry action upstream).
  error,
}

/// Design-system snackbars. The only sanctioned transient feedback surface.
abstract final class LdsSnack {
  /// Shows [message] with the styling of [variant].
  static void show(
    BuildContext context,
    String message, {
    LdsSnackVariant variant = LdsSnackVariant.info,
  }) {
    final lds = context.lds;
    final c = lds.colors;
    final accent = switch (variant) {
      LdsSnackVariant.info => c.info,
      LdsSnackVariant.success => c.positive,
      LdsSnackVariant.error => c.negative,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: c.surfaceHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LdsRadius.md),
            side: BorderSide(color: c.borderSubtle),
          ),
          content: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(LdsRadius.full),
                ),
              ),
              const SizedBox(width: LdsSpacing.sm),
              Expanded(
                child: Text(message, style: lds.typography.body),
              ),
            ],
          ),
        ),
      );
  }
}
