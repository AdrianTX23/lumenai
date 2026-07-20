import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart' hide Transaction;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Proves the "local algorithms find real anomalies" claim
/// (docs/04-domain-model.md §2) against the actual seed dataset, not a
/// synthetic fixture: seed the real engine, run the real detector
/// through the real repository, and check the planted Netflix price
/// increase surfaces with the right numbers.
void main() {
  final fixedNow = DateTime(2026, 7, 15, 12);
  const detector = RecurringChargeDetector();

  late LumenDatabase db;

  setUp(() async {
    db = LumenDatabase(NativeDatabase.memory());
    final seeded =
        await DriftSeedRepository(db, clock: () => fixedNow).seedIfNeeded();
    expect(seeded.isOk, isTrue);
  });

  tearDown(() async => db.close());

  test('detects the planted Netflix price increase from real seed data',
      () async {
    final transactionRepo = DriftTransactionRepository(db);
    final all = await transactionRepo
        .watchTransactions(const TransactionFilter(limit: 5000))
        .first;

    final insights = detector.detect(all);
    final netflix = insights.firstWhere((i) => i.merchantName == 'Netflix');

    expect(netflix.occurrences, SeedEngine.monthsOfHistory);
    expect(netflix.firstAmount, const Money.minor(26900, 'COP'));
    expect(netflix.latestAmount, const Money.minor(33900, 'COP'));
    expect(netflix.hasNotableChange, isTrue);
    expect(netflix.percentChange, closeTo(26.02, 0.1));
  });

  test('also detects stable recurring charges without flagging them', () async {
    final transactionRepo = DriftTransactionRepository(db);
    final all = await transactionRepo
        .watchTransactions(const TransactionFilter(limit: 5000))
        .first;

    final insights = detector.detect(all);
    final spotify = insights.firstWhere((i) => i.merchantName == 'Spotify');

    expect(spotify.hasNotableChange, isFalse);
    expect(spotify.percentChange, 0);
  });

  test('the DetectSubscriptions use case surfaces the same result', () async {
    final useCase = DetectSubscriptions(DriftTransactionRepository(db));

    final insights = await useCase().first;

    expect(
      insights.any((i) => i.merchantName == 'Netflix' && i.hasNotableChange),
      isTrue,
    );
  });

  test('ForecastCashflow use case projects from real cashflow history',
      () async {
    final analyticsRepo = DriftAnalyticsRepository(db);
    final useCase = ForecastCashflow(analyticsRepo);
    final anchor = Period.monthly(containing: fixedNow);

    final forecast = await useCase(anchor: anchor).first;

    expect(forecast, isNotNull);
    expect(forecast!.monthsConsidered, 6);
    expect(forecast.projectedSpend.isPositive, isTrue);
  });
}
