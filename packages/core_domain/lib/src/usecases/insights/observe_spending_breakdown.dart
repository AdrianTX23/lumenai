import 'package:core_domain/src/entities/analytics.dart';
import 'package:core_domain/src/repositories/analytics_repository.dart';
import 'package:core_domain/src/value_objects/period.dart';

/// Streams spend-per-category for a period, largest first.
final class ObserveSpendingBreakdown {
  /// Creates the use case.
  const ObserveSpendingBreakdown(this._analytics);

  final AnalyticsRepository _analytics;

  /// Subscribes to the breakdown of [period].
  Stream<List<CategorySpend>> call(Period period) =>
      _analytics.watchSpendingBreakdown(period);
}
