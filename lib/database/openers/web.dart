import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens the SQLite database using the WebAssembly build of SQLite, used on
/// web browsers where `dart:ffi` is not available.
LazyDatabase openDatabase() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'clash_command',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      // ignore: avoid_print
      print(
        'Using ${result.chosenImplementation} due to missing browser features: '
        '${result.missingFeatures}',
      );
    }

    return result.resolvedExecutor;
  });
}
