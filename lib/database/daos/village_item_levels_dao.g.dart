// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'village_item_levels_dao.dart';

// ignore_for_file: type=lint
mixin _$VillageItemLevelsDaoMixin on DatabaseAccessor<AppDatabase> {
  $VillagesTable get villages => attachedDatabase.villages;
  $VillageItemLevelsTable get villageItemLevels =>
      attachedDatabase.villageItemLevels;
  VillageItemLevelsDaoManager get managers => VillageItemLevelsDaoManager(this);
}

class VillageItemLevelsDaoManager {
  final _$VillageItemLevelsDaoMixin _db;
  VillageItemLevelsDaoManager(this._db);
  $$VillagesTableTableManager get villages =>
      $$VillagesTableTableManager(_db.attachedDatabase, _db.villages);
  $$VillageItemLevelsTableTableManager get villageItemLevels =>
      $$VillageItemLevelsTableTableManager(
        _db.attachedDatabase,
        _db.villageItemLevels,
      );
}
