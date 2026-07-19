import 'package:core_data/src/database/lumen_database.dart';
import 'package:core_domain/core_domain.dart' as domain;

/// The ONLY translation site between storage rows and domain entities.
/// Rows never leak above this file; entities never gain storage concerns.
extension AccountRowMapper on AccountRow {
  /// Converts to the domain entity.
  domain.Account toEntity() {
    return domain.Account(
      id: domain.AccountId(id),
      name: name,
      type: type,
      currencyCode: currencyCode,
      openingBalance: domain.Money.minor(openingBalanceMinor, currencyCode),
      cardMeta: cardLast4 == null
          ? null
          : domain.CardMeta(
              last4: cardLast4!,
              network: cardNetwork ?? '',
              skinIndex: cardSkinIndex ?? 0,
            ),
    );
  }
}

/// Maps transaction rows to entities.
extension TransactionRowMapper on TransactionRow {
  /// Converts to the domain entity.
  domain.Transaction toEntity() {
    return domain.Transaction(
      id: domain.TransactionId(id),
      accountId: domain.AccountId(accountId),
      amount: domain.Money.minor(amountMinor, currencyCode),
      merchantName: merchantName,
      merchantRaw: merchantRaw,
      category: category,
      timestamp: timestamp,
      status: status,
      categorySource: categorySource,
      note: note,
    );
  }
}

/// Maps budget rows to entities.
extension BudgetRowMapper on BudgetRow {
  /// Converts to the domain entity.
  domain.Budget toEntity() {
    return domain.Budget(
      id: domain.BudgetId(id),
      category: category,
      limit: domain.Money.minor(limitMinor, currencyCode),
      anchorDay: anchorDay,
      createdAt: createdAt,
    );
  }
}
