import 'package:intl/intl.dart';

/// Formats monetary amounts expressed in minor units (cents).
///
/// The single formatting authority for the design system: `AmountText` and
/// charts render through this, so grouping, decimals and symbol placement
/// are consistent everywhere. Amounts are ints by policy — `double` money
/// does not exist in this codebase (docs/04-domain-model.md).
abstract final class LdsMoneyFormat {
  /// Renders [minorUnits] of [currencyCode] for [locale].
  ///
  /// [signed] prefixes an explicit `+` on positive amounts (income
  /// emphasis); negatives always carry `-`. [compact] drops decimals when
  /// they are zero (hero displays: `€1,240` instead of `€1,240.00`).
  static String format(
    int minorUnits, {
    required String currencyCode,
    String locale = 'en',
    bool signed = false,
    bool compact = false,
  }) {
    final formatter = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );
    final major = minorUnits / _minorPerMajor(formatter);
    if (compact && minorUnits % _minorPerMajor(formatter) == 0) {
      formatter.maximumFractionDigits = 0;
    }
    final text = formatter.format(major.abs());
    final sign = minorUnits < 0 ? '-' : (signed && minorUnits > 0 ? '+' : '');
    return '$sign$text';
  }

  static int _minorPerMajor(NumberFormat formatter) {
    var scale = 1;
    for (var i = 0; i < formatter.decimalDigits!; i++) {
      scale *= 10;
    }
    return scale;
  }
}
