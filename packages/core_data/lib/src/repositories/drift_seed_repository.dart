import 'package:core_data/src/database/lumen_database.dart';
import 'package:core_data/src/seed/seed_engine.dart';
import 'package:core_domain/core_domain.dart';

/// Drift adapter for [SeedRepository].
final class DriftSeedRepository implements SeedRepository {
  /// Creates the adapter. [clock] is injectable for deterministic tests.
  DriftSeedRepository(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final LumenDatabase _db;
  final DateTime Function() _clock;

  static const _versionKey = 'seed_version';

  @override
  Future<Result<void>> seedIfNeeded() async {
    try {
      final meta = await (_db.select(_db.appMeta)
            ..where((m) => m.key.equals(_versionKey)))
          .getSingleOrNull();
      if (meta?.value == SeedEngine.version) {
        return const Result.ok(null);
      }
      await _seed();
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.err(StorageFailure('seeding failed: $e'));
    }
  }

  @override
  Future<Result<void>> reset() async {
    try {
      await _seed();
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.err(StorageFailure('reset failed: $e'));
    }
  }

  Future<void> _seed() async {
    final engine = SeedEngine(now: _clock());
    final accounts = engine.accounts();
    final transactions = engine.transactions();

    await _db.transaction(() async {
      await _db.wipe();
      await _db.batch((batch) {
        batch
          ..insertAll(_db.accounts, accounts)
          ..insertAll(_db.transactions, transactions)
          ..insert(
            _db.appMeta,
            AppMetaCompanion.insert(
              key: _versionKey,
              value: SeedEngine.version,
            ),
          );
      });
    });
  }
}
