import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart' hide Transaction;
import 'package:core_domain/core_domain.dart' as domain show Transaction;
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LumenDatabase db;
  late DriftTransactionRepository repo;
  late DriftAccountRepository accountRepo;

  TransactionsCompanion tx({
    required String id,
    required int amount,
    String account = 'a1',
    Category category = Category.groceries,
    String merchant = 'Mercadona',
    String? note,
    DateTime? when,
  }) {
    return TransactionsCompanion.insert(
      id: id,
      accountId: account,
      amountMinor: amount,
      currencyCode: 'EUR',
      merchantName: merchant,
      merchantRaw: merchant.toUpperCase(),
      category: category,
      timestamp: when ?? DateTime(2026, 7, 10),
      status: TransactionStatus.settled,
      categorySource: CategorySource.rule,
      note: Value(note),
    );
  }

  setUp(() async {
    db = LumenDatabase(NativeDatabase.memory());
    repo = DriftTransactionRepository(db);
    accountRepo = DriftAccountRepository(db);

    await db.batch((batch) {
      batch
        ..insertAll(db.accounts, [
          AccountsCompanion.insert(
            id: 'a1',
            name: 'Current',
            type: AccountType.checking,
            currencyCode: 'EUR',
            openingBalanceMinor: 10000,
          ),
          AccountsCompanion.insert(
            id: 'a2',
            name: 'Savings',
            type: AccountType.savings,
            currencyCode: 'EUR',
            openingBalanceMinor: 50000,
          ),
        ])
        ..insertAll(db.transactions, [
          tx(id: 't1', amount: -500, when: DateTime(2026, 7)),
          tx(
            id: 't2',
            amount: -1200,
            category: Category.dining,
            merchant: 'Glovo',
            note: 'team lunch',
            when: DateTime(2026, 7, 5),
          ),
          tx(
            id: 't3',
            amount: 2000,
            account: 'a2',
            category: Category.income,
            merchant: 'Acme',
            when: DateTime(2026, 7, 8),
          ),
        ]);
    });
  });

  tearDown(() async => db.close());

  group('DriftAccountRepository', () {
    test('balances are opening balance + transaction sums', () async {
      final snapshots = await accountRepo.watchAccounts().first;

      final byName = {
        for (final s in snapshots) s.account.name: s.balance.minorUnits,
      };
      expect(byName, {
        'Current': 10000 - 500 - 1200,
        'Savings': 50000 + 2000,
      });
    });

    test('createAccount persists a manually-entered account', () async {
      final result = await accountRepo.createAccount(
        const Account(
          id: AccountId('a3'),
          name: 'Cash',
          type: AccountType.cash,
          currencyCode: 'EUR',
          openingBalance: Money.minor(15000, 'EUR'),
        ),
      );

      expect(result.isOk, isTrue);
      final snapshots = await accountRepo.watchAccounts().first;
      final cash = snapshots.singleWhere((s) => s.account.id.value == 'a3');
      expect(cash.account.name, 'Cash');
      expect(cash.balance.minorUnits, 15000);
    });
  });

  group('DriftTransactionRepository', () {
    test('feed is newest first', () async {
      final all = await repo.watchTransactions(const TransactionFilter()).first;

      expect(all.map((t) => t.id.value), ['t3', 't2', 't1']);
    });

    test('filters by account, category and search text', () async {
      final byAccount = await repo
          .watchTransactions(
            const TransactionFilter(accountId: AccountId('a2')),
          )
          .first;
      expect(byAccount.single.id.value, 't3');

      final byCategory = await repo
          .watchTransactions(
            const TransactionFilter(category: Category.dining),
          )
          .first;
      expect(byCategory.single.id.value, 't2');

      final bySearchMerchant = await repo
          .watchTransactions(const TransactionFilter(searchText: 'glo'))
          .first;
      expect(bySearchMerchant.single.id.value, 't2');

      final bySearchNote = await repo
          .watchTransactions(const TransactionFilter(searchText: 'LUNCH'))
          .first;
      expect(bySearchNote.single.id.value, 't2');
    });

    test('recategorize updates the row and the watched stream', () async {
      final result = await repo.recategorize(
        const TransactionId('t1'),
        Category.shopping,
        CategorySource.user,
      );

      expect(result.isOk, isTrue);
      final all = await repo.watchTransactions(const TransactionFilter()).first;
      final t1 = all.singleWhere((t) => t.id.value == 't1');
      expect(t1.category, Category.shopping);
      expect(t1.categorySource, CategorySource.user);
    });

    test('recategorize on a missing id returns StorageFailure', () async {
      final result = await repo.recategorize(
        const TransactionId('nope'),
        Category.shopping,
        CategorySource.user,
      );

      expect(result.isErr, isTrue);
      expect((result as Err<void>).failure, isA<StorageFailure>());
    });

    test('createTransaction persists a manually-entered transaction', () async {
      final result = await repo.createTransaction(
        domain.Transaction(
          id: const TransactionId('t4'),
          accountId: const AccountId('a1'),
          amount: const Money.minor(-9900, 'EUR'),
          merchantName: 'Amazon',
          merchantRaw: 'Amazon',
          category: Category.shopping,
          timestamp: DateTime(2026, 7, 12),
          status: TransactionStatus.settled,
          categorySource: CategorySource.user,
        ),
      );

      expect(result.isOk, isTrue);
      final all = await repo.watchTransactions(const TransactionFilter()).first;
      expect(all.map((t) => t.id.value), contains('t4'));
    });

    test('deleteTransaction removes the row', () async {
      final result = await repo.deleteTransaction(const TransactionId('t1'));

      expect(result.isOk, isTrue);
      final all = await repo.watchTransactions(const TransactionFilter()).first;
      expect(all.map((t) => t.id.value), isNot(contains('t1')));
    });

    test('deleteTransaction on a missing id returns StorageFailure', () async {
      final result = await repo.deleteTransaction(const TransactionId('nope'));

      expect(result.isErr, isTrue);
      expect((result as Err<void>).failure, isA<StorageFailure>());
    });
  });
}
