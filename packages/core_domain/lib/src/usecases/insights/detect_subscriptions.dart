import 'package:core_domain/src/entities/subscription_insight.dart';
import 'package:core_domain/src/repositories/transaction_repository.dart';
import 'package:core_domain/src/services/recurring_charge_detector.dart';

/// Streams recurring-charge insights found in the full transaction
/// history.
final class DetectSubscriptions {
  /// Creates the use case.
  const DetectSubscriptions(this._transactions);

  final TransactionRepository _transactions;

  static const _detector = RecurringChargeDetector();

  /// A history window generous enough that recurrence detection never
  /// misses a charge because it fell outside the page.
  static const _historyLimit = 5000;

  /// Subscribes to detected recurring charges, most recently active
  /// first.
  Stream<List<SubscriptionInsight>> call() {
    return _transactions
        .watchTransactions(const TransactionFilter(limit: _historyLimit))
        .map(_detector.detect);
  }
}
