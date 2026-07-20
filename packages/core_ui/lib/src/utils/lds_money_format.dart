import 'package:intl/intl.dart';

/// Formats monetary amounts expressed in minor units.
///
/// The single formatting authority for the design system: `AmountText` and
/// charts render through this, so grouping, decimals and symbol placement
/// are consistent everywhere. Amounts are ints by policy — `double` money
/// does not exist in this codebase (docs/04-domain-model.md).
abstract final class LdsMoneyFormat {
  /// Currencies whose everyday usage carries no subdivision, even where
  /// ISO 4217 nominally defines one. COP is the canonical case: Colombia
  /// hasn't transacted in centavos for decades, so every peso amount in
  /// this app is a whole unit — and the symbol leads (`$ 15.000`), which
  /// CLDR's es_CO data gets wrong (it trails). Formatting correctness for
  /// a currency this central to the product must not depend on a
  /// library's inference — it is stated here explicitly and tested.
  static const Map<String, int> _decimalDigitsOverride = {'COP': 0};

  /// Renders [minorUnits] of [currencyCode] for [locale].
  ///
  /// [signed] prefixes an explicit `+` on positive amounts (income
  /// emphasis); negatives always carry `-`. [compact] drops decimals when
  /// they are zero (hero displays: `€1,240` instead of `€1,240.00`) — a
  /// no-op for zero-decimal currencies, which are always compact.
  static String format(
    int minorUnits, {
    required String currencyCode,
    String locale = 'en',
    bool signed = false,
    bool compact = false,
  }) {
    final override = _decimalDigitsOverride[currencyCode];
    final NumberFormat formatter;
    if (override != null) {
      final symbol = NumberFormat.simpleCurrency(
        locale: locale,
        name: currencyCode,
      ).currencySymbol;
      formatter = NumberFormat.currency(
        locale: locale,
        symbol: symbol,
        decimalDigits: override,
        // Leading symbol with a space, grouping from the locale.
        customPattern: '¤ #,##0',
      );
    } else {
      formatter = NumberFormat.simpleCurrency(
        locale: locale,
        name: currencyCode,
      );
    }

    final digits = override ?? formatter.decimalDigits!;
    final scale = _scaleFor(digits);
    final major = minorUnits / scale;
    if (compact && minorUnits % scale == 0) {
      formatter.maximumFractionDigits = 0;
    }
    final text = formatter.format(major.abs());
    final sign = minorUnits < 0 ? '-' : (signed && minorUnits > 0 ? '+' : '');
    return '$sign$text';
  }

  static int _scaleFor(int decimalDigits) {
    var scale = 1;
    for (var i = 0; i < decimalDigits; i++) {
      scale *= 10;
    }
    return scale;
  }
}
