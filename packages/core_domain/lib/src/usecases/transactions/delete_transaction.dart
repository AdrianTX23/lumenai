import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/repositories/transaction_repository.dart';
import 'package:core_domain/src/value_objects/identifiers.dart';

/// Removes a manually-entered transaction.
final class DeleteTransaction {
  /// Creates the use case.
  const DeleteTransaction(this._transactions);

  final TransactionRepository _transactions;

  /// Deletes the transaction with [id].
  Future<Result<void>> call(TransactionId id) =>
      _transactions.deleteTransaction(id);
}
