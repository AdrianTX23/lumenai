import 'dart:async';

import 'package:core_telemetry/core_telemetry.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/app.dart';
import 'package:lumen_app/di/app_flavor.dart';
import 'package:lumen_app/di/di.dart';

/// Application bootstrap: the only composition point.
///
/// Assembles DI for [flavor], installs the global error funnel and runs the
/// app inside a guarded zone. Uncaught errors anywhere in the app end up in
/// the [Logger] port — never on the user's screen.
void bootstrap(AppFlavor flavor) {
  final container = ProviderContainer(overrides: overridesFor(flavor));
  final logger = container.read(loggerProvider);

  FlutterError.onError = (details) {
    logger.log(
      LogLevel.error,
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      // Seed the demo dataset in the background; screens render loading
      // states until the watched queries emit (stream-first, ADR-007).
      unawaited(
        container.read(seedDemoDataProvider).call().then(
              (result) => result.fold(
                onOk: (_) => logger.info('demo data ready'),
                onErr: (failure) =>
                    logger.error('seeding failed', error: failure),
              ),
            ),
      );

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const LumenApp(),
        ),
      );
    },
    (error, stackTrace) {
      logger.log(
        LogLevel.error,
        'Uncaught zone error',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
