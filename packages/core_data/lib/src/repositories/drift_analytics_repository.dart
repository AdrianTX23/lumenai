import 'package:core_data/src/database/lumen_database.dart';
import 'package:core_domain/core_domain.dart';

/// Drift adapter for [AnalyticsRepository]. Aggregation happens in SQL;
/// this class only shapes rows into read models.
final class DriftAnalyticsRepository implements AnalyticsRepository {
  /// Creates the adapter for a single-currency dataset in
  /// [currencyCode].
  const DriftAnalyticsRepository(this._db, {String currencyCode = 'EUR'})
      : _currency = currencyCode;

  final LumenDatabase _db;
  final String _currency;

  @override
  Stream<NetWorth> watchNetWorth() {
    return _db.watchNetWorthMinor().map(
          (minor) => NetWorth(total: Money.minor(minor, _currency)),
        );
  }

  @override
  Stream<List<CategorySpend>> watchSpendingBreakdown(Period period) {
    return _db.watchSpendingBreakdown(period.start, period.end).map(
          (rows) => rows
              .map(
                (row) => CategorySpend(
                  category: row.$1,
                  total: Money.minor(row.$2, _currency),
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<CashflowEntry>> watchMonthlyCashflow({
    required Period anchor,
    required int months,
  }) {
    var period = anchor;
    final periods = <Period>[period];
    for (var i = 1; i < months; i++) {
      period = period.previous;
      periods.insert(0, period);
    }
    final windows = [for (final p in periods) (p.start, p.end)];

    return _db.watchCashflow(windows).map(
          (rows) => rows
              .map(
                (row) => CashflowEntry(
                  periodStart: row.$1,
                  income: Money.minor(row.$2, _currency),
                  spend: Money.minor(row.$3, _currency),
                ),
              )
              .toList(),
        );
  }
}
