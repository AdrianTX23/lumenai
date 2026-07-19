import 'package:core_telemetry/core_telemetry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/di/app_flavor.dart';

/// The active build flavor. Overridden in [overridesFor]; reading it before
/// bootstrap wires it is a programming error, hence no default.
final flavorProvider = Provider<AppFlavor>(
  (ref) => throw UnimplementedError('flavorProvider must be overridden'),
);

/// Logging port. Console adapter for now; a release adapter (crash
/// reporting vendor) will replace it per flavor without touching consumers.
final loggerProvider = Provider<Logger>((ref) => ConsoleLogger());

/// The single place where ports are bound to adapters (composition root).
///
/// As adapters land (Phase 2: Drift repositories, Phase 5: AI proxy), this
/// is the only file where flavor-specific bindings are added.
List<Override> overridesFor(AppFlavor flavor) {
  return [
    flavorProvider.overrideWithValue(flavor),
    // Phase 2+: repository ports → Drift adapters (dev: seeded, prod: encrypted).
    // Phase 5+: CopilotRepository → mock (dev) | SSE proxy (prod).
  ];
}
