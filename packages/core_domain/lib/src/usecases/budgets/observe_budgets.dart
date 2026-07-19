import 'package:core_domain/src/entities/budget.dart';
import 'package:core_domain/src/repositories/budget_repository.dart';

/// Streams all budgets.
final class ObserveBudgets {
  /// Creates the use case.
  const ObserveBudgets(this._budgets);

  final BudgetRepository _budgets;

  /// Subscribes to the budget list.
  Stream<List<Budget>> call() => _budgets.watchBudgets();
}
