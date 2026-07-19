import 'package:core_domain/src/entities/budget.dart';
import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/value_objects/identifiers.dart';

/// Port: budget storage.
abstract interface class BudgetRepository {
  /// All budgets. Emits on any budget write.
  Stream<List<Budget>> watchBudgets();

  /// Persists [budget] (one per category — replaces an existing one).
  Future<Result<void>> upsertBudget(Budget budget);

  /// Removes the budget [id].
  Future<Result<void>> deleteBudget(BudgetId id);
}
