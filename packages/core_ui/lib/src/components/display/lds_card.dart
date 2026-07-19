import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/material.dart';

/// Elevated content container with the signature LUMEN corner.
///
/// Dark-mode elevation = lighter surface + hairline border. Never a drop
/// shadow on dark (docs/03 §2.3).
class LdsCard extends StatelessWidget {
  /// Creates a design-system card.
  const LdsCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(LdsSpacing.lg),
    super.key,
  });

  /// Card content.
  final Widget child;

  /// Optional tap handler (adds ripple).
  final VoidCallback? onTap;

  /// Inner padding; defaults to the comfortable card padding token.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.lds.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(LdsRadius.card),
      side: BorderSide(color: c.borderSubtle),
    );
    return Material(
      color: c.surfaceElevated,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
