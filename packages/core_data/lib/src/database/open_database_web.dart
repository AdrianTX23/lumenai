import 'package:core_data/src/database/lumen_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens the browser-persisted database (IndexedDB/OPFS, via Drift's
/// wasm executor). [fileName] becomes the database's IndexedDB name.
///
/// [encryptionKey] is accepted only so this file's public API matches
/// [openAppDatabase]'s native counterpart — there is no SQLCipher/wasm
/// build, so it's unused here. That's an acceptable tradeoff for a web
/// demo: the browser already sandboxes storage per-origin, and the
/// prod flavor (the only caller that ever supplies a key) isn't the one
/// used for the web build anyway (see `main_web.dart`).
LumenDatabase openAppDatabase({
  String fileName = 'lumen.db',
  Future<String> Function()? encryptionKey,
}) {
  return LumenDatabase(
    LazyDatabase(() async {
      final result = await WasmDatabase.open(
        databaseName: fileName,
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    }),
  );
}

/// Not used on web — only test/tooling code calls this, and that runs
/// on the Dart VM (via the native implementation), never a web target.
LumenDatabase openInMemoryDatabase() =>
    throw UnsupportedError('openInMemoryDatabase is not available on web.');
