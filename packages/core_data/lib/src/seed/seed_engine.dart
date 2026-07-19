import 'dart:math';

import 'package:core_data/src/database/lumen_database.dart';
import 'package:core_domain/core_domain.dart' hide Transaction;
import 'package:drift/drift.dart';

/// Deterministic demo dataset: ~18 months of realistic financial life.
///
/// Same `now` + same seed → byte-identical output, so screenshots, demo
/// videos and the analytics golden tests never drift. The data plants two
/// anomalies on purpose for the insights/AI features to find:
///  1. Netflix price rises from 12.99 to 14.99 in the 6 most recent months.
///  2. A duplicated gym charge (same day, same amount) two months ago.
final class SeedEngine {
  /// Creates an engine generating relative to [now].
  SeedEngine({required DateTime now, int seed = 20260718})
      : _now = DateTime(now.year, now.month, now.day, now.hour),
        _rng = Random(seed);

  final DateTime _now;
  final Random _rng;
  int _txCounter = 0;

  /// Dataset version — bump to force a reseed on app update.
  static const version = '1';

  static const _currency = 'EUR';
  static const _mainId = 'acc-main';
  static const _savingsId = 'acc-savings';
  static const _creditId = 'acc-credit';

  /// Number of full months of history.
  static const monthsOfHistory = 18;

  /// The three demo accounts.
  List<AccountsCompanion> accounts() {
    return [
      AccountsCompanion.insert(
        id: _mainId,
        name: 'Lumen Current',
        type: AccountType.checking,
        currencyCode: _currency,
        openingBalanceMinor: 84000,
        cardLast4: const Value('4821'),
        cardNetwork: const Value('Visa'),
        cardSkinIndex: const Value(0),
      ),
      AccountsCompanion.insert(
        id: _savingsId,
        name: 'Rainy Day',
        type: AccountType.savings,
        currencyCode: _currency,
        openingBalanceMinor: 800000,
      ),
      AccountsCompanion.insert(
        id: _creditId,
        name: 'Lumen Card',
        type: AccountType.credit,
        currencyCode: _currency,
        openingBalanceMinor: 0,
        cardLast4: const Value('9034'),
        cardNetwork: const Value('Mastercard'),
        cardSkinIndex: const Value(2),
      ),
    ];
  }

  /// All transactions, oldest first. Nothing after `now` is emitted.
  List<TransactionsCompanion> transactions() {
    final all = <TransactionsCompanion>[];
    for (var monthsAgo = monthsOfHistory - 1; monthsAgo >= 0; monthsAgo--) {
      final monthStart = DateTime(_now.year, _now.month - monthsAgo);
      all.addAll(_month(monthStart, monthsAgo));
    }
    all.sort(
      (a, b) => a.timestamp.value.compareTo(b.timestamp.value),
    );
    return all;
  }

