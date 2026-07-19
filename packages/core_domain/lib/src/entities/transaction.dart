import 'package:core_domain/src/value_objects/category.dart';
import 'package:core_domain/src/value_objects/identifiers.dart';
import 'package:core_domain/src/value_objects/money.dart';

/// Settlement state of a transaction.
enum TransactionStatus {
  /// Authorized but not yet settled.
  pending,

  /// Final.
  settled,
}

/// Where a transaction's category came from — user choices must never be
/// silently overwritten by rules or AI.
enum CategorySource {
  /// Deterministic merchant rule.
  rule,

  /// AI categorizer.
  ai,

  /// Explicit user override (highest precedence).
  user,
}

/// A single money movement.
final class Transaction {
  /// Creates a transaction.
  const Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.merchantName,
    required this.merchantRaw,
    required this.category,
    required this.timestamp,
    required this.status,
    required this.categorySource,
    this.note,
  });

  /// Stable identifier.
  final TransactionId id;

  /// Owning account.
  final AccountId accountId;

  /// Signed amount: negative = spend, positive = inflow.
  final Money amount;

  /// Normalized display name (see `MerchantNormalizer`).
  final String merchantName;

  /// Raw bank descriptor as received (kept for audit and re-normalization).
  final String merchantRaw;

  /// Assigned category.
  final Category category;

  /// When the transaction happened.
  final DateTime timestamp;

  /// Settlement state.
  final TransactionStatus status;

  /// Provenance of [category].
  final CategorySource categorySource;

  /// Optional user note.
  final String? note;
}
