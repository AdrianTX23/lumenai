import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

void main() {
  const normalizer = MerchantNormalizer();

  group('MerchantNormalizer rules', () {
    test('maps known descriptors to display names', () {
      expect(normalizer.normalize('AMZN MKTP CO*2K3XY12'), 'Amazon');
      expect(normalizer.normalize('NETFLIX.COM 866-579-7172'), 'Netflix');
      expect(normalizer.normalize('PAYPAL *SPOTIFY'), 'Spotify');
      expect(normalizer.normalize('ALMACENES EXITO CALLE 80'), 'Éxito');
      expect(normalizer.normalize('TIENDAS D1 SAS BOGOTA'), 'D1');
      expect(normalizer.normalize('APPLE.COM/BILL'), 'Apple');
      expect(
        normalizer.normalize('TRANSMILENIO RECARGA TULLAVE'),
        'TransMilenio',
      );
      expect(normalizer.normalize('ENEL CODENSA SA ESP'), 'Enel Codensa');
      expect(normalizer.normalize('SMART FIT COLOMBIA SAS'), 'Smart Fit');
    });

    test('order matters: Rappi Pro wins over Rappi', () {
      expect(normalizer.normalize('RAPPI PRO MEMBRESIA'), 'Rappi Pro');
      expect(normalizer.normalize('RAPPI*RESTAURANTES BOG'), 'Rappi');
    });

    test('is case-insensitive on input', () {
      expect(normalizer.normalize('netflix.com'), 'Netflix');
      expect(normalizer.normalize('juan valdez cafe 93'), 'Juan Valdez');
    });
  });

  group('MerchantNormalizer cleanup fallback', () {
    test('strips reference codes and title-cases the rest', () {
      expect(
        normalizer.normalize('PANADERIA LA ESPIGA *8842 BOGOTA'),
        'Panaderia La Espiga Bogota',
      );
    });

    test('strips long digit runs and dates', () {
      expect(
        normalizer.normalize('PARQUEADERO 000123456 15/07'),
        'Parqueadero',
      );
    });

    test('never returns empty for noise-only descriptors', () {
      final result = normalizer.normalize('*8842 991234');
      expect(result.trim(), isNotEmpty);
    });
  });
}
