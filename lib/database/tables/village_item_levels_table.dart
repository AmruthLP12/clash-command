import 'package:drift/drift.dart';

import 'villages_table.dart';

/// Stores the current levels of tracked items for a specific village.
@DataClassName('VillageItemLevelRow')
class VillageItemLevels extends Table {
  TextColumn get id => text()();
  TextColumn get villageId => text().references(Villages, #id, onDelete: KeyAction.cascade)();
  TextColumn get category => text()();
  TextColumn get itemName => text().withLength(min: 1, max: 200)();
  IntColumn get currentLevel => integer()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {villageId, category, itemName},
  ];
}

