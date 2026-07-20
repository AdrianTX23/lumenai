import 'package:core_domain/src/entities/subscription_insight.dart';
import 'package:core_domain/src/entities/transaction.dart';

/// Finds merchants that charge on a roughly monthly cadence.
///
/// Deterministic interval clustering, not machine learning: group spend
/// by merchant, sort by time, and check whether the median gap between
/// consecutive charges falls in a monthly window. This is transparent by
/// design — the AI copilot explains and converses, this is the code that
/// computes (docs/04-domain-model.md §5). Runs entirely in memory over
/// domain entities; no database involved, so it's trivially unit-tested.
final class RecurringChargeDetector {
  /// Creates a detector. [minOccurrences] guards against flagging a
  /// merchant seen only once or twice; [minIntervalDays]/
  /// [maxIntervalDays] define the "roughly monthly" window (a 30-day
  /// cadence drifts with weekends and billing-cycle quirks).
  const RecurringChargeDetector({
    this.minOccurrences = 3,
    this.minIntervalDays = 25,
    this.maxIntervalDays = 35,
  });

  /// Minimum charges required before a merchant is considered.
  final int minOccurrences;

  /// Lower bound of the monthly interval window, in days.
  final int minIntervalDays;

  /// Upper bound of the monthly interval window, in days.
  final int maxIntervalDays;

  /// Detects recurring charges in [transactions] (any order). Excludes
  /// income and transfers — a salary or a card payoff recurs monthly
  /// too, but neither is a "charge" in the sense a user would recognize
  /// — and to categories where repeat merchant charges are typically
  /// meaningful (`Category.isTypicallyRecurring`): interval clustering
  /// alone can't distinguish a real subscription from a habit of
  /// visiting the same grocery store on a similar schedule, so the
  /// category prior does that filtering instead. Result is sorted most-
  /// recently-active first.
  List<SubscriptionInsight> detect(List<Transaction> transactions) {
    final byMerchant = <String, List<Transaction>>{};
    for (final tx in transactions) {
      if (!tx.amount.isNegative ||
          !tx.category.isSpending ||
          !tx.category.isTypicallyRecurring) {
        continue;
      }
      (byMerchant[tx.merchantName] ??= []).add(tx);
    }

    final insights = <SubscriptionInsight>[];
    for (final entry in byMerchant.entries) {
      final charges = entry.value
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      if (charges.length < minOccurrences) continue;

      final intervals = [
        for (var i = 1; i < charges.length; i++)
          charges[i].timestamp.difference(charges[i - 1].timestamp).inDays,
      ];
      final medianInterval = _median(intervals);
      if (medianInterval < minIntervalDays ||
          medianInterval > maxIntervalDays) {
        continue;
      }

      final first = charges.first;
      final last = charges.last;
      final firstMagnitude = first.amount.minorUnits.abs();
      final lastMagnitude = last.amount.minorUnits.abs();
      final percentChange = firstMagnitude == 0
          ? 0.0
          : (lastMagnitude - firstMagnitude) / firstMagnitude * 100;

      insights.add(
        SubscriptionInsight(
          merchantName: entry.key,
          category: last.category,
          occurrences: charges.length,
          firstAmount: first.amount.abs(),
          latestAmount: last.amount.abs(),
          lastChargedAt: last.timestamp,
          percentChange: percentChange,
        ),
      );
    }

    insights.sort((a, b) => b.lastChargedAt.compareTo(a.lastChargedAt));
    return insights;
  }

  double _median(List<int> values) {
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid].toDouble();
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }
}
