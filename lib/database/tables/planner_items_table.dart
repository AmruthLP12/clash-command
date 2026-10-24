import 'package:drift/drift.dart';

import 'villages_table.dart';

/// Stores planned future upgrades.
@DataClassName('PlannerItemRow')
class PlannerItems extends Table {
  TextColumn get id => text()();
  TextColumn get villageId => text().references(Villages, #id, onDelete: KeyAction.cascade)();
  TextColumn get category => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get targetLevel => integer().nullable()();
  TextColumn get priority => text().withDefault(const Constant('Medium'))();
  TextColumn get notes => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('planned'))();
  BoolColumn get isNext => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

