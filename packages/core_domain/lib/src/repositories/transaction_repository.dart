import 'package:core_domain/src/entities/transaction.dart';
import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/value_objects/category.dart';
import 'package:core_domain/src/value_objects/identifiers.dart';

/// Filter for transaction queries. All fields optional and combinable.
final class TransactionFilter {
  /// Creates a filter.
  const TransactionFilter({
    this.accountId,
    this.category,
    this.searchText,
    this.limit = 50,
    this.offset = 0,
  });

  /// Restrict to one account.
  final AccountId? accountId;

  /// Restrict to one category.
  final Category? category;

  /// Case-insensitive match on merchant name or note.
  final String? searchText;

  /// Page size.
  final int limit;

  /// Page offset.
  final int offset;
}

/// Port: transaction reads and category writes.
abstract interface class TransactionRepository {
  /// Transactions matching [filter], newest first. Emits on any write.
  Stream<List<Transaction>> watchTransactions(TransactionFilter filter);

  /// Reassigns [category] to [id], recording [source] provenance.
  Future<Result<void>> recategorize(
    TransactionId id,
    Category category,
    CategorySource source,
  );
}
