import 'package:core_ui/src/components/display/amount_text.dart';
import 'package:core_ui/src/components/display/category_chip.dart';
import 'package:core_ui/src/components/display/lds_avatar.dart';
import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/material.dart';

/// One transaction row: merchant avatar, name, category chip, amount.
///
/// Pure display component — receives already-localized strings and minor
/// units; no domain types (dependency matrix, docs/02 §4).
class TransactionTile extends StatelessWidget {
  /// Creates a transaction row.
  const TransactionTile({
    required this.merchantName,
    required this.categoryLabel,
    required this.categoryPaletteIndex,
    required this.amountMinorUnits,
    required this.currencyCode,
    this.locale = 'en',
    this.subtitle,
    this.onTap,
    super.key,
  });

  /// Normalized merchant display name.
  final String merchantName;

  /// Localized category label.
  final String categoryLabel;

  /// Stable palette index for the category.
  final int categoryPaletteIndex;

  /// Signed amount in minor units (negative = spend).
  final int amountMinorUnits;

  /// ISO 4217 currency code.
  final String currencyCode;

  /// BCP-47 locale tag for amount formatting.
  final String locale;

  /// Optional secondary line (e.g. relative time).
  final String? subtitle;

  /// Row tap handler (opens the detail sheet).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LdsRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LdsSpacing.md,
          vertical: LdsSpacing.sm,
        ),
        child: Row(
          children: [
            LdsAvatar(label: merchantName),
            const SizedBox(width: LdsSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchantName,
                    style: lds.typography.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: lds.typography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: LdsSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AmountText(
                  amountMinorUnits,
                  currencyCode: currencyCode,
                  locale: locale,
                ),
                const SizedBox(height: 2),
                CategoryChip(
                  label: categoryLabel,
                  paletteIndex: categoryPaletteIndex,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
