/// An exact monetary amount: minor units (cents) + ISO 4217 currency code.
///
/// `double` money does not exist in this codebase — all arithmetic is
/// integer arithmetic on minor units. Mixing currencies in arithmetic or
/// comparison is a programming error and throws [ArgumentError]; it is
/// never a recoverable `Failure`.
final class Money implements Comparable<Money> {
  /// Creates an amount of [minorUnits] in [currencyCode].
  const Money.minor(this.minorUnits, this.currencyCode);

  /// Zero in [currencyCode].
  const Money.zero(this.currencyCode) : minorUnits = 0;

  /// Signed amount in minor units (e.g. cents).
  final int minorUnits;

  /// ISO 4217 code, e.g. `EUR`.
  final String currencyCode;

  /// Whether the amount is strictly negative (spend).
  bool get isNegative => minorUnits < 0;

  /// Whether the amount is strictly positive (income).
  bool get isPositive => minorUnits > 0;

  /// Whether the amount is exactly zero.
  bool get isZero => minorUnits == 0;

  /// Sum. Both operands must share a currency.
  Money operator +(Money other) {
    _guardCurrency(other);
    return Money.minor(minorUnits + other.minorUnits, currencyCode);
  }

  /// Difference. Both operands must share a currency.
  Money operator -(Money other) {
    _guardCurrency(other);
    return Money.minor(minorUnits - other.minorUnits, currencyCode);
  }

  /// Negation.
  Money operator -() => Money.minor(-minorUnits, currencyCode);

  /// Magnitude.
  Money abs() => Money.minor(minorUnits.abs(), currencyCode);

  @override
  int compareTo(Money other) {
    _guardCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _guardCurrency(Money other) {
    if (other.currencyCode != currencyCode) {
      throw ArgumentError(
        'Currency mismatch: $currencyCode vs ${other.currencyCode}',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currencyCode == currencyCode;

  @override
  int get hashCode => Object.hash(minorUnits, currencyCode);

  @override
  String toString() => 'Money($minorUnits $currencyCode)';
}
