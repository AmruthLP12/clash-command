import 'package:drift/drift.dart';

/// Opens a database connection for unsupported platforms.
///
/// Web and native platforms provide their own implementations; this is only
/// used as a fallback so that the shared database code compiles everywhere.
LazyDatabase openDatabase() {
  throw UnsupportedError(
    'No database implementation is available for this platform.',
  );
}
