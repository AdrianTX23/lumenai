/// Opens the app database — SQLite via `NativeDatabase` on mobile/desktop,
/// or Drift's wasm executor (IndexedDB/OPFS) on web. Both implementations
/// expose the same `openAppDatabase`/`openInMemoryDatabase` API so callers
/// (the composition root, tests) never branch on platform themselves; see
/// `open_database_native.dart` and `open_database_web.dart` for the
/// platform-specific details and tradeoffs (encryption, in particular).
library;

export 'open_database_native.dart'
    if (dart.library.js_interop) 'open_database_web.dart';
