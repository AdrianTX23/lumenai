import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

final class _RecordingTransactionRepository implements TransactionRepository {
  final created = <Transaction>[];

  @override
  Stream<List<Transaction>> watchTransactions(TransactionFilter filter) =>
      const Stream.empty();

  @override
  Future<Result<void>> recategorize(
    TransactionId id,
    Category category,
    CategorySource source,
  ) async =>
      const Result.ok(null);

  @override
  Future<Result<void>> createTransaction(Transaction transaction) async {
    created.add(transaction);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteTransaction(TransactionId id) async =>
      const Result.ok(null);
}

Transaction _transaction({
  String merchantName = 'Éxito',
  int amountMinor = -50000,
}) {
  return Transaction(
    id: const TransactionId('t1'),
    accountId: const AccountId('a1'),
    amount: Money.minor(amountMinor, 'COP'),
    merchantName: merchantName,
    merchantRaw: merchantName,
    category: Category.groceries,
    timestamp: DateTime(2026, 7, 19),
    status: TransactionStatus.settled,
    categorySource: CategorySource.user,
  );
}

void main() {
  group('CreateTransaction', () {
    late _RecordingTransactionRepository repo;
    late CreateTransaction createTransaction;

    setUp(() {
      repo = _RecordingTransactionRepository();
      createTransaction = CreateTransaction(repo);
    });

    test('persists a valid transaction', () async {
      final result = await createTransaction(_transaction());

      expect(result.isOk, isTrue);
      expect(repo.created, hasLength(1));
    });

    test('rejects an empty merchant name', () async {
      final result = await createTransaction(_transaction(merchantName: '  '));

      expect(result.isErr, isTrue);
      expect((result as Err<void>).failure, isA<ValidationFailure>());
      expect(repo.created, isEmpty);
    });

    test('rejects a zero amount', () async {
      final result = await createTransaction(_transaction(amountMinor: 0));

      expect(result.isErr, isTrue);
      expect((result as Err<void>).failure, isA<ValidationFailure>());
      expect(repo.created, isEmpty);
    });
  });
}
