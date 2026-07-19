import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Placeholder until the Copilot feature lands (Phase 5).
class CopilotPlaceholderScreen extends StatelessWidget {
  /// Creates the placeholder.
  const CopilotPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LdsEmptyState(
      icon: Icons.auto_awesome_rounded,
      title: l10n.comingSoonTitle,
      message: l10n.comingSoonCopilot,
    );
  }
}
