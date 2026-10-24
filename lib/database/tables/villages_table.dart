import 'package:drift/drift.dart';

/// Villages table — each row is one tracked village.
@DataClassName('VillageRow')
class Villages extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get townHallLevel => integer().nullable()();
  IntColumn get builderHallLevel => integer().nullable()();
  IntColumn get builderCapacity => integer().withDefault(const Constant(1))();
  IntColumn get sortOrder => integer().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
