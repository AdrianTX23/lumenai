import 'dart:io';

import 'package:core_data/src/database/lumen_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the on-device database in the app's documents directory.
///
/// Executor construction lives in core_data so the composition root never
/// imports drift directly. SQLCipher encryption swaps in here in Phase 6
/// without touching any caller.
LumenDatabase openAppDatabase({String fileName = 'lumen.db'}) {
  return LumenDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      return NativeDatabase.createInBackground(
        File(p.join(dir.path, fileName)),
      );
    }),
  );
}

/// Opens an in-memory database (tests and ephemeral dev runs).
LumenDatabase openInMemoryDatabase() => LumenDatabase(NativeDatabase.memory());
