/// Typed identifiers as zero-cost extension types: an [AccountId] cannot be
/// passed where a [TransactionId] is expected, at no runtime overhead.
library;

/// Identifier of an `Account`.
extension type const AccountId(String value) {}

/// Identifier of a `Transaction`.
extension type const TransactionId(String value) {}

/// Identifier of a `Budget`.
extension type const BudgetId(String value) {}
