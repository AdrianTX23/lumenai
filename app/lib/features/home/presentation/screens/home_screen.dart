import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lumen_app/common/category_ui.dart';
import 'package:lumen_app/common/money_locale.dart';
import 'package:lumen_app/features/home/presentation/controllers/home_providers.dart';
import 'package:lumen_app/router/routes.dart';

/// Wallet home: net-worth hero, card stack, recent activity.
class HomeScreen extends ConsumerWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lds = context.lds;
    final netWorth = ref.watch(netWorthProvider);
    final accounts = ref.watch(accountsProvider);
    final recent = ref.watch(recentTransactionsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LdsSpacing.md,
        LdsSpacing.lg,
        LdsSpacing.md,
        LdsSpacing.jumbo + LdsSpacing.xxl,
      ),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Semantics(
            button: true,
            label: l10n.homeSettings,
            child: IconButton(
              icon: Icon(Icons.settings_outlined, color: lds.colors.textMuted),
              onPressed: () => context.push(AppRoutes.settings.path),
            ),
          ),
        ),
        Text(l10n.homeNetWorth, style: lds.typography.bodyMuted),
        const SizedBox(height: LdsSpacing.xxs),
        switch (netWorth) {
          AsyncData(:final value) => AnimatedAmount(
              value.total.minorUnits,
              currencyCode: value.total.currencyCode,
              locale: appMoneyLocale,
            ),
          AsyncError() => Text('—', style: lds.typography.moneyXl),
          _ => const LdsSkeleton(width: 220, height: 40),
        },
        const SizedBox(height: LdsSpacing.xl),
        Text(l10n.homeAccounts, style: lds.typography.heading),
        const SizedBox(height: LdsSpacing.md),
        switch (accounts) {
          AsyncData(:final value) => Center(
              // Drag-driven card reordering repaints on every gesture
              // frame — isolate it so the rest of Home's scroll content
              // doesn't repaint along with it (docs/06 §4).
              child: RepaintBoundary(
                child: CardStack(
                  width: 340,
                  items: [
                    for (final snapshot in value)
                      CardStackItem(
                        accountName: snapshot.account.name,
                        last4: snapshot.account.cardMeta?.last4 ?? '····',
                        network: snapshot.account.cardMeta?.network ?? '',
                        skinIndex: snapshot.account.cardMeta?.skinIndex ??
                            snapshot.account.type.index + 1,
                        balanceMinorUnits: snapshot.balance.minorUnits,
                      ),
                  ],
                ),
              ),
            ),
          AsyncError() => _HomeError(ref: ref),
          _ => const LdsSkeleton(height: 214, radius: LdsRadius.lg),
        },
        const SizedBox(height: LdsSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.homeRecentActivity, style: lds.typography.heading),
            LdsButton(
              label: l10n.homeSeeAll,
              variant: LdsButtonVariant.ghost,
              size: LdsButtonSize.small,
              onPressed: () => context.goNamed(AppRoutes.activity.name),
            ),
          ],
        ),
        const SizedBox(height: LdsSpacing.xs),
        switch (recent) {
          AsyncData(:final value) => LdsCard(
              padding: const EdgeInsets.symmetric(vertical: LdsSpacing.xs),
              child: Column(
                children: [
                  for (final tx in value) _RecentTile(transaction: tx),
                ],
              ),
            ),
          AsyncError() => const SizedBox.shrink(),
          _ => const LdsSkeleton(height: 220, radius: LdsRadius.card),
        },
      ],
    );
  }
}

class _RecentTile extends ConsumerWidget {
  const _RecentTile({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return TransactionTile(
      merchantName: transaction.merchantName,
      categoryLabel: transaction.category.label(l10n),
      categoryPaletteIndex: transaction.category.paletteIndex,
      amountMinorUnits: transaction.amount.minorUnits,
      currencyCode: transaction.amount.currencyCode,
      locale: appMoneyLocale,
      subtitle: DateFormat.MMMd(locale).format(transaction.timestamp),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LdsErrorState(
      title: l10n.errorTitle,
      message: l10n.errorMessage,
      retryLabel: l10n.errorRetry,
      onRetry: () => ref.invalidate(accountsProvider),
    );
  }
}
