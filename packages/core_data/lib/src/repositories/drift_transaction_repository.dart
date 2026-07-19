import 'package:core_data/src/database/lumen_database.dart';
import 'package:core_data/src/mappers/row_mappers.dart';
import 'package:core_domain/core_domain.dart';

/// Drift adapter for [TransactionRepository].
final class DriftTransactionRepository implements TransactionRepository {
  /// Creates the adapter over the database.
  const DriftTransactionRepository(this._db);

  final LumenDatabase _db;

  @override
  Stream<List<Transaction>> watchTransactions(TransactionFilter filter) {
    return _db
        .watchTransactionRows(filter)
        .map((rows) => rows.map((row) => row.toEntity()).toList());
  }

  @override
  Future<Result<void>> recategorize(
    TransactionId id,
    Category category,
    CategorySource source,
  ) async {
    try {
      final updated = await _db.updateCategory(id.value, category, source);
      if (updated == 0) {
        return Result.err(
          StorageFailure('transaction ${id.value} not found'),
        );
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.err(StorageFailure('recategorize failed: $e'));
    }
  }
}
