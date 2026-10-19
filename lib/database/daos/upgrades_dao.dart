import 'package:drift/drift.dart';

import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import '../app_database.dart';
import '../tables/upgrades_table.dart';

part 'upgrades_dao.g.dart';

@DriftAccessor(tables: [Upgrades])
class UpgradesDao extends DatabaseAccessor<AppDatabase>
    with _$UpgradesDaoMixin {
  UpgradesDao(super.db);

  /// Watches active upgrades for a given village, ordered by soonest first.
  Stream<List<Upgrade>> watchActiveForVillage(String villageId) {
    return (select(upgrades)
          ..where(
            (u) =>
                u.villageId.equals(villageId) &
                u.status.equals(UpgradeStatus.active.name),
          )
          ..orderBy([
            (u) => OrderingTerm.asc(u.expectedCompletionAtUtc),
          ]))
        .watch()
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  /// Watches all active upgrades across all villages.
  Stream<List<Upgrade>> watchAllActive() {
    return (select(upgrades)
          ..where((u) => u.status.equals(UpgradeStatus.active.name))
          ..orderBy([
            (u) => OrderingTerm.asc(u.expectedCompletionAtUtc),
          ]))
        .watch()
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  /// Watches all upgrades for a village (for history view).
  Stream<List<Upgrade>> watchAllForVillage(String villageId) {
    return (select(upgrades)
          ..where((u) => u.villageId.equals(villageId))
          ..orderBy([
            (u) => OrderingTerm.desc(u.expectedCompletionAtUtc),
          ]))
        .watch()
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  /// Fetches a single upgrade by ID.
  Future<Upgrade?> findById(String id) async {
    final row = await (select(upgrades)..where((u) => u.id.equals(id)))
        .getSingleOrNull();
    return row?.toDomain();
  }

  /// Inserts or replaces an upgrade.
  Future<void> upsert(Upgrade upgrade) async {
    await into(upgrades).insertOnConflictUpdate(upgrade.toCompanion());
  }

  /// Deletes an upgrade by ID.
  Future<void> deleteUpgrade(String id) async {
    await (delete(upgrades)..where((u) => u.id.equals(id))).go();
  }

  /// Returns all active upgrades — used for notification reconciliation.
  Future<List<Upgrade>> getAllActive() async {
    final rows = await (select(upgrades)
          ..where((u) => u.status.equals(UpgradeStatus.active.name)))
        .get();
    return rows.map((r) => r.toDomain()).toList();
  }
}
