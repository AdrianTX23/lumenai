import 'package:core_domain/src/entities/analytics.dart';
import 'package:core_domain/src/value_objects/period.dart';

/// Port: aggregated reads. Implementations MUST aggregate in the storage
/// engine (SQL), not in memory — analytics stays fast at years of data.
abstract interface class AnalyticsRepository {
  /// Total balance across accounts. Emits on any write.
  Stream<NetWorth> watchNetWorth();

  /// Spend per category within [period], largest first. Excludes income
  /// and transfers (see `Category.isSpending`).
  Stream<List<CategorySpend>> watchSpendingBreakdown(Period period);

  /// Income vs spend for the [months] windows ending at [anchor]
  /// (oldest first).
  Stream<List<CashflowEntry>> watchMonthlyCashflow({
    required Period anchor,
    required int months,
  });
}
