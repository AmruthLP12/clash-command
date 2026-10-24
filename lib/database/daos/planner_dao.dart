import 'package:drift/drift.dart';

import 'package:clash_command/domain/models/planner_item.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import '../app_database.dart';
import '../tables/planner_items_table.dart';

part 'planner_dao.g.dart';

@DriftAccessor(tables: [PlannerItems])
class PlannerDao extends DatabaseAccessor<AppDatabase> with _$PlannerDaoMixin {
  PlannerDao(super.db);

  /// Watches all planned items for a specific village, ordered by sortOrder then createdAt.
  Stream<List<PlannerItem>> watchForVillage(String villageId) {
    return (select(plannerItems)
          ..where((t) => t.villageId.equals(villageId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAtUtc),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Watches all planned items across all villages.
  Stream<List<PlannerItem>> watchAll() {
    return (select(plannerItems)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAtUtc),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Fetches a single planner item by ID.
  Future<PlannerItem?> findById(String id) async {
    final row = await (select(plannerItems)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  /// Inserts or replaces a planned item.
  Future<void> upsert(PlannerItem item) async {
    await into(plannerItems).insertOnConflictUpdate(_toCompanion(item));
  }

  /// Deletes a planned item by ID.
  Future<void> deleteItem(String id) async {
    await (delete(plannerItems)..where((t) => t.id.equals(id))).go();
  }

  /// Updates status of a planned item (e.g. 'started', 'completed', 'cancelled').
  Future<void> updateStatus(String id, String status) async {
    await (update(plannerItems)..where((t) => t.id.equals(id))).write(
      PlannerItemsCompanion(
        status: Value(status),
        updatedAtUtc: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Marks a specific item as 'next' in a village and category, clearing 'next' on others in that group.
  Future<void> markAsNext(String villageId, String itemId) async {
    final target = await findById(itemId);
    if (target == null) return;

    await transaction(() async {
      // Clear isNext for all items in this village with the same category
      await (update(plannerItems)
            ..where((t) =>
                t.villageId.equals(villageId) &
                t.category.equals(target.category.name)))
          .write(
        const PlannerItemsCompanion(isNext: Value(false)),
      );

      // Set target isNext
      await (update(plannerItems)..where((t) => t.id.equals(itemId))).write(
        PlannerItemsCompanion(
          isNext: const Value(true),
          updatedAtUtc: Value(DateTime.now().toUtc()),
        ),
      );
    });
  }

  /// Reorders items for a village by updating their sortOrder values in order.
  Future<void> reorder(String villageId, List<String> orderedIds) async {
    await transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(plannerItems)..where((t) => t.id.equals(orderedIds[i]))).write(
          PlannerItemsCompanion(
            sortOrder: Value(i),
            updatedAtUtc: Value(DateTime.now().toUtc()),
          ),
        );
      }
    });
  }

  PlannerItem _toDomain(PlannerItemRow row) {
    return PlannerItem(
      id: row.id,
      villageId: row.villageId,
      category: UpgradeCategory.fromString(row.category),
      name: row.name,
      targetLevel: row.targetLevel,
      priority: row.priority,
      notes: row.notes,
      sortOrder: row.sortOrder,
      status: row.status,
      isNext: row.isNext,
      createdAtUtc: row.createdAtUtc,
      updatedAtUtc: row.updatedAtUtc,
    );
  }

  PlannerItemsCompanion _toCompanion(PlannerItem item) {
    return PlannerItemsCompanion(
      id: Value(item.id),
      villageId: Value(item.villageId),
      category: Value(item.category.name),
      name: Value(item.name),
      targetLevel: Value(item.targetLevel),
      priority: Value(item.priority),
      notes: Value(item.notes),
      sortOrder: Value(item.sortOrder),
      status: Value(item.status),
      isNext: Value(item.isNext),
      createdAtUtc: Value(item.createdAtUtc),
      updatedAtUtc: Value(item.updatedAtUtc),
    );
  }
}

