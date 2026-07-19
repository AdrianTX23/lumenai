import 'dart:async';

import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_motion.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:core_ui/src/utils/lds_haptics.dart';
import 'package:flutter/material.dart';

/// Visual variants of [LdsButton].
enum LdsButtonVariant {
  /// Accent fill — the one primary action per screen.
  primary,

  /// Elevated surface with border — secondary actions.
  secondary,

  /// Text-only — tertiary/inline actions.
  ghost,

  /// Coral fill — destructive confirmations.
  destructive,
}

/// Size presets of [LdsButton].
enum LdsButtonSize {
  /// 36pt — inline contexts.
  small(36),

  /// 44pt — default (minimum comfortable touch target).
  medium(44),

  /// 52pt — hero CTAs.
  large(52);

  const LdsButtonSize(this.height);

  /// Fixed control height.
  final double height;
}

/// The design-system button. All tappable CTAs in the app are this widget —
/// raw `ElevatedButton`/`TextButton` are banned outside core_ui.
class LdsButton extends StatelessWidget {
  /// Creates a design-system button.
  const LdsButton({
    required this.label,
    required this.onPressed,
    this.variant = LdsButtonVariant.primary,
    this.size = LdsButtonSize.medium,
    this.icon,
    this.loading = false,
    this.expand = false,
    super.key,
  });

  /// Button copy (already localized).
  final String label;

  /// Tap handler; `null` renders the disabled state.
  final VoidCallback? onPressed;

  /// Visual variant.
  final LdsButtonVariant variant;

  /// Size preset.
  final LdsButtonSize size;

  /// Optional leading icon.
  final IconData? icon;

  /// Shows a spinner and suppresses taps while `true`.
  final bool loading;

  /// Stretches to the available width.
  final bool expand;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final c = lds.colors;

    final (background, foreground, border) = switch (variant) {
      LdsButtonVariant.primary => (c.accent, c.onAccent, null),
      LdsButtonVariant.secondary => (
          c.surfaceElevated,
          c.textPrimary,
          c.borderSubtle,
        ),
      LdsButtonVariant.ghost => (Colors.transparent, c.accent, null),
      LdsButtonVariant.destructive => (c.negative, c.surface, null),
    };

    final radius = BorderRadius.circular(size.height / 2.6);
    final labelStyle = lds.typography.label.copyWith(
      color: foreground,
      fontSize: size == LdsButtonSize.large ? 15 : 13,
    );

    final content = AnimatedSwitcher(
      duration: LdsMotion.fast,
      child: loading
          ? SizedBox.square(
              key: const ValueKey('lds-button-spinner'),
              dimension: size.height / 2.6,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(foreground),
              ),
            )
          : Row(
              key: const ValueKey('lds-button-label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: foreground),
                  const SizedBox(width: LdsSpacing.xs),
                ],
                Text(label, style: labelStyle),
              ],
            ),
    );

    return AnimatedOpacity(
      duration: LdsMotion.fast,
      opacity: _enabled || loading ? 1 : 0.45,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: _enabled
              ? () {
                  unawaited(LdsHaptics.tap());
                  onPressed!();
                }
              : null,
          child: Container(
            height: size.height,
            width: expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: LdsSpacing.lg),
            alignment: Alignment.center,
            decoration: border == null
                ? null
                : BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: border),
                  ),
            child: content,
          ),
        ),
      ),
    );
  }
}
