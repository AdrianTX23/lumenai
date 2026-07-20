import 'dart:async';

import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_motion.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:core_ui/src/utils/lds_haptics.dart';
import 'package:flutter/material.dart';

/// Who a [ChatBubble] represents.
enum ChatBubbleRole {
  /// The person using the app — right-aligned, accent fill.
  user,

  /// Lumen's copilot — left-aligned, elevated surface.
  assistant,
}

/// One turn in a copilot conversation.
///
/// Renders [content] as it grows during streaming; a blinking cursor
/// marks the live edge while [isStreaming] is true. [evidenceLabel] is
/// pre-formatted by the caller (e.g. `"3 sources"`) — tapping it is how
/// a grounded answer's citations get highlighted in the ledger.
class ChatBubble extends StatelessWidget {
  /// Creates a chat bubble.
  const ChatBubble({
    required this.role,
    required this.content,
    this.isStreaming = false,
    this.evidenceLabel,
    this.onEvidenceTap,
    this.maxWidth = 300,
    super.key,
  });

  /// Who sent it.
  final ChatBubbleRole role;

  /// Rendered text.
  final String content;

  /// Shows a blinking cursor at the end of the text while true.
  final bool isStreaming;

  /// Pre-formatted evidence caption (e.g. `"3 sources"`); omitted when
  /// the answer cites nothing.
  final String? evidenceLabel;

  /// Fires when the evidence chip is tapped.
  final VoidCallback? onEvidenceTap;

  /// Cap on the bubble's width.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final isUser = role == ChatBubbleRole.user;
    final background = isUser ? lds.colors.accent : lds.colors.surfaceElevated;
    final foreground = isUser ? lds.colors.onAccent : lds.colors.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: LdsSpacing.md,
            vertical: LdsSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(LdsRadius.lg),
              topRight: const Radius.circular(LdsRadius.lg),
              bottomLeft: Radius.circular(isUser ? LdsRadius.lg : LdsRadius.sm),
              bottomRight:
                  Radius.circular(isUser ? LdsRadius.sm : LdsRadius.lg),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  style: lds.typography.body.copyWith(color: foreground),
                  children: [
                    TextSpan(text: content),
                    if (isStreaming)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: _StreamingCursor(color: foreground),
                        ),
                      ),
                  ],
                ),
              ),
              if (evidenceLabel != null) ...[
                const SizedBox(height: LdsSpacing.xs),
                _EvidenceChip(
                  label: evidenceLabel!,
                  color: foreground,
                  onTap: onEvidenceTap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EvidenceChip extends StatelessWidget {
  const _EvidenceChip({required this.label, required this.color, this.onTap});

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              unawaited(LdsHaptics.tap());
              onTap!();
            },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LdsSpacing.xs,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(LdsRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: lds.typography.caption.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamingCursor extends StatefulWidget {
  const _StreamingCursor({required this.color});

  final Color color;

  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: LdsMotion.celebratory,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 14,
        color: widget.color,
      ),
    );
  }
}
