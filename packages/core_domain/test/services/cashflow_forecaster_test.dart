import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

CashflowEntry _entry(int monthOffset, int spend, {int income = 3000000}) {
  return CashflowEntry(
    periodStart: DateTime(2026, 1 + monthOffset),
    income: Money.minor(income, 'COP'),
    spend: Money.minor(spend, 'COP'),
  );
}

void main() {
  const forecaster = CashflowForecaster();

  group('CashflowForecaster', () {
    test('returns null for empty history', () {
      expect(forecaster.forecast([]), isNull);
    });

    test('projects the period right after the last one', () {
      final forecast = forecaster.forecast([
        _entry(0, 1000000),
        _entry(1, 1200000),
      ])!;

      expect(forecast.periodStart, DateTime(2026, 3));
      expect(forecast.monthsConsidered, 2);
    });

    test('odd count uses the exact middle value as the median', () {
      final forecast = forecaster.forecast([
        _entry(0, 900000),
        _entry(1, 1500000),
        _entry(2, 1100000),
      ])!;

      expect(forecast.projectedSpend, const Money.minor(1100000, 'COP'));
    });

    test('even count averages the two middle values', () {
      final forecast = forecaster.forecast([
        _entry(0, 100000),
        _entry(1, 200000),
        _entry(2, 300000),
        _entry(3, 400000),
      ])!;

      expect(forecast.projectedSpend, const Money.minor(250000, 'COP'));
    });

    test('median is robust to a single outlier month, unlike a mean', () {
      final forecast = forecaster.forecast([
        _entry(0, 1000000),
        _entry(1, 1050000),
        _entry(2, 950000),
        _entry(3, 9000000), // a one-off trip, say.
        _entry(4, 1020000),
      ])!;

      // Mean would be ~2.6M, dragged far above what a typical month
      // actually costs. Median stays anchored to the ordinary months.
      expect(forecast.projectedSpend, const Money.minor(1020000, 'COP'));
    });

    test('preserves the trailing entries currency', () {
      final forecast = forecaster.forecast([_entry(0, 500000)])!;
      expect(forecast.projectedSpend.currencyCode, 'COP');
    });
  });
}
