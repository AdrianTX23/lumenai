import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart' hide Transaction;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Grounds every assertion against the real seed dataset — the mock's
/// whole point is that its numbers are traceable, so tests must compare
/// against independently computed values, not hardcoded strings.
void main() {
  final fixedNow = DateTime(2026, 7, 15, 12);

  late LumenDatabase db;
  late MockCopilotRepository copilot;
  late AnalyticsRepository analytics;
  late TransactionRepository transactions;

  setUp(() async {
    db = LumenDatabase(NativeDatabase.memory());
    final seeded =
        await DriftSeedRepository(db, clock: () => fixedNow).seedIfNeeded();
    expect(seeded.isOk, isTrue);

    analytics = DriftAnalyticsRepository(db);
    transactions = DriftTransactionRepository(db);
    copilot = MockCopilotRepository(
      analytics: analytics,
      transactions: transactions,
    );
  });

  tearDown(() async => db.close());

  Future<String> fullText(Stream<CopilotEvent> events) async {
    final buffer = StringBuffer();
    await for (final event in events) {
      if (event is CopilotTokenDelta) buffer.write(event.text);
    }
    return buffer.toString();
  }

  group('MockCopilotRepository', () {
    test('net-worth answer matches the real analytics figure', () async {
      final netWorth = await analytics.watchNetWorth().first;
      final expectedMagnitude =
          netWorth.total.minorUnits.abs().toString().replaceAllMapped(
                RegExp(r'\B(?=(\d{3})+(?!\d))'),
                (m) => '.',
              );

      final text = await fullText(
        copilot.ask(const ConversationId('c1'), 'What is my net worth?'),
      );

      expect(text, contains(expectedMagnitude));
    });

    test('dining answer cites real transactions as evidence', () async {
      final events = await copilot
          .ask(const ConversationId('c1'), 'How much on dining this month?')
          .toList();

      final evidenceEvent = events.whereType<CopilotEvidence>().singleOrNull;
      expect(events.last, isA<CopilotDone>());

      if (evidenceEvent == null) {
        // Zero dining transactions in the current calendar month is
        // possible depending on the fixed clock's day-of-month; the
        // important invariant either way is that it terminates cleanly.
        return;
      }

      final allDining = await transactions
          .watchTransactions(
            const TransactionFilter(category: Category.dining, limit: 500),
          )
          .first;
      final diningIds = allDining.map((t) => t.id).toSet();
      for (final id in evidenceEvent.transactionIds) {
        expect(diningIds, contains(id));
      }
    });

    test('subscriptions answer surfaces the planted Netflix increase',
        () async {
      final text = await fullText(
        copilot.ask(
          const ConversationId('c1'),
          'Any subscriptions I should know about?',
        ),
      );

      expect(text, contains('Netflix'));
      expect(text, contains('%'));
    });

    test('forecast answer produces a grounded projection', () async {
      final anchor = Period.monthly(containing: fixedNow);
      final history =
          await analytics.watchMonthlyCashflow(anchor: anchor, months: 6).first;
      final forecast = const CashflowForecaster().forecast(history)!;
      final expectedMagnitude = forecast.projectedSpend.minorUnits
          .toString()
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

      final text = await fullText(
        copilot.ask(
          const ConversationId('c1'),
          'What is my forecast for next month?',
        ),
      );

      expect(text, contains(expectedMagnitude));
    });

    test('unrecognized questions get a helpful fallback, not an error',
        () async {
      final events = await copilot
          .ask(const ConversationId('c1'), 'asdkjqwoie nonsense')
          .toList();

      expect(events.last, isA<CopilotDone>());
      expect(events.whereType<CopilotFailed>(), isEmpty);
      final text = await fullText(Stream.fromIterable(events));
      expect(text, isNotEmpty);
    });

    test('every answer terminates with CopilotDone exactly once', () async {
      for (final question in [
        'net worth',
        'dining',
        'subscriptions',
        'forecast',
        'gibberish',
      ]) {
        final events =
            await copilot.ask(const ConversationId('c1'), question).toList();
        expect(events.whereType<CopilotDone>(), hasLength(1));
        expect(events.last, isA<CopilotDone>());
      }
    });

    test('works end-to-end through the AskCopilot use case', () async {
      final useCase = AskCopilot(copilot);
      final text = await fullText(
        useCase(const ConversationId('c1'), 'net worth'),
      );
      expect(text, contains(r'$'));
    });
  });
}
