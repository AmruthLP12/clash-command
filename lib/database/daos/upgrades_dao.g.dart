// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upgrades_dao.dart';

// ignore_for_file: type=lint
mixin _$UpgradesDaoMixin on DatabaseAccessor<AppDatabase> {
  $VillagesTable get villages => attachedDatabase.villages;
  $UpgradesTable get upgrades => attachedDatabase.upgrades;
  UpgradesDaoManager get managers => UpgradesDaoManager(this);
}

class UpgradesDaoManager {
  final _$UpgradesDaoMixin _db;
  UpgradesDaoManager(this._db);
  $$VillagesTableTableManager get villages =>
      $$VillagesTableTableManager(_db.attachedDatabase, _db.villages);
  $$UpgradesTableTableManager get upgrades =>
      $$UpgradesTableTableManager(_db.attachedDatabase, _db.upgrades);
}
