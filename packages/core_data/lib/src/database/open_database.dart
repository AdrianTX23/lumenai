import 'dart:io';

import 'package:core_data/src/database/lumen_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the on-device database in the app's documents directory.
///
/// Executor construction lives in core_data so the composition root never
/// imports drift directly. When [encryptionKey] is given (prod flavor),
/// the connection is SQLCipher-encrypted at rest; omitting it (dev
/// flavor) opens a plain, unencrypted database for fast iteration — the
/// same `sqlcipher_flutter_libs`-provided SQLite binary reads both,
/// since an empty/absent key is a no-op for SQLCipher. [encryptionKey]
/// is a callback (not a plain string) so fetching it from secure storage
/// stays deferred to first DB access, same as the rest of `LazyDatabase`.
LumenDatabase openAppDatabase({
  String fileName = 'lumen.db',
  Future<String> Function()? encryptionKey,
}) {
  return LumenDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final key = await encryptionKey?.call();
      return NativeDatabase.createInBackground(
        File(p.join(dir.path, fileName)),
        setup: key == null
            ? null
            : (rawDb) => rawDb.execute("PRAGMA key = \"x'$key'\""),
      );
    }),
  );
}

/// Opens an in-memory database (tests and ephemeral dev runs).
LumenDatabase openInMemoryDatabase() => LumenDatabase(NativeDatabase.memory());
