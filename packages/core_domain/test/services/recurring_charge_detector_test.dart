import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

Transaction _tx({
  required String id,
  required String merchant,
  required int amount,
  required Category category,
  required DateTime when,
}) {
  return Transaction(
    id: TransactionId(id),
    accountId: const AccountId('a1'),
    amount: Money.minor(amount, 'COP'),
    merchantName: merchant,
    merchantRaw: merchant.toUpperCase(),
    category: category,
    timestamp: when,
    status: TransactionStatus.settled,
    categorySource: CategorySource.rule,
  );
}

void main() {
  const detector = RecurringChargeDetector();

  group('RecurringChargeDetector', () {
    test('flags a merchant charging monthly with a stable amount', () {
      final txs = [
        for (var m = 0; m < 6; m++)
          _tx(
            id: 'netflix-$m',
            merchant: 'Netflix',
            amount: -26900,
            category: Category.subscriptions,
            when: DateTime(2026, 1 + m, 5),
          ),
      ];

      final insights = detector.detect(txs);

      expect(insights, hasLength(1));
      expect(insights.single.merchantName, 'Netflix');
      expect(insights.single.occurrences, 6);
      expect(insights.single.percentChange, 0);
      expect(insights.single.hasNotableChange, isFalse);
    });

    test('computes a positive percentChange when the charge grew', () {
      final txs = [
        for (var m = 0; m < 8; m++)
          _tx(
            id: 'netflix-$m',
            merchant: 'Netflix',
            amount: m < 4 ? -26900 : -33900,
            category: Category.subscriptions,
            when: DateTime(2026, 1 + m, 5),
          ),
      ];

      final insight = detector.detect(txs).single;

      expect(insight.firstAmount, const Money.minor(26900, 'COP'));
      expect(insight.latestAmount, const Money.minor(33900, 'COP'));
      expect(insight.percentChange, closeTo(26.02, 0.1));
      expect(insight.hasNotableChange, isTrue);
    });

    test('ignores merchants seen fewer than minOccurrences times', () {
      final txs = [
        _tx(
          id: '1',
          merchant: 'One-off Store',
          amount: -50000,
          category: Category.shopping,
          when: DateTime(2026, 1, 5),
        ),
        _tx(
          id: '2',
          merchant: 'One-off Store',
          amount: -50000,
          category: Category.shopping,
          when: DateTime(2026, 2, 5),
        ),
      ];

      expect(detector.detect(txs), isEmpty);
    });

    test('ignores charges whose interval is not roughly monthly', () {
      final txs = [
        for (var d = 0; d < 6; d++)
          _tx(
            id: 'groceries-$d',
            merchant: 'Éxito',
            amount: -80000,
            category: Category.groceries,
            when: DateTime(2026).add(Duration(days: d * 5)),
          ),
      ];

      expect(detector.detect(txs), isEmpty);
    });

    test(
        'ignores categories where repeat merchants are typically '
        'coincidence, even with a clean monthly cadence', () {
      // Same shape as a real subscription (stable amount, ~monthly gaps)
      // but dining is habit, not a bill — should not be flagged.
      final txs = [
        for (var m = 0; m < 6; m++)
          _tx(
            id: 'dining-$m',
            merchant: 'Crepes & Waffles',
            amount: -45000,
            category: Category.dining,
            when: DateTime(2026, 1 + m, 5),
          ),
      ];

      expect(detector.detect(txs), isEmpty);
    });

    test('excludes income and transfers even if they recur monthly', () {
      final txs = [
        for (var m = 0; m < 6; m++) ...[
          _tx(
            id: 'salary-$m',
            merchant: 'Tecnova',
            amount: 2100000,
            category: Category.income,
            when: DateTime(2026, 1 + m),
          ),
          _tx(
            id: 'cardpay-$m',
            merchant: 'Card payment',
            amount: -600000,
            category: Category.transfers,
            when: DateTime(2026, 1 + m, 28),
          ),
        ],
      ];

      expect(detector.detect(txs), isEmpty);
    });

    test('sorts results by most recently charged first', () {
      final txs = [
        for (var m = 0; m < 4; m++)
          _tx(
            id: 'netflix-$m',
            merchant: 'Netflix',
            amount: -26900,
            category: Category.subscriptions,
            when: DateTime(2026, 1 + m, 5),
          ),
        for (var m = 0; m < 4; m++)
          _tx(
            id: 'spotify-$m',
            merchant: 'Spotify',
            amount: -16900,
            category: Category.subscriptions,
            when: DateTime(2026, 1 + m, 20),
          ),
      ];

      final insights = detector.detect(txs);

      expect(insights.map((i) => i.merchantName), ['Spotify', 'Netflix']);
    });
  });
}
