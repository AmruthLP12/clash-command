// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'villages_dao.dart';

// ignore_for_file: type=lint
mixin _$VillagesDaoMixin on DatabaseAccessor<AppDatabase> {
  $VillagesTable get villages => attachedDatabase.villages;
  VillagesDaoManager get managers => VillagesDaoManager(this);
}

class VillagesDaoManager {
  final _$VillagesDaoMixin _db;
  VillagesDaoManager(this._db);
  $$VillagesTableTableManager get villages =>
      $$VillagesTableTableManager(_db.attachedDatabase, _db.villages);
}
