import 'package:core_domain/src/failures/result.dart';

/// Port: demo-data lifecycle.
abstract interface class SeedRepository {
  /// Seeds the deterministic demo dataset if the store is empty or the
  /// seed version changed. No-op otherwise.
  Future<Result<void>> seedIfNeeded();

  /// Wipes all data and reseeds.
  Future<Result<void>> reset();
}
