import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/material.dart';

/// Shows the design-system modal bottom sheet: rounded top, drag handle,
/// safe-area aware. Quick actions and glanceable detail live in sheets;
/// full flows use full-screen routes (navigation grammar, docs/03 §4).
Future<T?> showLdsSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  final c = context.lds.colors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: c.surfaceHigh,
    barrierColor: c.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(LdsRadius.lg)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: LdsSpacing.sm,
              bottom: LdsSpacing.xs,
            ),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.borderStrong,
                borderRadius: BorderRadius.circular(LdsRadius.full),
              ),
            ),
          ),
          Flexible(child: Builder(builder: builder)),
        ],
      ),
    ),
  );
}
