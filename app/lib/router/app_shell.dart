import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tab scaffold hosting the four branches behind the LDS bottom bar.
class AppShell extends StatelessWidget {
  /// Creates the shell around the active [navigationShell] branch.
  const AppShell({required this.navigationShell, super.key});

  /// The indexed-stack shell from go_router.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LdsScaffold(
      safeBottom: false,
      body: navigationShell,
      bottomBar: LdsBottomBar(
        selectedIndex: navigationShell.currentIndex,
        onSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          LdsBottomBarItem(icon: Icons.home_rounded, label: l10n.tabHome),
          LdsBottomBarItem(
            icon: Icons.receipt_long_rounded,
            label: l10n.tabActivity,
          ),
          LdsBottomBarItem(
            icon: Icons.donut_small_rounded,
            label: l10n.tabInsights,
          ),
          LdsBottomBarItem(
            icon: Icons.auto_awesome_rounded,
            label: l10n.tabCopilot,
          ),
        ],
      ),
    );
  }
}
