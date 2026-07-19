import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/utils/lds_money_format.dart';
import 'package:flutter/widgets.dart';

/// Emphasis presets for [AmountText].
enum AmountEmphasis {
  /// Inline rows and tiles (money style, 15pt).
  inline,

  /// Hero figures (moneyXl style, 34pt).
  hero,
}

/// The single renderer for monetary values.
///
/// Sign and color policy lives here and nowhere else: negative amounts
/// render in the primary text color (spending is normal, not alarming),
/// positive amounts render in the positive color with an explicit `+`.
/// Always tabular figures — amounts never jitter.
class AmountText extends StatelessWidget {
  /// Creates an amount display for [minorUnits] of [currencyCode].
  const AmountText(
    this.minorUnits, {
    required this.currencyCode,
    this.emphasis = AmountEmphasis.inline,
    this.locale = 'en',
    this.colored = true,
    super.key,
  });

  /// Amount in minor units (cents). Ints by policy — never doubles.
  final int minorUnits;

  /// ISO 4217 code, e.g. `EUR`.
  final String currencyCode;

  /// Visual emphasis preset.
  final AmountEmphasis emphasis;

  /// BCP-47 locale tag for formatting.
  final String locale;

  /// Applies the positive color to income; `false` keeps primary text
  /// color (e.g. inside already-colored contexts).
  final bool colored;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final style = switch (emphasis) {
      AmountEmphasis.inline => lds.typography.money,
      AmountEmphasis.hero => lds.typography.moneyXl,
    };
    final color = colored && minorUnits > 0
        ? lds.colors.positive
        : lds.typography.money.color;
    final text = LdsMoneyFormat.format(
      minorUnits,
      currencyCode: currencyCode,
      locale: locale,
      signed: colored,
      compact: emphasis == AmountEmphasis.hero,
    );
    return Text(
      text,
      style: style.copyWith(color: color),
      semanticsLabel: text,
    );
  }
}
