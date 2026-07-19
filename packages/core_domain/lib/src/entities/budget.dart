import 'package:core_domain/src/value_objects/category.dart';
import 'package:core_domain/src/value_objects/identifiers.dart';
import 'package:core_domain/src/value_objects/money.dart';

/// A monthly spending envelope for one category.
final class Budget {
  /// Creates a budget.
  const Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.anchorDay,
    required this.createdAt,
  });

  /// Stable identifier.
  final BudgetId id;

  /// Budgeted category (one budget per category).
  final Category category;

  /// Monthly limit (always positive).
  final Money limit;

  /// Day the budget month starts on (salary-cycle aware, see `Period`).
  final int anchorDay;

  /// Creation moment.
  final DateTime createdAt;
}
