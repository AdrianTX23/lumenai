import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../helpers/golden_helpers.dart';

void main() {
  ldsGoldenPair(
    fileName: 'lds_button',
    scenarios: {
      'primary': const LdsButton(label: 'Continue', onPressed: _noop),
      'secondary': const LdsButton(
        label: 'See details',
        onPressed: _noop,
        variant: LdsButtonVariant.secondary,
      ),
      'ghost': const LdsButton(
        label: 'Skip',
        onPressed: _noop,
        variant: LdsButtonVariant.ghost,
      ),
      'destructive': const LdsButton(
        label: 'Delete budget',
        onPressed: _noop,
        variant: LdsButtonVariant.destructive,
      ),
      'with icon': const LdsButton(
        label: 'Add account',
        onPressed: _noop,
        icon: Icons.add_rounded,
      ),
      'loading': const LdsButton(
        label: 'Continue',
        onPressed: _noop,
        loading: true,
      ),
      'disabled': const LdsButton(label: 'Continue', onPressed: null),
      'large expanded': const LdsButton(
        label: 'Get started',
        onPressed: _noop,
        size: LdsButtonSize.large,
        expand: true,
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'amount_text',
    scenarios: {
      'inline spend': const AmountText(-1250, currencyCode: 'EUR'),
      'inline income': const AmountText(245000, currencyCode: 'EUR'),
      'hero balance': const AmountText(
        1224065,
        currencyCode: 'EUR',
        emphasis: AmountEmphasis.hero,
        colored: false,
      ),
      'hero income': const AmountText(
        180000,
        currencyCode: 'EUR',
        emphasis: AmountEmphasis.hero,
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'lds_card_and_tile',
    scenarios: {
      'card': const LdsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Monthly spending'),
            SizedBox(height: LdsSpacing.xs),
            AmountText(-184230, currencyCode: 'EUR'),
          ],
        ),
      ),
      'transaction tile': const TransactionTile(
        merchantName: 'Mercadona',
        categoryLabel: 'Groceries',
        categoryPaletteIndex: 0,
        amountMinorUnits: -4211,
        currencyCode: 'EUR',
        subtitle: 'Today, 18:24',
      ),
      'income tile': const TransactionTile(
        merchantName: 'Acme Corp',
        categoryLabel: 'Income',
        categoryPaletteIndex: 6,
        amountMinorUnits: 245000,
        currencyCode: 'EUR',
        subtitle: 'Jul 1',
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'chips_badges_avatar',
    scenarios: {
      'category chips': const Wrap(
        spacing: LdsSpacing.xs,
        children: [
          CategoryChip(label: 'Groceries', paletteIndex: 0),
          CategoryChip(
            label: 'Transport',
            paletteIndex: 1,
            icon: Icons.directions_bus_rounded,
          ),
          CategoryChip(label: 'Dining', paletteIndex: 3),
        ],
      ),
      'trend badges': const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TrendBadge(percent: 12.5, upIsGood: false),
          SizedBox(width: LdsSpacing.xs),
          TrendBadge(percent: -8.2, upIsGood: false),
          SizedBox(width: LdsSpacing.xs),
          TrendBadge(percent: 4.1),
        ],
      ),
      'avatars': const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LdsAvatar(label: 'Mercadona'),
          SizedBox(width: LdsSpacing.xs),
          LdsAvatar(label: 'Netflix'),
          SizedBox(width: LdsSpacing.xs),
          LdsAvatar(label: 'Uber'),
          SizedBox(width: LdsSpacing.xs),
          LdsAvatar(label: 'Savings', icon: Icons.savings_rounded),
        ],
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'status_views',
    constraints: const BoxConstraints(maxWidth: 420, maxHeight: 380),
    scenarios: {
      'empty': const LdsEmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'No transactions yet',
        message: 'When money moves, it shows up here.',
        actionLabel: 'Add demo data',
        onAction: _noop,
      ),
      'error': const LdsErrorState(
        title: 'Something went wrong',
        message: "We couldn't load your activity.",
        retryLabel: 'Try again',
        onRetry: _noop,
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'skeleton',
    scenarios: {
      // ldsWrap forces reduced motion, so the shimmer renders deterministically.
      'blocks': const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          LdsSkeleton(width: 120, height: 12),
          SizedBox(height: LdsSpacing.xs),
          LdsSkeleton(height: 44),
          SizedBox(height: LdsSpacing.xs),
          LdsSkeleton(width: 220, height: 12),
        ],
      ),
    },
  );
}

void _noop() {}
