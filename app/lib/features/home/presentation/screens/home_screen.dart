import 'package:flutter/material.dart';

/// Placeholder home screen — proves the shell (router, DI, theme) works.
/// Replaced in Phase 3 by the real wallet home (net worth hero, card
/// stack, recent activity) built from core_ui components.
class HomeScreen extends StatelessWidget {
  /// Creates the placeholder home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LUMEN AI',
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Foundations · Phase 0',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
