import 'package:drift/drift.dart';

import 'package:clash_command/domain/models/village.dart';
import '../app_database.dart';
import '../tables/villages_table.dart';

part 'villages_dao.g.dart';

@DriftAccessor(tables: [Villages])
class VillagesDao extends DatabaseAccessor<AppDatabase>
    with _$VillagesDaoMixin {
  VillagesDao(super.db);

  /// Watches all non-archived villages ordered by sortOrder then name.
  Stream<List<Village>> watchAll() {
    return (select(villages)
          ..where((v) => v.isArchived.equals(false))
          ..orderBy([
            (v) => OrderingTerm.asc(v.sortOrder),
            (v) => OrderingTerm.asc(v.name),
          ]))
        .watch()
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  /// Fetches a single village by ID, or null if not found.
  Future<Village?> findById(String id) async {
    final row = await (select(villages)..where((v) => v.id.equals(id)))
        .getSingleOrNull();
    return row?.toDomain();
  }

  /// Inserts or replaces a village.
  Future<void> upsert(Village village) async {
    await into(villages).insertOnConflictUpdate(village.toCompanion());
  }

  /// Soft-archives a village (does not delete its upgrades).
  Future<void> archive(String id) async {
    await (update(villages)..where((v) => v.id.equals(id))).write(
      VillagesCompanion(
        isArchived: const Value(true),
        updatedAtUtc: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Hard-deletes a village. Cascades to upgrades via the foreign key.
  Future<void> deleteVillage(String id) async {
    await (delete(villages)..where((v) => v.id.equals(id))).go();
  }

  /// Returns all villages (including archived) once — used for export.
  Future<List<Village>> getAll() async {
    final rows = await select(villages).get();
    return rows.map((r) => r.toDomain()).toList();
  }
}
