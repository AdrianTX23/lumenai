import 'package:core_domain/src/value_objects/category.dart';
import 'package:core_domain/src/value_objects/money.dart';

/// Total balance across all accounts.
final class NetWorth {
  /// Creates a net-worth reading.
  const NetWorth({required this.total});

  /// Sum of all account balances.
  final Money total;
}

/// Spend total for one category within a period.
final class CategorySpend {
  /// Creates a category spend entry.
  const CategorySpend({required this.category, required this.total});

  /// The category.
  final Category category;

  /// Total spent (positive magnitude).
  final Money total;
}

/// Income vs spend for one month-anchored window.
final class CashflowEntry {
  /// Creates a cashflow entry.
  const CashflowEntry({
    required this.periodStart,
    required this.income,
    required this.spend,
  });

  /// Start of the window.
  final DateTime periodStart;

  /// Total inflows (positive).
  final Money income;

  /// Total outflows (positive magnitude).
  final Money spend;
}
