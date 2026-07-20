import 'package:core_domain/src/entities/transaction.dart';
import 'package:core_domain/src/failures/failure.dart';
import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/repositories/transaction_repository.dart';

/// Validates and persists a manually-entered transaction.
final class CreateTransaction {
  /// Creates the use case.
  const CreateTransaction(this._transactions);

  final TransactionRepository _transactions;

  /// Validates [transaction] and stores it.
  Future<Result<void>> call(Transaction transaction) async {
    if (transaction.merchantName.trim().isEmpty) {
      return const Result.err(
        ValidationFailure('merchant name must not be empty'),
      );
    }
    if (transaction.amount.isZero) {
      return const Result.err(
        ValidationFailure('amount must not be zero'),
      );
    }
    return _transactions.createTransaction(transaction);
  }
}
