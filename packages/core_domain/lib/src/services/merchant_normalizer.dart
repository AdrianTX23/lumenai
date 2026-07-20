/// Turns raw bank descriptors into human merchant names.
///
/// Two stages: (1) table-driven rules for known merchants — first match
/// wins, order matters ("UBER EATS" before "UBER"); (2) generic cleanup
/// for unknowns (strip reference codes, collapse whitespace, title-case).
/// Pure and deterministic — the AI never touches this path.
final class MerchantNormalizer {
  /// Creates a normalizer with the built-in rule table.
  const MerchantNormalizer();

  static final _rules = <(RegExp, String)>[
    // Global platforms.
    (RegExp('AMZN|AMAZON'), 'Amazon'),
    (RegExp('NETFLIX'), 'Netflix'),
    (RegExp('SPOTIFY'), 'Spotify'),
    (RegExp(r'RAPPI\s*PRO'), 'Rappi Pro'),
    (RegExp('RAPPI'), 'Rappi'),
    (RegExp(r'UBER\s*EATS'), 'Uber Eats'),
    (RegExp('UBER'), 'Uber'),
    (RegExp('DIDI'), 'DiDi'),
    (RegExp(r'APPLE\.COM|ITUNES|ICLOUD'), 'Apple'),
    (RegExp(r'GOOGLE\s*\*?(YOUTUBE|STORAGE|ONE)'), 'Google'),
    (RegExp(r'PAYPAL\s*\*'), 'PayPal'),
    (RegExp(r'HBO|MAX\.COM'), 'Max'),
    (RegExp('ZARA'), 'Zara'),
    (RegExp('FALABELLA'), 'Falabella'),
    (RegExp('MERCADOLIBRE|MERCADO LIBRE'), 'Mercado Libre'),
    (RegExp('STEAM'), 'Steam'),
    // Colombian merchants and services.
    (RegExp(r'ALMACENES\s*EXITO|EXITO\b'), 'Éxito'),
    (RegExp('CARULLA'), 'Carulla'),
    (RegExp(r'TIENDAS\s*D1|D1\s*SAS'), 'D1'),
    (RegExp('OLIMPICA'), 'Olímpica'),
    (RegExp(r'JUAN\s*VALDEZ'), 'Juan Valdez'),
    (RegExp(r'EL\s*CORRAL'), 'El Corral'),
    (RegExp('CREPES'), 'Crepes & Waffles'),
    (RegExp('TRANSMILENIO|TULLAVE'), 'TransMilenio'),
    (RegExp(r'TAXIS\s*LIBRES'), 'Taxis Libres'),
    (RegExp('AVIANCA'), 'Avianca'),
    (RegExp('LATAM'), 'LATAM'),
    (RegExp(r'CINE\s*COLOMBIA'), 'Cine Colombia'),
    (RegExp(r'SMART\s*FIT'), 'Smart Fit'),
    (RegExp('ENEL|CODENSA'), 'Enel Codensa'),
    (RegExp('CLARO'), 'Claro'),
    (RegExp('MOVISTAR'), 'Movistar'),
    (RegExp('BANCOLOMBIA'), 'Bancolombia'),
    (RegExp('NEQUI'), 'Nequi'),
    (RegExp('DAVIVIENDA'), 'Davivienda'),
  ];

  /// Reference-code noise: `*2K3X`, `#1234`, long digit runs, dates.
  static final _noise = RegExp(
    r'([*#]\s?\w+)|(\b\d{4,}\b)|(\b\d{2}/\d{2}\b)',
  );

  /// Normalizes [raw] into a display name.
  String normalize(String raw) {
    final upper = raw.toUpperCase();
    for (final (pattern, name) in _rules) {
      if (pattern.hasMatch(upper)) return name;
    }
    return _cleanup(raw);
  }

  String _cleanup(String raw) {
    final stripped =
        raw.replaceAll(_noise, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (stripped.isEmpty) return raw.trim();
    return stripped
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
