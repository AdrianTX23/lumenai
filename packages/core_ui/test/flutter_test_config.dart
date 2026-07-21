import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Global test config for core_ui.
///
/// Platform goldens (real font rendering) are pinned to macOS only — the
/// committed baselines live in `goldens/macos/`, so running them on any
/// other host (Linux CI, Windows) would compare against a non-existent
/// `goldens/<os>/` baseline and fail. Restricting the allowed platform
/// set is more robust than a `CI` env-var check, which didn't propagate
/// reliably through `melos exec` on the GitHub runner. Everywhere else,
/// only the platform-agnostic `ci/` goldens (Ahem rendering) run, so
/// golden checks stay deterministic across machines.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        platforms: {HostPlatform.macOS},
      ),
    ),
    run: testMain,
  );
}
