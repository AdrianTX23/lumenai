import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumen_app/common/category_ui.dart';
import 'package:lumen_app/common/money_locale.dart';
import 'package:lumen_app/features/activity/presentation/controllers/activity_controller.dart';
import 'package:lumen_app/features/activity/presentation/widgets/transaction_detail_sheet.dart';

/// Transaction feed with search and category filters.
class ActivityScreen extends ConsumerStatefulWidget {
  /// Creates the activity screen.
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;
    final filter = ref.watch(activityControllerProvider);
    final feed = ref.watch(activityFeedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            LdsSpacing.md,
            LdsSpacing.lg,
            LdsSpacing.md,
            LdsSpacing.sm,
          ),
          child: Text(l10n.activityTitle, style: lds.typography.title),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LdsSpacing.md),
          child: LdsSearchField(
            hint: l10n.activitySearchHint,
            controller: _searchController,
            onChanged: ref.read(activityControllerProvider.notifier).setSearch,
          ),
        ),
        const SizedBox(height: LdsSpacing.sm),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: LdsSpacing.md),
            children: [
              for (final category in Category.values)
                if (category.isSpending)
                  Padding(
                    padding: const EdgeInsets.only(right: LdsSpacing.xs),
                    child: _FilterChip(
                      category: category,
                      selected: filter.category == category,
                      onTap: () => ref
                          .read(activityControllerProvider.notifier)
                          .toggleCategory(category),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: LdsSpacing.xs),
        Expanded(
          child: switch (feed) {
            AsyncData(:final value) when value.isEmpty => LdsEmptyState(
                icon: Icons.receipt_long_rounded,
                title: l10n.activityEmptyTitle,
                message: l10n.activityEmptyMessage,
              ),
            AsyncData(:final value) => ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: LdsSpacing.jumbo + LdsSpacing.xxl,
                ),
                itemCount: value.length,
                itemBuilder: (context, index) {
                  final transaction = value[index];
                  // Isolates each row's repaint region so scrolling
                  // doesn't force sibling rows to redraw — the feed can
                  // run into the thousands of transactions (docs/06 §4).
                  return RepaintBoundary(
                    key: ValueKey(transaction.id),
                    child: _FeedTile(transaction: transaction),
                  );
                },
              ),
            AsyncError() => LdsErrorState(
                title: l10n.errorTitle,
                message: l10n.errorMessage,
                retryLabel: l10n.errorRetry,
                onRetry: () => ref.invalidate(activityFeedProvider),
              ),
            _ => ListView(
                children: [
                  for (var i = 0; i < 8; i++)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: LdsSpacing.md,
                        vertical: LdsSpacing.xs,
                      ),
                      child: LdsSkeleton(height: 56),
                    ),
                ],
              ),
          },
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: LdsMotion.fast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LdsRadius.full),
          border: Border.all(
            color: selected ? lds.colors.accent : lds.colors.borderSubtle,
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: CategoryChip(
          label: category.label(l10n),
          paletteIndex: category.paletteIndex,
          icon: category.icon,
        ),
      ),
    );
  }
}

class _FeedTile extends ConsumerWidget {
  const _FeedTile({required this.transaction});

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
      subtitle: DateFormat.MMMd(locale).add_Hm().format(transaction.timestamp),
      onTap: () => showTransactionDetailSheet(context, transaction),
    );
  }
}
