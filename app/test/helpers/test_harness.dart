import 'package:core_data/core_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_app/di/app_flavor.dart';
import 'package:lumen_app/di/di.dart';

/// A DI container over a seeded in-memory database. Disposal (and DB
/// close) is registered on the test's tear-down.
Future<ProviderContainer> seededTestContainer() async {
  final db = openInMemoryDatabase();
  final container = ProviderContainer(
    overrides: [
      flavorProvider.overrideWithValue(AppFlavor.dev),
      databaseProvider.overrideWithValue(db),
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
