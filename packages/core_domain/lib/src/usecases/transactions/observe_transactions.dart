import 'package:core_domain/src/entities/transaction.dart';
import 'package:core_domain/src/repositories/transaction_repository.dart';

/// Streams transactions matching a filter, newest first.
final class ObserveTransactions {
  /// Creates the use case.
  const ObserveTransactions(this._transactions);

  final TransactionRepository _transactions;

  /// Subscribes to the filtered feed.
  Stream<List<Transaction>> call(TransactionFilter filter) =>
      _transactions.watchTransactions(filter);
}
