import 'package:core_data/src/database/lumen_database.dart';
import 'package:core_data/src/mappers/row_mappers.dart';
import 'package:core_domain/core_domain.dart';
import 'package:drift/drift.dart';

/// Drift adapter for [BudgetRepository].
final class DriftBudgetRepository implements BudgetRepository {
  /// Creates the adapter over the database.
  const DriftBudgetRepository(this._db);

  final LumenDatabase _db;

  @override
  Stream<List<Budget>> watchBudgets() {
    final query = _db.select(_db.budgets)
      ..orderBy([(b) => OrderingTerm.asc(b.createdAt)]);
    return query.watch().map(
          (rows) => rows.map((row) => row.toEntity()).toList(),
        );
  }

  @override
  Future<Result<void>> upsertBudget(Budget budget) async {
    try {
      await _db.into(_db.budgets).insert(
            BudgetsCompanion.insert(
              id: budget.id.value,
              category: budget.category,
              limitMinor: budget.limit.minorUnits,
              currencyCode: budget.limit.currencyCode,
              anchorDay: budget.anchorDay,
              createdAt: budget.createdAt,
            ),
            onConflict: DoUpdate(
              (old) => BudgetsCompanion(
                limitMinor: Value(budget.limit.minorUnits),
                currencyCode: Value(budget.limit.currencyCode),
                anchorDay: Value(budget.anchorDay),
              ),
              target: [_db.budgets.category],
            ),
          );
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.err(StorageFailure('upsert budget failed: $e'));
    }
  }

  @override
  Future<Result<void>> deleteBudget(BudgetId id) async {
    try {
      await (_db.delete(_db.budgets)..where((b) => b.id.equals(id.value))).go();
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.err(StorageFailure('delete budget failed: $e'));
    }
  }
}
