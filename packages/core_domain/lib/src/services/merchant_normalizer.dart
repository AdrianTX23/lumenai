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
    (RegExp('AMZN|AMAZON'), 'Amazon'),
    (RegExp('NETFLIX'), 'Netflix'),
    (RegExp('SPOTIFY'), 'Spotify'),
    (RegExp(r'UBER\s*EATS'), 'Uber Eats'),
    (RegExp('UBER'), 'Uber'),
    (RegExp('MERCADONA'), 'Mercadona'),
    (RegExp('CARREFOUR'), 'Carrefour'),
    (RegExp('LIDL'), 'Lidl'),
    (RegExp(r'APPLE\.COM|ITUNES|ICLOUD'), 'Apple'),
    (RegExp(r'GOOGLE\s*\*?(YOUTUBE|STORAGE|ONE)'), 'Google'),
    (RegExp(r'PAYPAL\s*\*'), 'PayPal'),
    (RegExp('GLOVO'), 'Glovo'),
    (RegExp('RYANAIR'), 'Ryanair'),
    (RegExp('VUELING'), 'Vueling'),
    (RegExp('RENFE'), 'Renfe'),
    (RegExp('IBERDROLA'), 'Iberdrola'),
    (RegExp('VODAFONE'), 'Vodafone'),
    (RegExp(r'HBO|MAX\.COM'), 'Max'),
    (RegExp('ZARA'), 'Zara'),
    (RegExp('DECATHLON'), 'Decathlon'),
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
