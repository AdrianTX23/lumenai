import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(const LumenWidgetbook());

/// Gallery shell. Component use cases are registered per family
/// (tokens, actions, display, charts…) as they land in Phase 1.
class LumenWidgetbook extends StatelessWidget {
  const LumenWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      appBuilder: (context, child) => child,
      addons: [
        MaterialThemeAddon(
          themes: [
            // Placeholder Material themes until the LDS theme lands (Phase 1),
            // after which these become the core_ui light/dark themes.
            WidgetbookTheme(
              name: 'Dark',
              data: ThemeData(brightness: Brightness.dark, useMaterial3: true),
            ),
            WidgetbookTheme(
              name: 'Light',
              data: ThemeData(brightness: Brightness.light, useMaterial3: true),
            ),
          ],
        ),
      ],
      directories: const [],
    );
  }
}
