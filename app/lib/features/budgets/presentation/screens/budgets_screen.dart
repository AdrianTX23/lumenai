import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_app/common/category_ui.dart';
import 'package:lumen_app/common/money_locale.dart';
import 'package:lumen_app/di/di.dart';
import 'package:lumen_app/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:lumen_app/features/budgets/presentation/widgets/create_budget_sheet.dart';

/// Monthly spending envelopes with a live pace-vs-limit indicator.
///
/// Pushed from Insights, not a bottom-bar tab — docs/03-design-system.md
/// §4 is explicit that a 5th tab would dilute the IA.
class BudgetsScreen extends ConsumerWidget {
  /// Creates the Budgets screen.
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lds = context.lds;
    final budgets = ref.watch(budgetsProvider);
    final spendByCategory = ref.watch(budgetSpendProvider);

    return LdsScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LdsSpacing.xs,
              LdsSpacing.md,
              LdsSpacing.md,
              LdsSpacing.sm,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: lds.colors.textPrimary,
                  ),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(l10n.budgetsTitle, style: lds.typography.title),
                ),
                IconButton(
                  icon: Icon(Icons.add_rounded, color: lds.colors.accent),
                  onPressed: () => showCreateBudgetSheet(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (budgets) {
              AsyncData(:final value) when value.isEmpty => LdsEmptyState(
                  icon: Icons.donut_large_rounded,
                  title: l10n.budgetsEmptyTitle,
                  message: l10n.budgetsEmptyMessage,
                  actionLabel: l10n.budgetsAdd,
                  onAction: () => showCreateBudgetSheet(context),
                ),
              AsyncData(:final value) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    LdsSpacing.md,
                    0,
                    LdsSpacing.md,
                    LdsSpacing.jumbo,
                  ),
                  children: [
                    for (final budget in value)
                      _BudgetTile(
                        budget: budget,
                        spentMinorUnits: spendByCategory
                                .valueOrNull?[budget.category]?.minorUnits ??
                            0,
                      ),
                  ],
                ),
              AsyncError() => LdsErrorState(
                  title: l10n.errorTitle,
                  message: l10n.errorMessage,
                  retryLabel: l10n.errorRetry,
                  onRetry: () => ref.invalidate(budgetsProvider),
                ),
              _ => ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: LdsSpacing.md),
                  children: const [
                    LdsSkeleton(height: 56),
                    SizedBox(height: LdsSpacing.md),
                    LdsSkeleton(height: 56),
                  ],
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _BudgetTile extends ConsumerWidget {
  const _BudgetTile({required this.budget, required this.spentMinorUnits});

  final Budget budget;
  final int spentMinorUnits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lds = context.lds;
    final fraction = spentMinorUnits / budget.limit.minorUnits;
    final over = fraction > 1;
    final near = !over && fraction >= BudgetPaceBar.nearLimitThreshold;
    final status =
        over ? l10n.budgetsOverBudget : (near ? l10n.budgetsNearLimit : null);

    return Padding(
      padding: const EdgeInsets.only(bottom: LdsSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: BudgetPaceBar(
              label: budget.category.label(l10n),
              spentLabel: LdsMoneyFormat.format(
                spentMinorUnits,
                currencyCode: budget.limit.currencyCode,
                locale: appMoneyLocale,
              ),
              limitLabel: LdsMoneyFormat.format(
                budget.limit.minorUnits,
                currencyCode: budget.limit.currencyCode,
                locale: appMoneyLocale,
              ),
              fraction: fraction,
              statusLabel: status,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: lds.colors.textMuted,
            ),
            onPressed: () async {
              final result = await ref.read(deleteBudgetProvider)(budget.id);
              if (!context.mounted) return;
              result.fold(
                onOk: (_) => LdsSnack.show(context, l10n.budgetsDeleted),
                onErr: (_) {},
              );
            },
          ),
        ],
      ),
    );
  }
}
