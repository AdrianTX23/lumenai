import 'package:core_data/src/database/lumen_database.dart';
import 'package:core_data/src/mappers/row_mappers.dart';
import 'package:core_domain/core_domain.dart';
import 'package:drift/drift.dart';

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

  @override
  Future<Result<void>> createTransaction(Transaction transaction) async {
    try {
      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              id: transaction.id.value,
              accountId: transaction.accountId.value,
              amountMinor: transaction.amount.minorUnits,
              currencyCode: transaction.amount.currencyCode,
              merchantName: transaction.merchantName,
              merchantRaw: transaction.merchantRaw,
              category: transaction.category,
              timestamp: transaction.timestamp,
              status: transaction.status,
              categorySource: transaction.categorySource,
              note: Value(transaction.note),
            ),
          );
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.err(StorageFailure('create transaction failed: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(TransactionId id) async {
    try {
      final deleted = await (_db.delete(
        _db.transactions,
      )..where((t) => t.id.equals(id.value)))
          .go();
      if (deleted == 0) {
        return Result.err(
          StorageFailure('transaction ${id.value} not found'),
        );
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.err(StorageFailure('delete transaction failed: $e'));
    }
  }
}
