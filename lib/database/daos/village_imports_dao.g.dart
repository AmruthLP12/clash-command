// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'village_imports_dao.dart';

// ignore_for_file: type=lint
mixin _$VillageImportsDaoMixin on DatabaseAccessor<AppDatabase> {
  $VillagesTable get villages => attachedDatabase.villages;
  $VillageImportsTable get villageImports => attachedDatabase.villageImports;
  VillageImportsDaoManager get managers => VillageImportsDaoManager(this);
}

class VillageImportsDaoManager {
  final _$VillageImportsDaoMixin _db;
  VillageImportsDaoManager(this._db);
  $$VillagesTableTableManager get villages =>
      $$VillagesTableTableManager(_db.attachedDatabase, _db.villages);
  $$VillageImportsTableTableManager get villageImports =>
      $$VillageImportsTableTableManager(
        _db.attachedDatabase,
        _db.villageImports,
      );
}
