import 'package:core_data/src/database/tables.dart';
import 'package:core_domain/core_domain.dart' hide Transaction;
import 'package:drift/drift.dart';

part 'lumen_database.g.dart';

/// The local store. All analytics run as SQL here — never as in-memory
/// folds above this layer (ADR-003, ADR-007).
@DriftDatabase(tables: [Accounts, Transactions, Budgets, AppMeta])
class LumenDatabase extends _$LumenDatabase {
  /// Creates the database over [executor] (file in the app, in-memory in
  /// tests — injected by the composition root).
  LumenDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  // ── Accounts ──────────────────────────────────────────────────────────

  /// Accounts joined with their live balance
  /// (opening balance + sum of transaction amounts).
  Stream<List<(AccountRow, int)>> watchAccountsWithBalances() {
    final txSum = transactions.amountMinor.sum();
    final query = select(accounts).join([
      leftOuterJoin(
        transactions,
        transactions.accountId.equalsExp(accounts.id),
        useColumns: false,
      ),
    ])
      ..addColumns([txSum])
      ..groupBy([accounts.id])
      ..orderBy([OrderingTerm.asc(accounts.name)]);

    return query.watch().map(
          (rows) => rows.map((row) {
            final account = row.readTable(accounts);
            final txTotal = row.read(txSum) ?? 0;
            final balance = account.openingBalanceMinor + txTotal;
            return (account, balance);
          }).toList(),
        );
  }

  /// Total balance across all accounts, in minor units.
  Stream<int> watchNetWorthMinor() {
    return customSelect(
      'SELECT '
      '(SELECT COALESCE(SUM(opening_balance_minor), 0) FROM accounts) + '
      '(SELECT COALESCE(SUM(amount_minor), 0) FROM transactions) AS total',
      readsFrom: {accounts, transactions},
    ).watchSingle().map((row) => row.read<int>('total'));
  }

  // ── Transactions ──────────────────────────────────────────────────────

  /// Filtered transaction feed, newest first.
  Stream<List<TransactionRow>> watchTransactionRows(
    TransactionFilter filter,
  ) {
    final query = select(transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
      ..limit(filter.limit, offset: filter.offset);

    final accountId = filter.accountId;
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId.value));
    }
    final category = filter.category;
    if (category != null) {
      query.where((t) => t.category.equals(category.name));
    }
    final search = filter.searchText;
    if (search != null && search.trim().isNotEmpty) {
      final needle = '%${search.trim().toLowerCase()}%';
      query.where(
        (t) =>
            t.merchantName.lower().like(needle) | t.note.lower().like(needle),
      );
    }
    final ids = filter.ids;
    if (ids != null) {
      query.where((t) => t.id.isIn(ids.map((id) => id.value)));
    }
    return query.watch();
  }

  /// Updates the category of one transaction. Returns affected row count.
  Future<int> updateCategory(
    String transactionId,
    Category category,
    CategorySource source,
  ) {
    return (update(transactions)..where((t) => t.id.equals(transactionId)))
        .write(
      TransactionsCompanion(
        category: Value(category),
        categorySource: Value(source),
      ),
    );
  }

  // ── Analytics ─────────────────────────────────────────────────────────

  /// Spend per category within `[start, end)`, biggest spender first.
  /// Excludes income and transfers; spend is returned as a positive
  /// magnitude.
  Stream<List<(Category, int)>> watchSpendingBreakdown(
    DateTime start,
    DateTime end,
  ) {
    final spent = transactions.amountMinor.sum();
    final query = selectOnly(transactions)
      ..addColumns([transactions.category, spent])
      ..where(
        transactions.amountMinor.isSmallerThanValue(0) &
            transactions.timestamp.isBiggerOrEqualValue(start) &
            transactions.timestamp.isSmallerThanValue(end) &
            transactions.category.isNotIn(
              [Category.income.name, Category.transfers.name],
            ),
      )
      ..groupBy([transactions.category])
      ..orderBy([OrderingTerm.asc(spent)]);

    return query.watch().map(
          (rows) => rows.map((row) {
            final name = row.read(transactions.category)!;
            final total = -(row.read(spent) ?? 0);
            return (Category.values.byName(name), total);
          }).toList(),
        );
  }

  /// Income and spend magnitudes for each `[start, end)` window in
  /// [windows]. Missing windows yield zero entries. Transfers excluded.
  Stream<List<(DateTime, int, int)>> watchCashflow(
    List<(DateTime, DateTime)> windows,
  ) {
    final whens = StringBuffer();
    final variables = <Variable<Object>>[];
    for (var i = 0; i < windows.length; i++) {
      whens.write('WHEN timestamp >= ? AND timestamp < ? THEN $i ');
      variables
        ..add(Variable.withDateTime(windows[i].$1))
        ..add(Variable.withDateTime(windows[i].$2));
    }

    return customSelect(
      'SELECT CASE $whens ELSE NULL END AS bucket, '
      'COALESCE(SUM(CASE WHEN amount_minor > 0 THEN amount_minor '
      'ELSE 0 END), 0) AS income, '
      'COALESCE(SUM(CASE WHEN amount_minor < 0 THEN -amount_minor '
      'ELSE 0 END), 0) AS spend '
      "FROM transactions WHERE category != 'transfers' "
      'GROUP BY bucket HAVING bucket IS NOT NULL ORDER BY bucket',
      variables: variables,
      readsFrom: {transactions},
    ).watch().map((rows) {
      final byBucket = {
        for (final row in rows)
          row.read<int>('bucket'): (
            row.read<int>('income'),
            row.read<int>('spend'),
          ),
      };
      return [
        for (var i = 0; i < windows.length; i++)
          (
            windows[i].$1,
            byBucket[i]?.$1 ?? 0,
            byBucket[i]?.$2 ?? 0,
          ),
      ];
    });
  }

  // ── Maintenance ───────────────────────────────────────────────────────

  /// Deletes all rows from every table (used by reset/seed).
  Future<void> wipe() => transaction(() async {
        await delete(transactions).go();
        await delete(budgets).go();
        await delete(accounts).go();
        await delete(appMeta).go();
      });
}
