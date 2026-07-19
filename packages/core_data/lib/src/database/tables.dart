import 'package:core_domain/core_domain.dart';
import 'package:drift/drift.dart';

/// Accounts table. Row classes are suffixed `Row` so DTOs never collide
/// with domain entities.
@DataClassName('AccountRow')
class Accounts extends Table {
  /// Stable id (uuid-like string).
  TextColumn get id => text()();

  /// User-facing name.
  TextColumn get name => text()();

  /// Account kind, stored by enum name.
  TextColumn get type => textEnum<AccountType>()();

  /// ISO 4217 currency.
  TextColumn get currencyCode => text()();

  /// Balance before the first tracked transaction, minor units.
  IntColumn get openingBalanceMinor => integer()();

  /// Card display: last four digits.
  TextColumn get cardLast4 => text().nullable()();

  /// Card display: network name.
  TextColumn get cardNetwork => text().nullable()();

  /// Card display: gradient skin index.
  IntColumn get cardSkinIndex => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Transactions table. Indexed for the two hot paths: per-account feeds
/// and category aggregation over time ranges.
@DataClassName('TransactionRow')
@TableIndex(name: 'idx_tx_account_time', columns: {#accountId, #timestamp})
@TableIndex(name: 'idx_tx_category_time', columns: {#category, #timestamp})
class Transactions extends Table {
  /// Stable id.
  TextColumn get id => text()();

  /// Owning account.
  TextColumn get accountId => text().references(Accounts, #id)();

  /// Signed amount in minor units (negative = spend).
  IntColumn get amountMinor => integer()();

  /// ISO 4217 currency.
  TextColumn get currencyCode => text()();

  /// Normalized merchant display name.
  TextColumn get merchantName => text()();

  /// Raw bank descriptor.
  TextColumn get merchantRaw => text()();

  /// Category, stored by enum name.
  TextColumn get category => textEnum<Category>()();

  /// Moment of the transaction.
  DateTimeColumn get timestamp => dateTime()();

  /// Settlement state, stored by enum name.
  TextColumn get status => textEnum<TransactionStatus>()();

  /// Category provenance, stored by enum name.
  TextColumn get categorySource => textEnum<CategorySource>()();

  /// Optional user note.
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Budgets table. One budget per category.
@DataClassName('BudgetRow')
class Budgets extends Table {
  /// Stable id.
  TextColumn get id => text()();

  /// Budgeted category (unique — one envelope per category).
  TextColumn get category => textEnum<Category>().unique()();

  /// Monthly limit in minor units (positive).
  IntColumn get limitMinor => integer()();

  /// ISO 4217 currency.
  TextColumn get currencyCode => text()();

  /// Day the budget window starts on.
  IntColumn get anchorDay => integer()();

  /// Creation moment.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Key-value metadata (seed version, schema markers).
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  /// Metadata key.
  TextColumn get key => text()();

  /// Metadata value.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
