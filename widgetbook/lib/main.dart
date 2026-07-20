import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:lumen_widgetbook/showcases/token_showcases.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(const LumenWidgetbook());

/// The living catalog of the LUMEN Design System.
///
/// Every core_ui component registers its use cases here; the web build is
/// deployed to GitHub Pages so the design system can be explored without
/// installing anything.
class LumenWidgetbook extends StatelessWidget {
  const LumenWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Dark', data: buildLdsDarkTheme()),
            WidgetbookTheme(name: 'Light', data: buildLdsLightTheme()),
          ],
        ),
        ViewportAddon([Viewports.none, IosViewports.iPhone13]),
      ],
      directories: [
        WidgetbookFolder(
          name: 'Tokens',
          children: [
            WidgetbookComponent(
              name: 'Colors',
              useCases: [
                WidgetbookUseCase(
                  name: 'Semantic palette',
                  builder: (_) => const ColorTokensShowcase(),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'Typography',
              useCases: [
                WidgetbookUseCase(
                  name: 'Type scale',
                  builder: (_) => const TypographyShowcase(),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'Spacing & Shape',
              useCases: [
                WidgetbookUseCase(
                  name: 'Scales',
                  builder: (_) => const SpacingShowcase(),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Actions',
          children: [
            WidgetbookComponent(
              name: 'LdsButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Variants',
                  builder: (_) => const _Pad(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LdsButton(label: 'Primary', onPressed: _noop),
                        SizedBox(height: LdsSpacing.sm),
                        LdsButton(
                          label: 'Secondary',
                          onPressed: _noop,
                          variant: LdsButtonVariant.secondary,
                        ),
                        SizedBox(height: LdsSpacing.sm),
                        LdsButton(
                          label: 'Ghost',
                          onPressed: _noop,
                          variant: LdsButtonVariant.ghost,
                        ),
                        SizedBox(height: LdsSpacing.sm),
                        LdsButton(
                          label: 'Destructive',
                          onPressed: _noop,
                          variant: LdsButtonVariant.destructive,
                        ),
                      ],
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'States',
                  builder: (_) => const _Pad(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LdsButton(label: 'Enabled', onPressed: _noop),
                        SizedBox(height: LdsSpacing.sm),
                        LdsButton(
                          label: 'Loading',
                          onPressed: _noop,
                          loading: true,
                        ),
                        SizedBox(height: LdsSpacing.sm),
                        LdsButton(label: 'Disabled', onPressed: null),
                        SizedBox(height: LdsSpacing.sm),
                        LdsButton(
                          label: 'With icon',
                          onPressed: _noop,
                          icon: Icons.add_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Display',
          children: [
            WidgetbookComponent(
              name: 'AmountText',
              useCases: [
                WidgetbookUseCase(
                  name: 'Emphasis & sign',
                  builder: (_) => const _Pad(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AmountText(
                          1224065,
                          currencyCode: 'EUR',
                          emphasis: AmountEmphasis.hero,
                          colored: false,
                        ),
                        SizedBox(height: LdsSpacing.md),
                        AmountText(245000, currencyCode: 'EUR'),
                        SizedBox(height: LdsSpacing.xs),
                        AmountText(-4211, currencyCode: 'EUR'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'TransactionTile',
              useCases: [
                WidgetbookUseCase(
                  name: 'Spend & income',
                  builder: (_) => const _Pad(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TransactionTile(
                          merchantName: 'Mercadona',
                          categoryLabel: 'Groceries',
                          categoryPaletteIndex: 0,
                          amountMinorUnits: -4211,
                          currencyCode: 'EUR',
                          subtitle: 'Today, 18:24',
                          onTap: _noop,
                        ),
                        TransactionTile(
                          merchantName: 'Netflix',
                          categoryLabel: 'Subscriptions',
                          categoryPaletteIndex: 2,
                          amountMinorUnits: -1299,
                          currencyCode: 'EUR',
                          subtitle: 'Jul 12',
                          onTap: _noop,
                        ),
                        TransactionTile(
                          merchantName: 'Acme Corp',
                          categoryLabel: 'Income',
                          categoryPaletteIndex: 6,
                          amountMinorUnits: 245000,
                          currencyCode: 'EUR',
                          subtitle: 'Jul 1',
                          onTap: _noop,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'LdsCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (_) => const _Pad(
                    child: Center(
                      child: LdsCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monthly spending'),
                            SizedBox(height: LdsSpacing.xs),
                            AmountText(-184230, currencyCode: 'EUR'),
                            SizedBox(height: LdsSpacing.xs),
                            TrendBadge(percent: -8.2, upIsGood: false),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'Chips & Badges',
              useCases: [
                WidgetbookUseCase(
                  name: 'Gallery',
                  builder: (_) => const _Pad(
                    child: Center(
                      child: Wrap(
                        spacing: LdsSpacing.xs,
                        runSpacing: LdsSpacing.xs,
                        children: [
                          CategoryChip(label: 'Groceries', paletteIndex: 0),
                          CategoryChip(
                            label: 'Transport',
                            paletteIndex: 1,
                            icon: Icons.directions_bus_rounded,
                          ),
                          CategoryChip(label: 'Dining', paletteIndex: 3),
                          TrendBadge(percent: 12.5, upIsGood: false),
                          TrendBadge(percent: -8.2, upIsGood: false),
                          TrendBadge(percent: 4.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'LdsAvatar',
              useCases: [
                WidgetbookUseCase(
                  name: 'Monograms & icon',
                  builder: (_) => const _Pad(
                    child: Center(
                      child: Wrap(
                        spacing: LdsSpacing.sm,
                        children: [
                          LdsAvatar(label: 'Mercadona'),
                          LdsAvatar(label: 'Netflix'),
                          LdsAvatar(label: 'Uber'),
                          LdsAvatar(
                            label: 'Savings',
                            icon: Icons.savings_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Wallet',
          children: [
            WidgetbookComponent(
              name: 'PaymentCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'Skins',
                  builder: (_) => const _Pad(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PaymentCard(
                            accountName: 'Lumen Current',
                            last4: '4821',
                            network: 'Visa',
                            balanceMinorUnits: 184230,
                          ),
                          SizedBox(height: LdsSpacing.md),
                          PaymentCard(
                            accountName: 'Rainy Day',
                            last4: '7710',
                            network: 'Visa',
                            skinIndex: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'CardStack',
              useCases: [
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (_) => const _Pad(
                    child: Center(
                      child: CardStack(
                        items: [
                          CardStackItem(
                            accountName: 'Lumen Current',
                            last4: '4821',
                            network: 'Visa',
                            skinIndex: 0,
                            balanceMinorUnits: 184230,
                          ),
                          CardStackItem(
                            accountName: 'Rainy Day',
                            last4: '7710',
                            network: 'Visa',
                            skinIndex: 1,
                            balanceMinorUnits: 1340000,
                          ),
                          CardStackItem(
                            accountName: 'Lumen Card',
                            last4: '9034',
                            network: 'Mastercard',
                            skinIndex: 2,
                            balanceMinorUnits: -42150,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Charts',
          children: [
            WidgetbookComponent(
              name: 'SpendDonut',
              useCases: [
                WidgetbookUseCase(
                  name: 'With legend',
                  builder: (context) => _Pad(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpendDonut(
                            centerValue: r'$ 1.240.000',
                            centerLabel: 'this month',
                            slices: [
                              DonutSlice(
                                label: 'Groceries',
                                value: 620000,
                                valueLabel: r'$ 620.000',
                                color: context.lds.colors.dataViz[0],
                              ),
                              DonutSlice(
                                label: 'Dining',
                                value: 340000,
                                valueLabel: r'$ 340.000',
                                color: context.lds.colors.dataViz[1],
                              ),
                              DonutSlice(
                                label: 'Transport',
                                value: 180000,
                                valueLabel: r'$ 180.000',
                                color: context.lds.colors.dataViz[2],
                              ),
                            ],
                          ),
                          const SizedBox(height: LdsSpacing.lg),
                          SpendDonutLegend(
                            slices: [
                              DonutSlice(
                                label: 'Groceries',
                                value: 620000,
                                valueLabel: r'$ 620.000',
                                color: context.lds.colors.dataViz[0],
                              ),
                              DonutSlice(
                                label: 'Dining',
                                value: 340000,
                                valueLabel: r'$ 340.000',
                                color: context.lds.colors.dataViz[1],
                              ),
                              DonutSlice(
                                label: 'Transport',
                                value: 180000,
                                valueLabel: r'$ 180.000',
                                color: context.lds.colors.dataViz[2],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'CashflowBars',
              useCases: [
                WidgetbookUseCase(
                  name: 'Six months',
                  builder: (_) => const _Pad(
                    child: CashflowBars(
                      incomeLabel: 'Income',
                      spendLabel: 'Spend',
                      points: [
                        CashflowPoint(
                          label: 'Feb',
                          income: 4200000,
                          spend: 3100000,
                        ),
                        CashflowPoint(
                          label: 'Mar',
                          income: 4200000,
                          spend: 3400000,
                        ),
                        CashflowPoint(
                          label: 'Apr',
                          income: 4200000,
                          spend: 2900000,
                        ),
                        CashflowPoint(
                          label: 'May',
                          income: 4200000,
                          spend: 3900000,
                        ),
                        CashflowPoint(
                          label: 'Jun',
                          income: 4200000,
                          spend: 3200000,
                        ),
                        CashflowPoint(
                          label: 'Jul',
                          income: 4200000,
                          spend: 3050000,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'BudgetPaceBar',
              useCases: [
                WidgetbookUseCase(
                  name: 'States',
                  builder: (_) => const _Pad(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BudgetPaceBar(
                          label: 'Groceries',
                          spentLabel: r'$ 420.000',
                          limitLabel: r'$ 800.000',
                          fraction: 0.52,
                        ),
                        SizedBox(height: LdsSpacing.md),
                        BudgetPaceBar(
                          label: 'Dining',
                          spentLabel: r'$ 340.000',
                          limitLabel: r'$ 400.000',
                          fraction: 0.9,
                          statusLabel: 'Near limit',
                        ),
                        SizedBox(height: LdsSpacing.md),
                        BudgetPaceBar(
                          label: 'Shopping',
                          spentLabel: r'$ 950.000',
                          limitLabel: r'$ 800.000',
                          fraction: 1.19,
                          statusLabel: 'Over budget',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Copilot',
          children: [
            WidgetbookComponent(
              name: 'ChatBubble',
              useCases: [
                WidgetbookUseCase(
                  name: 'Conversation',
                  builder: (_) => const _Pad(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ChatBubble(
                          role: ChatBubbleRole.user,
                          content: 'How much did I spend on dining?',
                        ),
                        SizedBox(height: LdsSpacing.sm),
                        ChatBubble(
                          role: ChatBubbleRole.assistant,
                          content: r"You've spent $ 328.494 on dining "
                              'this month.',
                          evidenceLabel: '9 sources',
                        ),
                        SizedBox(height: LdsSpacing.sm),
                        ChatBubble(
                          role: ChatBubbleRole.assistant,
                          content: 'Thinking',
                          isStreaming: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PromptSuggestionChip',
              useCases: [
                WidgetbookUseCase(
                  name: 'Row',
                  builder: (_) => const _Pad(
                    child: Wrap(
                      spacing: LdsSpacing.xs,
                      runSpacing: LdsSpacing.xs,
                      children: [
                        PromptSuggestionChip(
                          label: 'How much on dining?',
                          onTap: _noop,
                        ),
                        PromptSuggestionChip(
                          label: 'Any subscriptions?',
                          onTap: _noop,
                        ),
                        PromptSuggestionChip(
                          label: 'Forecast next month',
                          onTap: _noop,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'InsightCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'With confidence',
                  builder: (_) => const _Pad(
                    child: InsightCard(
                      title: 'Price increase detected',
                      body: r'Netflix went from $ 26.900 to $ 33.900, '
                          'a 26% increase.',
                      confidenceLabel: 'Based on 18 charges',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Feedback',
          children: [
            WidgetbookComponent(
              name: 'Status views',
              useCases: [
                WidgetbookUseCase(
                  name: 'Empty',
                  builder: (_) => const LdsEmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'No transactions yet',
                    message: 'When money moves, it shows up here.',
                    actionLabel: 'Add demo data',
                    onAction: _noop,
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Error',
                  builder: (_) => const LdsErrorState(
                    title: 'Something went wrong',
                    message: "We couldn't load your activity.",
                    retryLabel: 'Try again',
                    onRetry: _noop,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'LdsSkeleton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Shimmer',
                  builder: (_) => const _Pad(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LdsSkeleton(width: 120, height: 12),
                        SizedBox(height: LdsSpacing.xs),
                        LdsSkeleton(height: 44),
                        SizedBox(height: LdsSpacing.xs),
                        LdsSkeleton(width: 220, height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'LdsSnack & LdsSheet',
              useCases: [
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (context) => _Pad(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Builder(
                          builder: (context) => LdsButton(
                            label: 'Show snack',
                            onPressed: () => LdsSnack.show(
                              context,
                              'Budget created',
                              variant: LdsSnackVariant.success,
                            ),
                          ),
                        ),
                        const SizedBox(height: LdsSpacing.sm),
                        Builder(
                          builder: (context) => LdsButton(
                            label: 'Open sheet',
                            variant: LdsButtonVariant.secondary,
                            onPressed: () => showLdsSheet<void>(
                              context: context,
                              builder: (context) => Padding(
                                padding: const EdgeInsets.all(LdsSpacing.xl),
                                child: Text(
                                  'Sheet content',
                                  style: context.lds.typography.body,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

void _noop() {}

/// Standard use-case padding on the theme surface.
class _Pad extends StatelessWidget {
  const _Pad({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.lds.colors.surface,
      body: Padding(
        padding: const EdgeInsets.all(LdsSpacing.xl),
        child: child,
      ),
    );
  }
}
