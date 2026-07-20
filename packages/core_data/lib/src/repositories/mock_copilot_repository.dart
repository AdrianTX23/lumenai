import 'package:core_domain/core_domain.dart';

/// Dev/demo/test adapter for [CopilotRepository].
///
/// Not a language model — a small keyword router over the same local use
/// cases the rest of the app uses (spending breakdown, recurring-charge
/// detection, cashflow forecast), so every number it says is real and
/// traceable to the ledger. This lets the entire copilot UI (streaming
/// bubbles, evidence highlighting, insight cards) get built and
/// golden-tested before the AI proxy exists (docs/05-backend-and-ai.md
/// §3). The real answers a live model would give are more capable and
/// more natural — this adapter's job is UX plumbing, not conversation
/// quality.
final class MockCopilotRepository implements CopilotRepository {
  /// Creates the mock, reading from the same repositories the rest of
  /// the app is wired to. [wordDelay] paces the simulated streaming —
  /// tests inject `Duration.zero` so a conversation drains in a couple
  /// of pumps instead of racing real timers against a fake clock.
  const MockCopilotRepository({
    required AnalyticsRepository analytics,
    required TransactionRepository transactions,
    this.wordDelay = const Duration(milliseconds: 40),
  })  : _analytics = analytics,
        _transactions = transactions;

  final AnalyticsRepository _analytics;
  final TransactionRepository _transactions;

  /// Delay between simulated streamed words.
  final Duration wordDelay;

  static const _detector = RecurringChargeDetector();

  static const _categoryKeywords = {
    Category.dining: ['dining', 'restaurant', 'comida', 'restaurantes'],
    Category.groceries: ['grocer', 'supermercado', 'mercado'],
    Category.transport: ['transport', 'uber', 'taxi', 'transmilenio'],
    Category.entertainment: ['entertainment', 'ocio', 'cine'],
    Category.shopping: ['shopping', 'compras'],
  };

  /// Spanish category labels — the answer prose is Spanish-only, so this
  /// can't reach into `core_l10n` (which core_data may not depend on)
  /// for the app's real ARB translations.
  static const _categoryLabels = {
    Category.groceries: 'supermercado',
    Category.dining: 'restaurantes',
    Category.transport: 'transporte',
    Category.subscriptions: 'suscripciones',
    Category.housing: 'vivienda',
    Category.utilities: 'suministros',
    Category.health: 'salud',
    Category.shopping: 'compras',
    Category.travel: 'viajes',
    Category.entertainment: 'ocio',
    Category.income: 'ingresos',
    Category.transfers: 'transferencias',
    Category.fees: 'comisiones',
    Category.other: 'otros',
  };

  @override
  Stream<CopilotEvent> ask(ConversationId conversationId, String question) {
    final normalized = question.toLowerCase();

    if (_matchesAny(normalized, const [
      'net worth',
      'patrimonio',
      'balance',
      'how much do i have',
      'cuánto tengo',
    ])) {
      return _answerNetWorth();
    }
    if (_matchesAny(normalized, const [
      'subscription',
      'suscri',
      'recurring',
      'recurrente',
      'netflix',
    ])) {
      return _answerSubscriptions();
    }
    if (_matchesAny(normalized, const [
      'forecast',
      'next month',
      'próximo mes',
      'proximo mes',
      'project',
    ])) {
      return _answerForecast();
    }
    for (final entry in _categoryKeywords.entries) {
      if (_matchesAny(normalized, entry.value)) {
        return _answerCategorySpend(entry.key);
      }
    }
    return _answerFallback();
  }

  bool _matchesAny(String haystack, List<String> needles) =>
      needles.any(haystack.contains);

  Stream<CopilotEvent> _answerNetWorth() async* {
    final netWorth = await _analytics.watchNetWorth().first;
    yield* _typeOut(
      'Tu patrimonio total en este momento es ${_formatCop(netWorth.total)}.',
    );
  }

