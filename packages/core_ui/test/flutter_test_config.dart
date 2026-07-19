import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';

/// Global test config for core_ui.
///
/// Platform goldens (real font rendering) run locally on macOS for visual
/// review; CI compares only the platform-agnostic `ci/` goldens (Ahem
/// rendering), so golden checks are deterministic across machines.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final isCi = Platform.environment.containsKey('CI');
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: !isCi),
    ),
    run: testMain,
  );
}
