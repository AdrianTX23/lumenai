import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/repositories/seed_repository.dart';

/// Wipes and reseeds all data (settings screen).
final class ResetData {
  /// Creates the use case.
  const ResetData(this._seed);

  final SeedRepository _seed;

  /// Performs the reset.
  Future<Result<void>> call() => _seed.reset();
}
