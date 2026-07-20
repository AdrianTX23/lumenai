import 'dart:math';

import 'package:core_data/src/database/lumen_database.dart';
import 'package:core_domain/core_domain.dart' hide Transaction;
import 'package:drift/drift.dart';

/// Deterministic demo dataset: ~18 months of realistic Colombian
/// financial life, in COP (whole pesos — COP has no minor subdivision).
///
/// Same `now` + same seed → byte-identical output, so screenshots, demo
/// videos and the analytics golden tests never drift. Local texture is
/// deliberate: quincena salary (two payments a month), arriendo, Éxito/
/// D1/Carulla groceries, Rappi dining, TransMilenio, monthly cuota de
/// manejo. The data plants two anomalies on purpose for the insights/AI
/// features to find:
///  1. Netflix price rises from $26.900 to $33.900 in the 6 most recent
///     months.
///  2. A duplicated Smart Fit charge (same day, same amount) two months
///     ago.
final class SeedEngine {
  /// Creates an engine generating relative to [now].
  SeedEngine({required DateTime now, int seed = 20260718})
      : _now = DateTime(now.year, now.month, now.day, now.hour),
        _rng = Random(seed);

  final DateTime _now;
  final Random _rng;
  int _txCounter = 0;

  /// Dataset version — bump to force a reseed on app update.
  static const version = '2';

  static const _currency = 'COP';
  static const _mainId = 'acc-main';
  static const _savingsId = 'acc-savings';
  static const _creditId = 'acc-credit';

  /// Number of full months of history.
  static const monthsOfHistory = 18;

  /// Salary payments per month (Colombian quincena).
  static const salariesPerMonth = 2;