  Stream<CopilotEvent> _answerCategorySpend(Category category) async* {
    final period = Period.monthly(containing: DateTime.now());
    final breakdown = await _analytics.watchSpendingBreakdown(period).first;

    var total = const Money.zero('COP');
    for (final entry in breakdown) {
      if (entry.category == category) {
        total = entry.total;
        break;
      }
    }

    final categoryTxs = await _transactions
        .watchTransactions(
          TransactionFilter(category: category, limit: 500),
        )
        .first;
    final thisPeriod =
        categoryTxs.where((t) => period.contains(t.timestamp)).toList();

    final label = _categoryLabels[category] ?? category.name;
    final text = thisPeriod.isEmpty
        ? 'No has gastado nada en $label este mes.'
        : 'Has gastado ${_formatCop(total)} en $label este mes, en '
            '${thisPeriod.length} '
            '${thisPeriod.length == 1 ? 'transacción' : 'transacciones'}.';

    yield* _typeOut(text, evidence: thisPeriod.map((t) => t.id).toList());
  }

  Stream<CopilotEvent> _answerSubscriptions() async* {
    final all = await _transactions
        .watchTransactions(const TransactionFilter(limit: 5000))
        .first;
    final insights = _detector.detect(all);

    if (insights.isEmpty) {
      yield* _typeOut(
        'Todavía no encuentro cargos recurrentes — vuelve a preguntar '
        'cuando tengas más meses de historial.',
      );
      return;
    }

    final changed = insights.where((i) => i.hasNotableChange).toList()
      ..sort(
        (a, b) => b.percentChange.abs().compareTo(a.percentChange.abs()),
      );
    final buffer = StringBuffer();
    if (changed.isNotEmpty) {
      final biggest = changed.first;
      buffer.write(
        'Atención — ${biggest.merchantName} pasó de '
        '${_formatCop(biggest.firstAmount)} a '
        '${_formatCop(biggest.latestAmount)}, un aumento del '
        '${biggest.percentChange.abs().round()}%. ',
      );
    }
    buffer.write(
      'Tengo ${insights.length} cargo'
      "${insights.length == 1 ? '' : 's'} recurrente"
      "${insights.length == 1 ? '' : 's'} detectado"
      "${insights.length == 1 ? '' : 's'} hasta ahora.",
    );

    final evidence = <TransactionId>[];
    for (final insight in insights.take(5)) {
      for (final tx in all) {
        if (tx.merchantName == insight.merchantName) {
          evidence.add(tx.id);
          break;
        }
      }
    }

    yield* _typeOut(buffer.toString(), evidence: evidence);
  }

  Stream<CopilotEvent> _answerForecast() async* {
    final anchor = Period.monthly(containing: DateTime.now());
    final history =
        await _analytics.watchMonthlyCashflow(anchor: anchor, months: 6).first;
    final forecast = const CashflowForecaster().forecast(history);

    if (forecast == null) {
      yield* _typeOut(
        'Necesito un poco más de historial antes de poder proyectar el '
        'próximo mes.',
      );
      return;
    }
    yield* _typeOut(
      'Con base en tus últimos ${forecast.monthsConsidered} meses, '
      'esperaría cerca de ${_formatCop(forecast.projectedSpend)} en gastos '
      'para el próximo mes.',
    );
  }

  Stream<CopilotEvent> _answerFallback() => _typeOut(
        'Puedo ayudarte con cosas como el gasto por categoría, tus cargos '
        'recurrentes o un pronóstico para el próximo mes — intenta '
        'preguntar sobre alguno de esos temas.',
      );

  /// Splits [text] into words and yields one [CopilotTokenDelta] per word
  /// with a small delay, mimicking a live model's streaming cadence, then
  /// [evidence] (if any) and a closing [CopilotDone].
  Stream<CopilotEvent> _typeOut(
    String text, {
    List<TransactionId> evidence = const [],
  }) async* {
    final words = text.split(' ');
    for (var i = 0; i < words.length; i++) {
      await Future<void>.delayed(wordDelay);
      yield CopilotTokenDelta(i == 0 ? words[i] : ' ${words[i]}');
    }
    if (evidence.isNotEmpty) {
      yield CopilotEvidence(evidence);
    }
    yield const CopilotDone();
  }

  /// Minimal COP prose formatting (leading symbol, dot-grouped thousands).
  /// The mock's own concern — real UI amounts always render through
  /// `LdsMoneyFormat`, which core_data may not depend on.
  String _formatCop(Money money) {
    final magnitude = money.minorUnits.abs();
    final grouped = magnitude.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
    final sign = money.minorUnits < 0 ? '-' : '';
    return '$sign\$ $grouped';
  }
}
