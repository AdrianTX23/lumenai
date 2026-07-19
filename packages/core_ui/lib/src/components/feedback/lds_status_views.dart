import 'package:core_ui/src/components/actions/lds_button.dart';
import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/material.dart';

/// Centered empty-state view: icon, title, message, optional action.
class LdsEmptyState extends StatelessWidget {
  /// Creates an empty state.
  const LdsEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Illustrative icon.
  final IconData icon;

  /// Short headline.
  final String title;

  /// One-sentence explanation.
  final String message;

  /// Optional call-to-action label.
  final String? actionLabel;

  /// Optional call-to-action handler.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LdsSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: lds.colors.textFaint),
            const SizedBox(height: LdsSpacing.md),
            Text(
              title,
              style: lds.typography.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LdsSpacing.xs),
            Text(
              message,
              style: lds.typography.bodyMuted,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: LdsSpacing.xl),
              LdsButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: LdsButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centered error view with a retry action. The standard rendering of a
/// domain `Failure` after presentation maps it to localized copy.
class LdsErrorState extends StatelessWidget {
  /// Creates an error state.
  const LdsErrorState({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  /// Short headline (localized).
  final String title;

  /// Explanation without technical jargon (localized).
  final String message;

  /// Retry button copy (localized).
  final String retryLabel;

  /// Retry handler.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LdsSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: lds.colors.negative,
            ),
            const SizedBox(height: LdsSpacing.md),
            Text(
              title,
              style: lds.typography.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LdsSpacing.xs),
            Text(
              message,
              style: lds.typography.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LdsSpacing.xl),
            LdsButton(label: retryLabel, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
