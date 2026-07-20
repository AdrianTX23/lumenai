import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lumen_app/common/category_ui.dart';
import 'package:lumen_app/common/money_locale.dart';
import 'package:lumen_app/features/insights/presentation/controllers/insights_providers.dart';
import 'package:lumen_app/features/insights/presentation/widgets/subscription_row.dart';
import 'package:lumen_app/router/routes.dart';

/// Spending breakdown, cashflow, recurring charges and next-month forecast
/// — all computed locally from the transaction ledger (docs/04 §2).
class InsightsScreen extends ConsumerWidget {
  /// Creates the Insights screen.
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lds = context.lds;
    final breakdown = ref.watch(spendingBreakdownProvider);
    final cashflow = ref.watch(monthlyCashflowProvider);
    final subscriptions = ref.watch(subscriptionsProvider);
    final forecast = ref.watch(cashflowForecastProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LdsSpacing.md,
        LdsSpacing.lg,
        LdsSpacing.md,
        LdsSpacing.jumbo + LdsSpacing.xxl,
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.insightsTitle, style: lds.typography.title),
            LdsButton(
              label: l10n.budgetsTitle,
              variant: LdsButtonVariant.ghost,
              size: LdsButtonSize.small,
              icon: Icons.donut_large_rounded,
              onPressed: () => context.pushNamed(AppRoutes.budgets.name),
            ),
          ],
        ),
        const SizedBox(height: LdsSpacing.xl),
        Text(l10n.insightsSpendingByCategory, style: lds.typography.heading),
        const SizedBox(height: LdsSpacing.md),
        switch (breakdown) {
          AsyncData(:final value) when value.isEmpty => Text(
              l10n.insightsEmptyBreakdown,
              style: lds.typography.bodyMuted,
            ),
          AsyncData(:final value) => _BreakdownSection(entries: value),
          AsyncError() =>
            Text(l10n.errorMessage, style: lds.typography.bodyMuted),
          _ => const LdsSkeleton(height: 168, radius: LdsRadius.full),
        },
        const SizedBox(height: LdsSpacing.xl),
        Text(l10n.insightsCashflowTitle, style: lds.typography.heading),
        const SizedBox(height: LdsSpacing.md),
        switch (cashflow) {
          AsyncData(:final value) => Builder(
              builder: (context) {
                final locale = Localizations.localeOf(context).toLanguageTag();
                return CashflowBars(
                  incomeLabel: l10n.insightsIncome,
                  spendLabel: l10n.insightsSpend,
                  points: [
                    for (final entry in value)
                      CashflowPoint(
                        label: DateFormat.MMM(locale).format(entry.periodStart),
                        income: entry.income.minorUnits.toDouble(),
                        spend: entry.spend.minorUnits.toDouble(),
                      ),
                  ],
                );
              },
            ),
          AsyncError() =>
            Text(l10n.errorMessage, style: lds.typography.bodyMuted),
          _ => const LdsSkeleton(height: 160, radius: LdsRadius.md),
        },
        const SizedBox(height: LdsSpacing.xl),
        switch (forecast) {
          AsyncData(:final value) when value != null =>
            _ForecastCard(forecast: value),
          _ => const SizedBox.shrink(),
        },
        const SizedBox(height: LdsSpacing.xl),
        Text(l10n.insightsSubscriptionsTitle, style: lds.typography.heading),
        const SizedBox(height: LdsSpacing.md),
        switch (subscriptions) {
          AsyncData(:final value) when value.isEmpty => Text(
              l10n.insightsSubscriptionsEmpty,
              style: lds.typography.bodyMuted,
            ),
          AsyncData(:final value) => LdsCard(
              padding: const EdgeInsets.symmetric(vertical: LdsSpacing.xs),
              child: Column(
                children: [
                  for (final insight in value)
                    SubscriptionRow(insight: insight),
                ],
              ),
            ),
          AsyncError() =>
            Text(l10n.errorMessage, style: lds.typography.bodyMuted),
          _ => const LdsSkeleton(height: 220, radius: LdsRadius.card),
        },
      ],
    );
  }
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({required this.entries});

  final List<CategorySpend> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;
    final palette = lds.colors.dataViz;
    final total = entries.fold<int>(0, (sum, e) => sum + e.total.minorUnits);
    final currency = entries.first.total.currencyCode;

    final slices = [
      for (final entry in entries)
        DonutSlice(
          label: entry.category.label(l10n),
          value: entry.total.minorUnits.toDouble(),
          valueLabel: LdsMoneyFormat.format(
            entry.total.minorUnits,
            currencyCode: entry.total.currencyCode,
            locale: appMoneyLocale,
          ),
          color: palette[entry.category.paletteIndex % palette.length],
        ),
    ];

    return Column(
      children: [
        Center(
          child: SpendDonut(
            slices: slices,
            centerLabel: l10n.insightsThisMonth,
            centerValue: LdsMoneyFormat.format(
              total,
              currencyCode: currency,
              locale: appMoneyLocale,
              compact: true,
            ),
          ),
        ),
        const SizedBox(height: LdsSpacing.lg),
        SpendDonutLegend(slices: slices),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.forecast});

  final CashflowForecast forecast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;
    return LdsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.insightsForecastTitle, style: lds.typography.heading),
          const SizedBox(height: LdsSpacing.xs),
          AmountText(
            -forecast.projectedSpend.minorUnits,
            currencyCode: forecast.projectedSpend.currencyCode,
            emphasis: AmountEmphasis.hero,
            locale: appMoneyLocale,
          ),
          const SizedBox(height: LdsSpacing.xxs),
          Text(l10n.insightsForecastCaption, style: lds.typography.caption),
        ],
      ),
    );
  }
}
