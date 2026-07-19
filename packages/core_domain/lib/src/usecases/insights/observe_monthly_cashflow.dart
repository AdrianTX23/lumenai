import 'package:core_domain/src/entities/analytics.dart';
import 'package:core_domain/src/repositories/analytics_repository.dart';
import 'package:core_domain/src/value_objects/period.dart';

/// Streams income-vs-spend for the trailing months.
final class ObserveMonthlyCashflow {
  /// Creates the use case.
  const ObserveMonthlyCashflow(this._analytics);

  final AnalyticsRepository _analytics;

  /// Subscribes to [months] windows ending at [anchor], oldest first.
  Stream<List<CashflowEntry>> call({
    required Period anchor,
    int months = 6,
  }) =>
      _analytics.watchMonthlyCashflow(anchor: anchor, months: months);
}
