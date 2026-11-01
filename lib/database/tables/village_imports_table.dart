import 'package:drift/drift.dart';

import 'villages_table.dart';

/// Stores historical audit records of Clash of Clans village JSON imports.
@DataClassName('VillageImportRow')
class VillageImports extends Table {
  TextColumn get id => text()();
  TextColumn get villageId =>
      text().references(Villages, #id, onDelete: KeyAction.cascade)();
  TextColumn get villageTag => text().withLength(min: 1, max: 50)();
  IntColumn get snapshotTimestamp => integer()();
  DateTimeColumn get importedAtUtc => dateTime()();
  IntColumn get importedRecordCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get skippedRecordCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get activeUpgradesCount =>
      integer().withDefault(const Constant(0))();
  TextColumn get importMode =>
      text().withLength(min: 1, max: 20)(); // 'merge' or 'replace'
  TextColumn get result =>
      text().withLength(min: 1, max: 20)(); // 'success', 'warning', 'error'
  TextColumn get summaryJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
