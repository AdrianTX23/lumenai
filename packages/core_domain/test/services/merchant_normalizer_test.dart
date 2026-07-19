import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

void main() {
  const normalizer = MerchantNormalizer();

  group('MerchantNormalizer rules', () {
    test('maps known descriptors to display names', () {
      expect(normalizer.normalize('AMZN MKTP ES*2K3XY12'), 'Amazon');
      expect(normalizer.normalize('NETFLIX.COM 866-579-7172'), 'Netflix');
      expect(normalizer.normalize('PAYPAL *SPOTIFY'), 'Spotify');
      expect(normalizer.normalize('MERCADONA C/VALENCIA 123'), 'Mercadona');
      expect(normalizer.normalize('APPLE.COM/BILL'), 'Apple');
    });

    test('order matters: Uber Eats wins over Uber', () {
      expect(normalizer.normalize('UBER EATS MADRID'), 'Uber Eats');
      expect(normalizer.normalize('UBER *TRIP'), 'Uber');
    });

    test('is case-insensitive on input', () {
      expect(normalizer.normalize('netflix.com'), 'Netflix');
    });
  });

  group('MerchantNormalizer cleanup fallback', () {
    test('strips reference codes and title-cases the rest', () {
      expect(
        normalizer.normalize('CAFETERIA SOL *8842 MADRID'),
        'Cafeteria Sol Madrid',
      );
    });

    test('strips long digit runs and dates', () {
      expect(
        normalizer.normalize('PARKING 000123456 15/07'),
        'Parking',
      );
    });

    test('never returns empty for noise-only descriptors', () {
      final result = normalizer.normalize('*8842 991234');
      expect(result.trim(), isNotEmpty);
    });
  });
}
