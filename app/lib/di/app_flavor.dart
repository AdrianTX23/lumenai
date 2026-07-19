/// Build flavors. The flavor selects a DI override set in `di.dart`;
/// no other code may branch on it — behavior differences live behind ports.
enum AppFlavor {
  /// Seeded demo data, mock adapters, verbose logging.
  dev,

  /// Encrypted storage, real adapters, quiet logging.
  prod,
}
