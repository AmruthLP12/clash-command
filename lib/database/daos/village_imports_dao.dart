import 'package:drift/drift.dart';

import 'package:clash_command/domain/models/village_import.dart';

import '../app_database.dart';
import '../tables/village_imports_table.dart';

part 'village_imports_dao.g.dart';

@DriftAccessor(tables: [VillageImports])
class VillageImportsDao extends DatabaseAccessor<AppDatabase>
    with _$VillageImportsDaoMixin {
  VillageImportsDao(super.db);

  /// Watches all import history records for a village, most recent first.
  Stream<List<VillageImport>> watchForVillage(String villageId) {
    return (select(villageImports)
          ..where((t) => t.villageId.equals(villageId))
          ..orderBy([(t) => OrderingTerm.desc(t.importedAtUtc)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Watches all import history records across all villages, most recent first.
  Stream<List<VillageImport>> watchAll() {
    return (select(villageImports)
          ..orderBy([(t) => OrderingTerm.desc(t.importedAtUtc)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Gets the most recent import record for a village, if any.
  Future<VillageImport?> getLatestForVillage(String villageId) async {
    final rows =
        await (select(villageImports)
              ..where((t) => t.villageId.equals(villageId))
              ..orderBy([(t) => OrderingTerm.desc(t.importedAtUtc)])
              ..limit(1))
            .get();
    if (rows.isEmpty) return null;
    return _toDomain(rows.first);
  }

  /// Checks if an exact snapshot timestamp was already imported for a village.
  Future<VillageImport?> findBySnapshot(
    String villageId,
    int snapshotTimestamp,
  ) async {
    final rows =
        await (select(villageImports)
              ..where(
                (t) =>
                    t.villageId.equals(villageId) &
                    t.snapshotTimestamp.equals(snapshotTimestamp),
              )
              ..limit(1))
            .get();
    if (rows.isEmpty) return null;
    return _toDomain(rows.first);
  }

  /// Inserts a new import history record.
  Future<void> insertImport(VillageImport importRecord) async {
    await into(villageImports).insert(_toCompanion(importRecord));
  }

  /// Deletes all import records for a village.
  Future<void> deleteForVillage(String villageId) async {
    await (delete(
      villageImports,
    )..where((t) => t.villageId.equals(villageId))).go();
  }

  VillageImport _toDomain(VillageImportRow row) {
    return VillageImport(
      id: row.id,
      villageId: row.villageId,
      villageTag: row.villageTag,
      snapshotTimestamp: row.snapshotTimestamp,
      importedAtUtc: row.importedAtUtc,
      importedRecordCount: row.importedRecordCount,
      skippedRecordCount: row.skippedRecordCount,
      activeUpgradesCount: row.activeUpgradesCount,
      importMode: row.importMode,
      result: row.result,
      summaryJson: row.summaryJson,
    );
  }

  VillageImportsCompanion _toCompanion(VillageImport record) {
    return VillageImportsCompanion(
      id: Value(record.id),
      villageId: Value(record.villageId),
      villageTag: Value(record.villageTag),
      snapshotTimestamp: Value(record.snapshotTimestamp),
      importedAtUtc: Value(record.importedAtUtc),
      importedRecordCount: Value(record.importedRecordCount),
      skippedRecordCount: Value(record.skippedRecordCount),
      activeUpgradesCount: Value(record.activeUpgradesCount),
      importMode: Value(record.importMode),
      result: Value(record.result),
      summaryJson: Value(record.summaryJson),
    );
  }
}
