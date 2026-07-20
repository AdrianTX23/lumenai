import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/common/period_providers.dart';
import 'package:lumen_app/di/di.dart';

/// Category spend for the current period, largest first.
final spendingBreakdownProvider = StreamProvider<List<CategorySpend>>((ref) {
  final period = ref.watch(currentPeriodProvider);
  return ref.watch(observeSpendingBreakdownProvider)(period);
});

/// Income vs. spend for the trailing 6 months.
final monthlyCashflowProvider = StreamProvider<List<CashflowEntry>>((ref) {
  final period = ref.watch(currentPeriodProvider);
  return ref.watch(observeMonthlyCashflowProvider)(anchor: period);
});

/// Detected recurring charges, most recently active first.
final subscriptionsProvider = StreamProvider<List<SubscriptionInsight>>(
  (ref) => ref.watch(detectSubscriptionsProvider)(),
);

/// Projected spend for next period, from trailing history.
final cashflowForecastProvider = StreamProvider<CashflowForecast?>((ref) {
  final period = ref.watch(currentPeriodProvider);
  return ref.watch(forecastCashflowProvider)(anchor: period);
});
