import 'package:core_domain/src/value_objects/identifiers.dart';
import 'package:core_domain/src/value_objects/money.dart';

/// Kinds of account LUMEN tracks.
enum AccountType {
  /// Day-to-day current account.
  checking,

  /// Savings account.
  savings,

  /// Credit card account (balance runs negative).
  credit,

  /// Physical cash tracked manually.
  cash,
}

/// Card presentation details for accounts that render as a payment card.
final class CardMeta {
  /// Creates card metadata.
  const CardMeta({
    required this.last4,
    required this.network,
    required this.skinIndex,
  });

  /// Last four digits of the PAN (display only — never a full number).
  final String last4;

  /// Card network display name (e.g. `Visa`).
  final String network;

  /// Index into the design system's card gradient skins.
  final int skinIndex;
}

/// A money container: bank account, card or cash.
final class Account {
  /// Creates an account.
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyCode,
    required this.openingBalance,
    this.cardMeta,
  });

  /// Stable identifier.
  final AccountId id;

  /// User-facing name.
  final String name;

  /// Account kind.
  final AccountType type;

  /// ISO 4217 currency of the account.
  final String currencyCode;

  /// Balance before the first tracked transaction.
  final Money openingBalance;

  /// Present when the account renders as a payment card.
  final CardMeta? cardMeta;
}

/// An [Account] together with its current balance
/// (opening balance + sum of settled transactions, computed by the data
/// layer's SQL — never cached in presentation).
final class AccountSnapshot {
  /// Creates a snapshot.
  const AccountSnapshot({required this.account, required this.balance});

  /// The underlying account.
  final Account account;

  /// Current balance.
  final Money balance;
}