  /// The three demo accounts.
  List<AccountsCompanion> accounts() {
    return [
      AccountsCompanion.insert(
        id: _mainId,
        name: 'Bancolombia',
        type: AccountType.checking,
        currencyCode: _currency,
        openingBalanceMinor: 2400000,
        cardLast4: const Value('4821'),
        cardNetwork: const Value('Visa'),
        cardSkinIndex: const Value(0),
      ),
      AccountsCompanion.insert(
        id: _savingsId,
        name: 'Nequi',
        type: AccountType.savings,
        currencyCode: _currency,
        openingBalanceMinor: 5800000,
      ),
      AccountsCompanion.insert(
        id: _creditId,
        name: 'Davivienda',
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
      // Quincena salary — the heartbeat of the dataset.
      _tx(
        account: _mainId,
        amount: 2100000,
        raw: 'NOMINA TECNOVA SAS QUINCENA 1',
        name: 'Tecnova',
        category: Category.income,
        day: monthStart.copyWith(day: 1, hour: 9),
      ),
      _tx(
        account: _mainId,
        amount: 2100000,
        raw: 'NOMINA TECNOVA SAS QUINCENA 2',
        name: 'Tecnova',
        category: Category.income,
        day: monthStart.copyWith(day: 16, hour: 9),
      ),
      // Arriendo.
      _tx(
        account: _mainId,
        amount: -1450000,
        raw: 'ARRIENDO APTO CHAPINERO',
        name: 'Arriendo Chapinero',
        category: Category.housing,
        day: monthStart.copyWith(day: 3, hour: 8),
      ),
      // Savings sweep (transfer pair — excluded from spend analytics).
      _tx(
        account: _mainId,
        amount: -400000,
        raw: 'TRANSFERENCIA A NEQUI',
        name: 'Transfer to Nequi',
        category: Category.transfers,
        day: monthStart.copyWith(day: 2, hour: 10),
      ),
      _tx(
        account: _savingsId,
        amount: 400000,
        raw: 'TRANSFERENCIA DESDE BANCOLOMBIA',
        name: 'Transfer from Bancolombia',
        category: Category.transfers,
        day: monthStart.copyWith(day: 2, hour: 10),
      ),
      // Subscriptions — Netflix price increase planted 6 months ago.
      _tx(
        account: _creditId,
        amount: monthsAgo < 6 ? -33900 : -26900,
        raw: 'NETFLIX.COM 866-579-7172',
        name: 'Netflix',
        category: Category.subscriptions,
        day: monthStart.copyWith(day: 5, hour: 12),
      ),
      _tx(
        account: _creditId,
        amount: -16900,
        raw: 'PAYPAL *SPOTIFY',
        name: 'Spotify',
        category: Category.subscriptions,
        day: monthStart.copyWith(day: 7, hour: 12),
      ),
      _tx(
        account: _creditId,
        amount: -12900,
        raw: 'APPLE.COM/BILL ICLOUD 50GB',
        name: 'Apple',
        category: Category.subscriptions,
        day: monthStart.copyWith(day: 3, hour: 7),
      ),
      _tx(
        account: _creditId,
        amount: -19990,
        raw: 'RAPPI PRO MEMBRESIA',
        name: 'Rappi Pro',
        category: Category.subscriptions,
        day: monthStart.copyWith(day: 9, hour: 6),
      ),
      _tx(
        account: _creditId,
        amount: -19900,
        raw: 'MAX.COM STREAMING',
        name: 'Max',
        category: Category.subscriptions,
        day: monthStart.copyWith(day: 11, hour: 13),
      ),
      // Gym — duplicated two months ago (planted anomaly #2).
      _tx(
        account: _mainId,
        amount: -79900,
        raw: 'SMART FIT COLOMBIA SAS',
        name: 'Smart Fit',
        category: Category.health,
        day: monthStart.copyWith(day: 4, hour: 7),
      ),
      if (monthsAgo == 2)
        _tx(
          account: _mainId,
          amount: -79900,
          raw: 'SMART FIT COLOMBIA SAS',
          name: 'Smart Fit',
          category: Category.health,
          day: monthStart.copyWith(day: 4, hour: 7, minute: 2),
        ),
      // Utilities.
      _tx(
        account: _mainId,
        amount: -(180000 + _rng.nextInt(140000)),
        raw: 'ENEL CODENSA SA ESP',
        name: 'Enel Codensa',
        category: Category.utilities,
        day: monthStart.copyWith(day: 15, hour: 8),
      ),
      _tx(
        account: _mainId,
        amount: -129900,
        raw: 'CLARO COLOMBIA HOGAR',
        name: 'Claro',
        category: Category.utilities,
        day: monthStart.copyWith(day: 17, hour: 8),
      ),
      // Cuota de manejo — monthly bank fee, a very Colombian constant.
      _tx(
        account: _mainId,
        amount: -12900,
        raw: 'CUOTA MANEJO TARJETA DEBITO',
        name: 'Cuota de Manejo',
        category: Category.fees,
        day: monthStart.copyWith(day: 20, hour: 6),
      ),
      // Credit card payoff (transfer pair).
      _tx(
        account: _mainId,
        amount: -600000,
        raw: 'PAGO TARJETA DAVIVIENDA',
        name: 'Card payment',
        category: Category.transfers,
        day: monthStart.copyWith(day: 28, hour: 9),
      ),
      _tx(
        account: _creditId,
        amount: 600000,
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
          ('ALMACENES EXITO CALLE 80', 'Éxito'),
          ('CARULLA FRESH MARKET', 'Carulla'),
          ('TIENDAS D1 SAS', 'D1'),
        ],
        category: Category.groceries,
        min: 25000,
        max: 220000,
        account: _mainId,
      ),
      // Dining: 6–9.
      ..._spray(
        monthStart,
        count: 6 + _rng.nextInt(4),
        merchants: const [
          ('RAPPI*RESTAURANTES BOG', 'Rappi'),
          ('EL CORRAL GOURMET', 'El Corral'),
          ('CREPES & WAFFLES 93', 'Crepes & Waffles'),
          ('JUAN VALDEZ CAFE PARQUE 93', 'Juan Valdez'),
        ],
        category: Category.dining,
        min: 14000,
        max: 120000,
        account: _mainId,
      ),
      // Transport: 8–13.
      ..._spray(
        monthStart,
        count: 8 + _rng.nextInt(6),
        merchants: const [
          ('UBER *TRIP', 'Uber'),
          ('TRANSMILENIO RECARGA TULLAVE', 'TransMilenio'),
          ('TAXIS LIBRES BOGOTA', 'Taxis Libres'),
        ],
        category: Category.transport,
        min: 3200,
        max: 40000,
        account: _mainId,
      ),
      // Shopping: 2–4 on the credit card.
      ..._spray(
        monthStart,
        count: 2 + _rng.nextInt(3),
        merchants: const [
          ('MERCADOLIBRE COLOMBIA', 'Mercado Libre'),
          ('FALABELLA SANTAFE', 'Falabella'),
          ('ZARA COLOMBIA ANDINO', 'Zara'),
        ],
        category: Category.shopping,
        min: 60000,
        max: 800000,
        account: _creditId,
      ),
      // Entertainment: 1–3.
      ..._spray(
        monthStart,
        count: 1 + _rng.nextInt(3),
        merchants: const [
          ('CINE COLOMBIA MULTIPLEX', 'Cine Colombia'),
          ('STEAMGAMES.COM 4259522', 'Steam'),
        ],
        category: Category.entertainment,
        min: 25000,
        max: 120000,
        account: _mainId,
      ),
      // Travel spikes twice a year.
      if (monthsAgo == 4 || monthsAgo == 11) ...[
        _tx(
          account: _mainId,
          amount: -480000,
          raw: 'AVIANCA BOG-CTG',
          name: 'Avianca',
          category: Category.travel,
          day: monthStart.copyWith(day: 12, hour: 14),
        ),
        _tx(
          account: _mainId,
          amount: -850000,
          raw: 'HOTEL LAS AMERICAS CARTAGENA',
          name: 'Hotel Las Americas',
          category: Category.travel,
          day: monthStart.copyWith(day: 13, hour: 16),
        ),
      ],
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
