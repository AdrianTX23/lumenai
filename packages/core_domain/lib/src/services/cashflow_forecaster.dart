import 'package:core_domain/src/entities/analytics.dart';
import 'package:core_domain/src/entities/cashflow_forecast.dart';
import 'package:core_domain/src/value_objects/money.dart';

/// Projects next period's spend from trailing history.
///
/// Trailing-median burn rate: robust to one unusually expensive or cheap
/// month (a holiday, a one-off purchase) in a way a plain average isn't
/// — a single outlier shifts a median by at most one rank, but can drag
/// a mean arbitrarily far. Deterministic and explainable — no model,
/// just arithmetic on the months the user actually lived through
/// (docs/04-domain-model.md §2).
final class CashflowForecaster {
  /// Creates a forecaster.
  const CashflowForecaster();

  /// Forecasts the period after the last entry in [history] (oldest
  /// first, as returned by `ObserveMonthlyCashflow`). Returns `null`
  /// when there's no history to project from.
  CashflowForecast? forecast(List<CashflowEntry> history) {
    if (history.isEmpty) return null;

    final currency = history.last.spend.currencyCode;
    final spends = history.map((e) => e.spend.minorUnits).toList()..sort();
    final medianSpend = _median(spends);

    final lastPeriodStart = history.last.periodStart;
    final nextPeriodStart = DateTime(
      lastPeriodStart.year,
      lastPeriodStart.month + 1,
      lastPeriodStart.day,
    );

    return CashflowForecast(
      periodStart: nextPeriodStart,
      projectedSpend: Money.minor(medianSpend, currency),
      monthsConsidered: history.length,
    );
  }

  int _median(List<int> sortedValues) {
    final mid = sortedValues.length ~/ 2;
    if (sortedValues.length.isOdd) return sortedValues[mid];
    return ((sortedValues[mid - 1] + sortedValues[mid]) / 2).round();
  }
}