  List<TransactionsCompanion> _month(DateTime monthStart, int monthsAgo) {
    final txs = <TransactionsCompanion>[
      // Salary — the heartbeat of the dataset.
      _tx(
        account: _mainId,
        amount: 245000,
        raw: 'NOMINA ACME CORP SL',
        name: 'Acme Corp',
        category: Category.income,
        day: monthStart.copyWith(day: 1, hour: 9),
      ),
      // Rent.
      _tx(
        account: _mainId,
        amount: -95000,
        raw: 'RECIBO ALQUILER C/LUNA 12',
        name: 'Alquiler C/Luna',
        category: Category.housing,
        day: monthStart.copyWith(day: 2, hour: 8),
      ),
      // Savings sweep (transfer pair — excluded from spend analytics).
      _tx(
        account: _mainId,
        amount: -30000,
        raw: 'TRASPASO A RAINY DAY',
        name: 'Transfer to savings',
        category: Category.transfers,
        day: monthStart.copyWith(day: 2, hour: 10),
      ),
      _tx(
        account: _savingsId,
        amount: 30000,
        raw: 'TRASPASO DESDE LUMEN CURRENT',
        name: 'Transfer from current',
        category: Category.transfers,
        day: monthStart.copyWith(day: 2, hour: 10),
      ),
      // Subscriptions — Netflix price increase planted 6 months ago.
      _tx(
        account: _creditId,
        amount: monthsAgo < 6 ? -1499 : -1299,
        raw: 'NETFLIX.COM 866-579-7172',
        name: 'Netflix',
        category: Category.subscriptions,
        day: monthStart.copyWith(day: 5, hour: 12),
      ),
      _tx(
        account: _creditId,
        amount: -999,
        raw: 'PAYPAL *SPOTIFY',
        name: 'Spotify',
        category: Category.subscriptions,
        day: monthStart.copyWith(day: 7, hour: 12),
      ),
      _tx(
        account: _creditId,
        amount: -299,
        raw: 'APPLE.COM/BILL ICLOUD 50GB',
        name: 'Apple',
        category: Category.subscriptions,
        day: monthStart.copyWith(day: 3, hour: 7),
      ),
      _tx(
        account: _creditId,
        amount: -499,
        raw: 'AMZN PRIME ES*MEMBERSHIP',
        name: 'Amazon',
        category: Category.subscriptions,
        day: monthStart.copyWith(day: 9, hour: 6),
      ),
      _tx(
        account: _creditId,
        amount: -899,
        raw: 'MAX.COM STREAMING',
        name: 'Max',
        category: Category.subscriptions,
        day: monthStart.copyWith(day: 11, hour: 13),
      ),
      // Gym — duplicated two months ago (planted anomaly #2).
      _tx(
        account: _mainId,
        amount: -2990,
        raw: 'BASIC-FIT SPAIN SAU',
        name: 'Basic-Fit',
        category: Category.health,
        day: monthStart.copyWith(day: 4, hour: 7),
      ),
      if (monthsAgo == 2)
        _tx(
          account: _mainId,
          amount: -2990,
          raw: 'BASIC-FIT SPAIN SAU',
          name: 'Basic-Fit',
          category: Category.health,
          day: monthStart.copyWith(day: 4, hour: 7, minute: 2),
        ),
      // Utilities.
      _tx(
        account: _mainId,
        amount: -(4500 + _rng.nextInt(4000)),
        raw: 'IBERDROLA CLIENTES SAU',
        name: 'Iberdrola',
        category: Category.utilities,
        day: monthStart.copyWith(day: 15, hour: 8),
      ),
      _tx(
        account: _mainId,
        amount: -3499,
        raw: 'VODAFONE ESPANA SAU',
        name: 'Vodafone',
        category: Category.utilities,
        day: monthStart.copyWith(day: 17, hour: 8),
      ),
      // Credit card payoff (transfer pair).
      _tx(
        account: _mainId,
        amount: -25000,
        raw: 'PAGO TARJETA LUMEN CARD',
        name: 'Card payment',
        category: Category.transfers,
        day: monthStart.copyWith(day: 28, hour: 9),
      ),
      _tx(
        account: _creditId,
        amount: 25000,
        raw: 'PAGO RECIBIDO — GRACIAS',
        name: 'Card payment',
        category: Category.transfers,
        day: monthStart.copyWith(day: 28, hour: 9),
      ),
      // Groceries: 10–13 visits/month.
      ..._spray(
        monthStart,
        count: 10 + _rng.nextInt(4),
        merchants: const [
          ('MERCADONA C/VALENCIA', 'Mercadona'),
          ('CARREFOUR EXPRESS 2231', 'Carrefour'),
          ('LIDL SUPERMERCADOS', 'Lidl'),
        ],
        category: Category.groceries,
        min: 1200,
        max: 9500,
        account: _mainId,
      ),
      // Dining: 6–9.
      ..._spray(
        monthStart,
        count: 6 + _rng.nextInt(4),
        merchants: const [
          ('GLOVOAPP ES', 'Glovo'),
          ('UBER EATS MADRID', 'Uber Eats'),
          ('LA TRATTORIA ROMANA', 'La Trattoria Romana'),
          ('CAFETERIA SOL *8842', 'Cafeteria Sol'),
        ],
        category: Category.dining,
        min: 700,
        max: 4500,
        account: _mainId,
      ),
      // Transport: 8–13.
      ..._spray(
        monthStart,
        count: 8 + _rng.nextInt(6),
        merchants: const [
          ('UBER *TRIP', 'Uber'),
          ('RENFE CERCANIAS', 'Renfe'),
          ('EMT MADRID ABONO', 'Emt Madrid Abono'),
        ],
        category: Category.transport,
        min: 150,
        max: 2500,
        account: _mainId,
      ),
      // Shopping: 2–4 on the credit card.
      ..._spray(
        monthStart,
        count: 2 + _rng.nextInt(3),
        merchants: const [
          ('AMZN MKTP ES*2K3XY', 'Amazon'),
          ('ZARA ESPANA SA', 'Zara'),
          ('DECATHLON MADRID', 'Decathlon'),
        ],
        category: Category.shopping,
        min: 1500,
        max: 12000,
        account: _creditId,
      ),
      // Entertainment: 1–3.
      ..._spray(
        monthStart,
        count: 1 + _rng.nextInt(3),
        merchants: const [
          ('CINESA PROYECCIONES', 'Cinesa Proyecciones'),
          ('STEAMGAMES.COM 4259522', 'Steamgames.com'),
        ],
        category: Category.entertainment,
        min: 800,
        max: 3000,
        account: _mainId,
      ),
      // Travel spikes twice a year.
      if (monthsAgo == 4 || monthsAgo == 11) ...[
        _tx(
          account: _mainId,
          amount: -8900,
          raw: 'RYANAIR RYR12345',
          name: 'Ryanair',
          category: Category.travel,
          day: monthStart.copyWith(day: 12, hour: 14),
        ),
        _tx(
          account: _mainId,
          amount: -23500,
          raw: 'HOTEL PLAYA AZUL SL',
          name: 'Hotel Playa Azul',
          category: Category.travel,
          day: monthStart.copyWith(day: 13, hour: 16),
        ),
      ],
      // Quarterly bank fee.
      if (monthsAgo % 3 == 0)
        _tx(
          account: _mainId,
          amount: -500,
          raw: 'COMISION MANTENIMIENTO',
          name: 'Comision Mantenimiento',
          category: Category.fees,
          day: monthStart.copyWith(day: 20, hour: 6),
        ),
    ];

    return txs.where((t) => !t.timestamp.value.isAfter(_now)).toList();
  }

  List<TransactionsCompanion> _spray(
    DateTime monthStart, {
    required int count,
    required List<(String, String)> merchants,
    required Category category,
    required int min,
    required int max,
    required String account,
  }) {
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    return [
      for (var i = 0; i < count; i++)
        () {
          final (raw, name) = merchants[_rng.nextInt(merchants.length)];
          return _tx(
            account: account,
            amount: -(min + _rng.nextInt(max - min)),
            raw: raw,
            name: name,
            category: category,
            day: monthStart.copyWith(
              day: 1 + _rng.nextInt(daysInMonth),
              hour: 8 + _rng.nextInt(13),
              minute: _rng.nextInt(60),
            ),
          );
        }(),
    ];
  }

  TransactionsCompanion _tx({
    required String account,
    required int amount,
    required String raw,
    required String name,
    required Category category,
    required DateTime day,
  }) {
    _txCounter++;
    return TransactionsCompanion.insert(
      id: 'tx-${_txCounter.toString().padLeft(5, '0')}',
      accountId: account,
      amountMinor: amount,
      currencyCode: _currency,
      merchantName: name,
      merchantRaw: raw,
      category: category,
      timestamp: day,
      status: TransactionStatus.settled,
      categorySource: CategorySource.rule,
    );
  }
}
