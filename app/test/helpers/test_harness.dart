import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_app/di/app_flavor.dart';
import 'package:lumen_app/di/di.dart';

/// Onboarding is always "done" in tests — `AppGateController` would
/// otherwise call the real `shared_preferences`-backed repository, whose
/// platform channel isn't mocked under `flutter test`.
final class _FakeOnboardingRepository implements OnboardingRepository {
  const _FakeOnboardingRepository();

  @override
  Future<bool> isCompleted() async => true;

  @override
  Future<void> markCompleted() async {}
}

/// App-lock is always "off" in tests, for the same reason —
/// `local_auth`/`flutter_secure_storage` have no test-mode platform
/// channel here, and no test in this suite exercises the real prompt.
final class _FakeAppLockRepository implements AppLockRepository {
  const _FakeAppLockRepository();

  @override
  Future<bool> isBiometricAvailable() async => false;

  @override
  Future<bool> isLockEnabled() async => false;

  @override
  Future<Result<void>> setLockEnabled({
    required bool enabled,
    required String reason,
  }) async =>
      const Result.ok(null);

  @override
  Future<Result<void>> authenticate({required String reason}) async =>
      const Result.ok(null);
}

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
      onboardingRepositoryProvider.overrideWithValue(
        const _FakeOnboardingRepository(),
      ),
      appLockRepositoryProvider.overrideWithValue(
        const _FakeAppLockRepository(),
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
