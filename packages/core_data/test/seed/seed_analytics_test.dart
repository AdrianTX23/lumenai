import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart' hide Transaction;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden-dataset test (Phase 2 exit criteria, docs/07-roadmap.md):
/// every SQL aggregation must return EXACTLY the values computed by an
/// independent in-memory fold over the same generated dataset. If SQL and
/// fold ever disagree, one of them is wrong — and the test says which
/// numbers diverged.
void main() {
  final fixedNow = DateTime(2026, 7, 15, 12);

  late LumenDatabase db;
  late DriftSeedRepository seedRepo;
  late DriftAnalyticsRepository analytics;
  late List<TransactionsCompanion> expectedTxs;
  late List<AccountsCompanion> expectedAccounts;

  setUp(() async {
    db = LumenDatabase(NativeDatabase.memory());
    seedRepo = DriftSeedRepository(db, clock: () => fixedNow);
    analytics = DriftAnalyticsRepository(db);

    final engine = SeedEngine(now: fixedNow);
    expectedAccounts = engine.accounts();
    expectedTxs = engine.transactions();

    final seeded = await seedRepo.seedIfNeeded();
    expect(seeded.isOk, isTrue);
  });

  tearDown(() async => db.close());

  group('SeedEngine determinism', () {
    test('same clock and seed produce byte-identical output', () {
      final a = SeedEngine(now: fixedNow).transactions();
      final b = SeedEngine(now: fixedNow).transactions();

      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].id.value, b[i].id.value);
        expect(a[i].amountMinor.value, b[i].amountMinor.value);
        expect(a[i].timestamp.value, b[i].timestamp.value);
      }
    });

    test('volume is in the designed range and nothing is in the future', () {
      expect(expectedTxs.length, inInclusiveRange(600, 1200));
      for (final tx in expectedTxs) {
        expect(tx.timestamp.value.isAfter(fixedNow), isFalse);
      }
    });

    test('planted anomalies exist: Netflix raise and duplicate gym charge', () {
      final netflix =
          expectedTxs.where((t) => t.merchantName.value == 'Netflix').toList();
      expect(netflix, hasLength(SeedEngine.monthsOfHistory));
      expect(netflix.first.amountMinor.value, -26900);
      expect(netflix.last.amountMinor.value, -33900);

      final gym = expectedTxs
          .where((t) => t.merchantName.value == 'Smart Fit')
          .toList();
      final byDay = <String, int>{};
      for (final g in gym) {
        final day = g.timestamp.value.toIso8601String().substring(0, 10);
        byDay[day] = (byDay[day] ?? 0) + 1;
      }
      expect(
        byDay.values.where((count) => count == 2),
        hasLength(1),
        reason: 'exactly one duplicated gym charge',
      );
    });

    test('quincena salary lands twice every month', () {
      final salaries =
          expectedTxs.where((t) => t.category.value == Category.income);
      // Fixed clock is July 15: the second quincena of the current month
      // (day 16) is still in the future and must not be emitted.
      expect(
        salaries,
        hasLength(
          SeedEngine.monthsOfHistory * SeedEngine.salariesPerMonth - 1,
        ),
      );
    });
  });

  group('SQL aggregations vs independent fold', () {
    test('net worth matches exactly', () async {
      final foldOpening = expectedAccounts.fold<int>(
        0,
        (sum, a) => sum + a.openingBalanceMinor.value,
      );
      final foldTx = expectedTxs.fold<int>(
        0,
        (sum, t) => sum + t.amountMinor.value,
      );

      final netWorth = await analytics.watchNetWorth().first;

      expect(netWorth.total.minorUnits, foldOpening + foldTx);
      expect(netWorth.total.currencyCode, 'COP');
    });

    test('spending breakdown for the current period matches exactly', () async {
      final period = Period.monthly(containing: fixedNow);
      final fold = <Category, int>{};
      for (final t in expectedTxs) {
        final category = t.category.value;
        final ts = t.timestamp.value;
        if (t.amountMinor.value < 0 &&
            category.isSpending &&
            period.contains(ts)) {
          fold[category] = (fold[category] ?? 0) - t.amountMinor.value;
        }
      }

      final breakdown = await analytics.watchSpendingBreakdown(period).first;
      final sql = {
        for (final entry in breakdown) entry.category: entry.total.minorUnits,
      };

      expect(sql, fold);
      // Largest spender first.
      final totals = breakdown.map((e) => e.total.minorUnits).toList();
      final descending = [...totals]..sort();
      expect(totals, orderedEquals(descending.reversed));
    });

    test('6-month cashflow matches exactly, oldest first', () async {
      final anchor = Period.monthly(containing: fixedNow);
      final periods = <Period>[anchor];
      for (var i = 1; i < 6; i++) {
        periods.insert(0, periods.first.previous);
      }

      final entries =
          await analytics.watchMonthlyCashflow(anchor: anchor, months: 6).first;

      expect(entries, hasLength(6));
      for (var i = 0; i < 6; i++) {
        final period = periods[i];
        var income = 0;
        var spend = 0;
        for (final t in expectedTxs) {
          if (t.category.value == Category.transfers) continue;
          if (!period.contains(t.timestamp.value)) continue;
          final amount = t.amountMinor.value;
          if (amount > 0) income += amount;
          if (amount < 0) spend -= amount;
        }
        expect(entries[i].periodStart, period.start);
        expect(
          entries[i].income.minorUnits,
          income,
          reason: 'income for window $i',
        );
        expect(
          entries[i].spend.minorUnits,
          spend,
          reason: 'spend for window $i',
        );
      }
    });
  });

  group('Seed lifecycle', () {
    test('seedIfNeeded is idempotent for the same version', () async {
      final before = await db.select(db.transactions).get();

      final again = await seedRepo.seedIfNeeded();

      expect(again.isOk, isTrue);
      final after = await db.select(db.transactions).get();
      expect(after.length, before.length);
    });

    test('reset wipes and reseeds deterministically', () async {
      // Mutate: recategorize one row, then reset must restore it.
      await DriftTransactionRepository(db).recategorize(
        const TransactionId('tx-00001'),
        Category.other,
        CategorySource.user,
      );

      final result = await seedRepo.reset();

      expect(result.isOk, isTrue);
      final row = await (db.select(db.transactions)
            ..where((t) => t.id.equals('tx-00001')))
          .getSingle();
      expect(row.category, isNot(Category.other));
    });
  });
}
