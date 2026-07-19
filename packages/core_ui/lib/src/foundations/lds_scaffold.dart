import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:flutter/material.dart';

/// Base page scaffold: LDS surface background and safe-area handling.
/// Every screen in the app sits on one of these.
class LdsScaffold extends StatelessWidget {
  /// Creates a design-system scaffold.
  const LdsScaffold({
    required this.body,
    this.appBar,
    this.bottomBar,
    this.safeTop = true,
    this.safeBottom = true,
    super.key,
  });

  /// Page content.
  final Widget body;

  /// Optional app bar.
  final PreferredSizeWidget? appBar;

  /// Optional bottom navigation surface.
  final Widget? bottomBar;

  /// Whether to inset the top safe area.
  final bool safeTop;

  /// Whether to inset the bottom safe area.
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.lds.colors.surface,
      appBar: appBar,
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        top: safeTop,
        bottom: safeBottom,
        child: body,
      ),
    );
  }
}
