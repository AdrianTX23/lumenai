import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/router/app_router.dart';

/// Root widget: wires router and the LUMEN Design System theme.
///
/// Dark is the primary brand experience; light has full parity and the
/// system setting decides. No screen may reference Material defaults —
/// everything flows from `context.lds`.
class LumenApp extends ConsumerWidget {
  /// Creates the root app widget.
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'LUMEN AI',
      debugShowCheckedModeBanner: false,
      theme: buildLdsLightTheme(),
      darkTheme: buildLdsDarkTheme(),
      routerConfig: router,
    );
  }
}
