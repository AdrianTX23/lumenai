import 'package:core_domain/src/value_objects/money.dart';

/// A projection of next period's spend, computed from trailing history.
final class CashflowForecast {
  /// Creates a forecast.
  const CashflowForecast({
    required this.periodStart,
    required this.projectedSpend,
    required this.monthsConsidered,
  });

  /// Start of the period being forecast.
  final DateTime periodStart;

  /// Projected spend magnitude (positive).
  final Money projectedSpend;

  /// How many trailing months fed the projection.
  final int monthsConsidered;
}
