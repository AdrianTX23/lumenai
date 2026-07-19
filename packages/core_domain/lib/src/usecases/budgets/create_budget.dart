import 'package:core_domain/src/entities/budget.dart';
import 'package:core_domain/src/failures/failure.dart';
import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/repositories/budget_repository.dart';

/// Validates and persists a budget. Business rules live HERE, not in
/// controllers: a positive limit, a budgetable category, a sane anchor.
final class CreateBudget {
  /// Creates the use case.
  const CreateBudget(this._budgets);

  final BudgetRepository _budgets;

  /// Validates [budget] and stores it (replacing any budget for the same
  /// category).
  Future<Result<void>> call(Budget budget) async {
    if (!budget.limit.isPositive) {
      return const Result.err(
        ValidationFailure('budget limit must be positive'),
      );
    }
    if (!budget.category.isSpending) {
      return const Result.err(
        ValidationFailure('income and transfers cannot be budgeted'),
      );
    }
    if (budget.anchorDay < 1 || budget.anchorDay > 31) {
      return const Result.err(
        ValidationFailure('anchor day must be between 1 and 31'),
      );
    }
    return _budgets.upsertBudget(budget);
  }
}
