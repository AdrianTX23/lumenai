import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

final class _RecordingTransactionRepository implements TransactionRepository {
  final deleted = <TransactionId>[];

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
  Future<Result<void>> createTransaction(Transaction transaction) async =>
      const Result.ok(null);

  @override
  Future<Result<void>> deleteTransaction(TransactionId id) async {
    deleted.add(id);
    return const Result.ok(null);
  }
}

void main() {
  test('DeleteTransaction forwards to the repository', () async {
    final repo = _RecordingTransactionRepository();
    final deleteTransaction = DeleteTransaction(repo);

    final result = await deleteTransaction(const TransactionId('t1'));

    expect(result.isOk, isTrue);
    expect(repo.deleted, [const TransactionId('t1')]);
  });
}
