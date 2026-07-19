import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Visual reference of the semantic color tokens for the active theme.
class ColorTokensShowcase extends StatelessWidget {
  const ColorTokensShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.lds.colors;
    final entries = <(String, Color)>[
      ('surface', c.surface),
      ('surfaceElevated', c.surfaceElevated),
      ('surfaceHigh', c.surfaceHigh),
      ('borderSubtle', c.borderSubtle),
      ('borderStrong', c.borderStrong),
      ('textPrimary', c.textPrimary),
      ('textMuted', c.textMuted),
      ('textFaint', c.textFaint),
      ('accent', c.accent),
      ('positive', c.positive),
      ('negative', c.negative),
      ('warning', c.warning),
      ('info', c.info),
    ];

    return ListView(
      padding: const EdgeInsets.all(LdsSpacing.xl),
      children: [
        Text('Semantic colors', style: context.lds.typography.title),
        const SizedBox(height: LdsSpacing.md),
        for (final (name, color) in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: LdsSpacing.xs),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(LdsRadius.sm),
                    border: Border.all(color: c.borderSubtle),
                  ),
                ),
                const SizedBox(width: LdsSpacing.sm),
                Text(name, style: context.lds.typography.body),
              ],
            ),
          ),
        const SizedBox(height: LdsSpacing.xl),
        Text('Accent gradient', style: context.lds.typography.title),
        const SizedBox(height: LdsSpacing.md),
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: c.accentGradient),
            borderRadius: BorderRadius.circular(LdsRadius.md),
          ),
        ),
        const SizedBox(height: LdsSpacing.xl),
        Text('Data-viz palette', style: context.lds.typography.title),
        const SizedBox(height: LdsSpacing.md),
        Row(
          children: [
            for (final color in c.dataViz)
              Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.only(right: LdsSpacing.xxs),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(LdsRadius.sm),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Visual reference of the type scale.
class TypographyShowcase extends StatelessWidget {
  const TypographyShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.lds.typography;
    final samples = <(String, TextStyle)>[
      ('displayXl 48/56', t.displayXl),
      ('display 34/40', t.display),
      ('title 24/30', t.title),
      ('heading 18/24', t.heading),
      ('body 15/22', t.body),
      ('bodyMuted 15/22', t.bodyMuted),
      ('label 13/18', t.label),
      ('caption 11/16', t.caption),
      ('moneyXl (tabular)', t.moneyXl),
      ('money (tabular)', t.money),
    ];

    return ListView(
      padding: const EdgeInsets.all(LdsSpacing.xl),
      children: [
        for (final (name, style) in samples) ...[
          Text(name, style: t.caption),
          Text(
            style == t.moneyXl || style == t.money
                ? '€1,234,567.89'
                : 'Your money, illuminated',
            style: style,
          ),
          const SizedBox(height: LdsSpacing.lg),
        ],
      ],
    );
  }
}

/// Visual reference of the spacing and radius scales.
class SpacingShowcase extends StatelessWidget {
  const SpacingShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final spacings = <(String, double)>[
      ('xxs 4', LdsSpacing.xxs),
      ('xs 8', LdsSpacing.xs),
      ('sm 12', LdsSpacing.sm),
      ('md 16', LdsSpacing.md),
      ('lg 20', LdsSpacing.lg),
      ('xl 24', LdsSpacing.xl),
      ('xxl 32', LdsSpacing.xxl),
      ('xxxl 40', LdsSpacing.xxxl),
      ('jumbo 56', LdsSpacing.jumbo),
    ];
    final radii = <(String, double)>[
      ('sm 10', LdsRadius.sm),
      ('md 16', LdsRadius.md),
      ('lg 24', LdsRadius.lg),
      ('card 28', LdsRadius.card),
    ];

    return ListView(
      padding: const EdgeInsets.all(LdsSpacing.xl),
      children: [
        Text('Spacing (4-pt base)', style: lds.typography.title),
        const SizedBox(height: LdsSpacing.md),
        for (final (name, value) in spacings)
          Padding(
            padding: const EdgeInsets.only(bottom: LdsSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(name, style: lds.typography.label),
                ),
                Container(
                  width: value,
                  height: 16,
                  color: lds.colors.accent,
                ),
              ],
            ),
          ),
        const SizedBox(height: LdsSpacing.xl),
        Text('Radius', style: lds.typography.title),
        const SizedBox(height: LdsSpacing.md),
        Row(
          children: [
            for (final (name, value) in radii)
              Padding(
                padding: const EdgeInsets.only(right: LdsSpacing.sm),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: lds.colors.surfaceElevated,
                        border: Border.all(color: lds.colors.borderStrong),
                        borderRadius: BorderRadius.circular(value),
                      ),
                    ),
                    const SizedBox(height: LdsSpacing.xxs),
                    Text(name, style: lds.typography.caption),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
