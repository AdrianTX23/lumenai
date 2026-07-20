import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:flutter/material.dart';

/// Presentation mapping for [AccountType]: localized label and glyph.
/// Lives in `common/` because both Home and Settings render account
/// pickers and features may not import each other.
extension AccountTypeUi on AccountType {
  /// Localized display name.
  String label(AppLocalizations l10n) => switch (this) {
        AccountType.checking => l10n.accountTypeChecking,
        AccountType.savings => l10n.accountTypeSavings,
        AccountType.credit => l10n.accountTypeCredit,
        AccountType.cash => l10n.accountTypeCash,
      };

  /// Account-type glyph.
  IconData get icon => switch (this) {
        AccountType.checking => Icons.account_balance_rounded,
        AccountType.savings => Icons.savings_rounded,
        AccountType.credit => Icons.credit_card_rounded,
        AccountType.cash => Icons.payments_rounded,
      };
}
