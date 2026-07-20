import 'package:core_domain/src/entities/cashflow_forecast.dart';
import 'package:core_domain/src/repositories/analytics_repository.dart';
import 'package:core_domain/src/services/cashflow_forecaster.dart';
import 'package:core_domain/src/value_objects/period.dart';

/// Streams a projection of next period's spend from trailing history.
final class ForecastCashflow {
  /// Creates the use case.
  const ForecastCashflow(this._analytics);

  final AnalyticsRepository _analytics;

  static const _forecaster = CashflowForecaster();

  /// Subscribes to the forecast computed from [months] windows ending
  /// at [anchor].
  Stream<CashflowForecast?> call({required Period anchor, int months = 6}) {
    return _analytics
        .watchMonthlyCashflow(anchor: anchor, months: months)
        .map(_forecaster.forecast);
  }
}
