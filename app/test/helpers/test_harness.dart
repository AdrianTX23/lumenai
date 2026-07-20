import 'package:core_data/core_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_app/di/app_flavor.dart';
import 'package:lumen_app/di/di.dart';

/// A DI container over a seeded in-memory database. Disposal (and DB
/// close) is registered on the test's tear-down.
///
/// [extraOverrides] are appended after the standard ones, so callers can
/// override providers (e.g. `copilotControllerProvider`) that depend on
/// state only known once the database is seeded.
Future<ProviderContainer> seededTestContainer({
  List<Override> extraOverrides = const [],
}) async {
  final db = openInMemoryDatabase();
  final container = ProviderContainer(
    overrides: [
      flavorProvider.overrideWithValue(AppFlavor.dev),
      databaseProvider.overrideWithValue(db),
      // Zero word-delay: the mock copilot's streaming cursor animates
      // forever while a message is in flight, so tests need the stream
      // to drain in a couple of pumps rather than racing real timers.
      copilotRepositoryProvider.overrideWith(
        (ref) => MockCopilotRepository(
          analytics: ref.watch(analyticsRepositoryProvider),
          transactions: ref.watch(transactionRepositoryProvider),
          wordDelay: Duration.zero,
        ),
      ),
      ...extraOverrides,
    ],
  );
  addTearDown(() async {
    container.dispose();
    await db.close();
  });

  final seeded = await container.read(seedDemoDataProvider)();
  expect(seeded.isOk, isTrue, reason: 'seeding must succeed');
  return container;
}
