import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Money', () {
    const euros = 'EUR';

    test('arithmetic stays in integer minor units', () {
      const a = Money.minor(1050, euros);
      const b = Money.minor(-250, euros);

      expect(a + b, const Money.minor(800, euros));
      expect(a - b, const Money.minor(1300, euros));
      expect(-a, const Money.minor(-1050, euros));
      expect(b.abs(), const Money.minor(250, euros));
    });

    test('sign predicates', () {
      expect(const Money.minor(1, euros).isPositive, isTrue);
      expect(const Money.minor(-1, euros).isNegative, isTrue);
      expect(const Money.zero(euros).isZero, isTrue);
    });

    test('comparison orders by amount', () {
      const small = Money.minor(100, euros);
      const big = Money.minor(200, euros);

      expect(small.compareTo(big), lessThan(0));
      expect([big, small]..sort(), [small, big]);
    });

    test('currency mismatch is a programming error, not a Failure', () {
      const eur = Money.minor(100, 'EUR');
      const usd = Money.minor(100, 'USD');

      expect(() => eur + usd, throwsArgumentError);
      expect(() => eur - usd, throwsArgumentError);
      expect(() => eur.compareTo(usd), throwsArgumentError);
    });

    test('value equality', () {
      expect(const Money.minor(500, euros), const Money.minor(500, euros));
      expect(
        const Money.minor(500, euros),
        isNot(const Money.minor(500, 'USD')),
      );
      expect(
        const Money.minor(500, euros).hashCode,
        const Money.minor(500, euros).hashCode,
      );
    });
  });
}
