import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:flutter/material.dart';

/// Presentation mapping for [Category]: localized label, glyph and the
/// stable data-viz palette index. Lives in `common/` because every feature
/// renders categories and features may not import each other.
extension CategoryUi on Category {
  /// Localized display name.
  String label(AppLocalizations l10n) => switch (this) {
        Category.groceries => l10n.categoryGroceries,
        Category.dining => l10n.categoryDining,
        Category.transport => l10n.categoryTransport,
        Category.subscriptions => l10n.categorySubscriptions,
        Category.housing => l10n.categoryHousing,
        Category.utilities => l10n.categoryUtilities,
        Category.health => l10n.categoryHealth,
        Category.shopping => l10n.categoryShopping,
        Category.travel => l10n.categoryTravel,
        Category.entertainment => l10n.categoryEntertainment,
        Category.income => l10n.categoryIncome,
        Category.transfers => l10n.categoryTransfers,
        Category.fees => l10n.categoryFees,
        Category.other => l10n.categoryOther,
      };

  /// Category glyph.
  IconData get icon => switch (this) {
        Category.groceries => Icons.shopping_basket_rounded,
        Category.dining => Icons.restaurant_rounded,
        Category.transport => Icons.directions_bus_rounded,
        Category.subscriptions => Icons.subscriptions_rounded,
        Category.housing => Icons.home_work_rounded,
        Category.utilities => Icons.bolt_rounded,
        Category.health => Icons.favorite_rounded,
        Category.shopping => Icons.shopping_bag_rounded,
        Category.travel => Icons.flight_rounded,
        Category.entertainment => Icons.movie_rounded,
        Category.income => Icons.trending_up_rounded,
        Category.transfers => Icons.swap_horiz_rounded,
        Category.fees => Icons.account_balance_rounded,
        Category.other => Icons.category_rounded,
      };

  /// Stable index into the LDS data-viz palette.
  int get paletteIndex => index;
}
