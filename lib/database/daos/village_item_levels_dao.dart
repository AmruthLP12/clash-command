import 'package:drift/drift.dart';

import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village_item_level.dart';

import '../app_database.dart';
import '../tables/village_item_levels_table.dart';

part 'village_item_levels_dao.g.dart';

@DriftAccessor(tables: [VillageItemLevels])
class VillageItemLevelsDao extends DatabaseAccessor<AppDatabase>
    with _$VillageItemLevelsDaoMixin {
  VillageItemLevelsDao(super.db);

  /// Watches all tracked item levels for a village, ordered by category, name, then level.
  Stream<List<VillageItemLevel>> watchForVillage(String villageId) {
    return (select(villageItemLevels)
          ..where((t) => t.villageId.equals(villageId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.category),
            (t) => OrderingTerm.asc(t.itemName),
            (t) => OrderingTerm.asc(t.currentLevel),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Watches all tracked item levels for a village and specific category.
  Stream<List<VillageItemLevel>> watchForVillageAndCategory(
    String villageId,
    UpgradeCategory category,
  ) {
    return (select(villageItemLevels)
          ..where(
            (t) =>
                t.villageId.equals(villageId) &
                t.category.equals(category.name),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.itemName),
            (t) => OrderingTerm.asc(t.currentLevel),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Gets all tracked item levels for a village snapshot.
  Future<List<VillageItemLevel>> getForVillage(String villageId) async {
    final rows =
        await (select(villageItemLevels)
              ..where((t) => t.villageId.equals(villageId))
              ..orderBy([
                (t) => OrderingTerm.asc(t.category),
                (t) => OrderingTerm.asc(t.itemName),
                (t) => OrderingTerm.asc(t.currentLevel),
              ]))
            .get();
    return rows.map(_toDomain).toList();
  }

  /// Finds a specific item level record for a village, category, and item name (first match).
  Future<VillageItemLevel?> findByItem(
    String villageId,
    UpgradeCategory category,
    String itemName,
  ) async {
    final cleanName = itemName.trim().toLowerCase();
    final rows =
        await (select(villageItemLevels)..where(
              (t) =>
                  t.villageId.equals(villageId) &
                  t.category.equals(category.name),
            ))
            .get();

    for (final row in rows) {
      if (row.itemName.trim().toLowerCase() == cleanName) {
        return _toDomain(row);
      }
    }
    return null;
  }

  /// Finds a specific item level record by village, category, item name, and level.
  Future<VillageItemLevel?> findByItemAndLevel(
    String villageId,
    UpgradeCategory category,
    String itemName,
    int level,
  ) async {
    final cleanName = itemName.trim().toLowerCase();
    final rows =
        await (select(villageItemLevels)..where(
              (t) =>
                  t.villageId.equals(villageId) &
                  t.category.equals(category.name) &
                  t.currentLevel.equals(level),
            ))
            .get();

    for (final row in rows) {
      if (row.itemName.trim().toLowerCase() == cleanName) {
        return _toDomain(row);
      }
    }
    return null;
  }

  /// Finds all level records for an item name in a village and category.
  Future<List<VillageItemLevel>> findAllByItem(
    String villageId,
    UpgradeCategory category,
    String itemName,
  ) async {
    final cleanName = itemName.trim().toLowerCase();
    final rows =
        await (select(villageItemLevels)..where(
              (t) =>
                  t.villageId.equals(villageId) &
                  t.category.equals(category.name),
            ))
            .get();

    return rows
        .where((r) => r.itemName.trim().toLowerCase() == cleanName)
        .map(_toDomain)
        .toList();
  }

  /// Inserts or updates an item level record.
  Future<void> upsert(VillageItemLevel item) async {
    await into(villageItemLevels).insertOnConflictUpdate(_toCompanion(item));
  }

  /// Batch upserts multiple item level records inside a single batch.
  Future<void> batchUpsert(List<VillageItemLevel> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        villageItemLevels,
        items.map(_toCompanion).toList(),
      );
    });
  }

  /// Deletes all level records for a village (used during replace import).
  Future<void> deleteForVillage(String villageId) async {
    await (delete(
      villageItemLevels,
    )..where((t) => t.villageId.equals(villageId))).go();
  }

  /// Deletes an item level record by ID.
  Future<void> deleteItem(String id) async {
    await (delete(villageItemLevels)..where((t) => t.id.equals(id))).go();
  }

  VillageItemLevel _toDomain(VillageItemLevelRow row) {
    return VillageItemLevel(
      id: row.id,
      villageId: row.villageId,
      category: UpgradeCategory.fromString(row.category),
      itemName: row.itemName,
      currentLevel: row.currentLevel,
      quantity: row.quantity,
      dataId: row.dataId,
      itemType: row.itemType,
      updatedAtUtc: row.updatedAtUtc,
    );
  }

  VillageItemLevelsCompanion _toCompanion(VillageItemLevel item) {
    return VillageItemLevelsCompanion(
      id: Value(item.id),
      villageId: Value(item.villageId),
      category: Value(item.category.name),
      itemType: Value(item.itemType),
      itemName: Value(item.itemName),
      currentLevel: Value(item.currentLevel),
      quantity: Value(item.quantity),
      dataId: Value(item.dataId),
      updatedAtUtc: Value(item.updatedAtUtc),
    );
  }
}
