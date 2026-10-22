import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the SQLite database from the app's documents directory using the
/// native `sqlite3` library via `dart:ffi`.
LazyDatabase openDatabase() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'clash_command.db'));
    return NativeDatabase.createInBackground(file);
  });
}
