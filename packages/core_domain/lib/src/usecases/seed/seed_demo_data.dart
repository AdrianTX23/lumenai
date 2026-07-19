import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/repositories/seed_repository.dart';

/// Ensures the demo dataset exists (bootstrap and dev flavor).
final class SeedDemoData {
  /// Creates the use case.
  const SeedDemoData(this._seed);

  final SeedRepository _seed;

  /// Seeds if the store is empty or outdated.
  Future<Result<void>> call() => _seed.seedIfNeeded();
}
