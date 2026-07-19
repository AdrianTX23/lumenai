import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/repositories/budget_repository.dart';
import 'package:core_domain/src/value_objects/identifiers.dart';

/// Removes a budget.
final class DeleteBudget {
  /// Creates the use case.
  const DeleteBudget(this._budgets);

  final BudgetRepository _budgets;

  /// Deletes the budget [id].
  Future<Result<void>> call(BudgetId id) => _budgets.deleteBudget(id);
}
