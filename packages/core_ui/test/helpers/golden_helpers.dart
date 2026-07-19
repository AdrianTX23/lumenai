import 'package:alchemist/alchemist.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Wraps a golden scenario in an LDS theme with the theme surface behind it.
Widget ldsWrap({required Widget child, required bool dark}) {
  final theme = dark ? buildLdsDarkTheme() : buildLdsLightTheme();
  return Theme(
    data: theme,
    child: Material(
      color: theme.extension<LdsTheme>()!.colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LdsSpacing.md),
        child: child,
      ),
    ),
  );
}

/// Declares a pair of golden tests (dark + light) for [scenarios].
///
/// Every design-system component must render through this helper so both
/// themes stay covered by construction.
void ldsGoldenPair({
  required String fileName,
  required Map<String, Widget> scenarios,
  BoxConstraints? constraints,
}) {
  for (final (suffix, dark) in [('dark', true), ('light', false)]) {
    goldenTest(
      '$fileName ($suffix)',
      fileName: '${fileName}_$suffix',
      pumpBeforeTest: pumpOnce,
      builder: () => GoldenTestGroup(
        scenarioConstraints: constraints ?? const BoxConstraints(maxWidth: 420),
        children: [
          for (final entry in scenarios.entries)
            GoldenTestScenario(
              name: entry.key,
              child: ldsWrap(child: entry.value, dark: dark),
            ),
        ],
      ),
    );
  }
}
