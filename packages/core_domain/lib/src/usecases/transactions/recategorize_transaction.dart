import 'package:core_domain/src/entities/transaction.dart';
import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/repositories/transaction_repository.dart';
import 'package:core_domain/src/value_objects/category.dart';
import 'package:core_domain/src/value_objects/identifiers.dart';

/// Reassigns a transaction's category as an explicit user decision.
///
/// Provenance is always [CategorySource.user] here — rules and AI go
/// through their own paths and can never masquerade as the user.
final class RecategorizeTransaction {
  /// Creates the use case.
  const RecategorizeTransaction(this._transactions);

  final TransactionRepository _transactions;

  /// Applies [category] to [id].
  Future<Result<void>> call(TransactionId id, Category category) =>
      _transactions.recategorize(id, category, CategorySource.user);
}
