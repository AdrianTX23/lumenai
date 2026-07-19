import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/router/app_router.dart';

/// Root widget: wires router and theme.
///
/// The Material dark theme below is a bootstrap placeholder — Phase 1
/// replaces it with the LUMEN Design System theme from core_ui, after
/// which no screen may reference Material defaults directly.
class LumenApp extends ConsumerWidget {
  /// Creates the root app widget.
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'LUMEN AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      routerConfig: router,
    );
  }
}
