import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/material.dart';

/// An AI-generated callout rendered as a card rather than prose.
///
/// [confidenceLabel] is the trust affordance — a short, pre-formatted
/// string like `"Based on 12 transactions"` that tells the user the
/// claim is grounded, not invented.
class InsightCard extends StatelessWidget {
  /// Creates an insight card.
  const InsightCard({
    required this.title,
    required this.body,
    this.confidenceLabel,
    super.key,
  });

  /// Short headline.
  final String title;

  /// Explanation body.
  final String body;

  /// Optional grounding caption.
  final String? confidenceLabel;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final accent = lds.colors.accent;
    return Container(
      padding: const EdgeInsets.all(LdsSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(LdsRadius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 16, color: accent),
              const SizedBox(width: LdsSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: lds.typography.label.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LdsSpacing.xs),
          Text(body, style: lds.typography.body),
          if (confidenceLabel != null) ...[
            const SizedBox(height: LdsSpacing.xs),
            Text(confidenceLabel!, style: lds.typography.caption),
          ],
        ],
      ),
    );
  }
}
