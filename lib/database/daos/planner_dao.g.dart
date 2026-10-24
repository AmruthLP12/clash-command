// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner_dao.dart';

// ignore_for_file: type=lint
mixin _$PlannerDaoMixin on DatabaseAccessor<AppDatabase> {
  $VillagesTable get villages => attachedDatabase.villages;
  $PlannerItemsTable get plannerItems => attachedDatabase.plannerItems;
  PlannerDaoManager get managers => PlannerDaoManager(this);
}

class PlannerDaoManager {
  final _$PlannerDaoMixin _db;
  PlannerDaoManager(this._db);
  $$VillagesTableTableManager get villages =>
      $$VillagesTableTableManager(_db.attachedDatabase, _db.villages);
  $$PlannerItemsTableTableManager get plannerItems =>
      $$PlannerItemsTableTableManager(_db.attachedDatabase, _db.plannerItems);
}
