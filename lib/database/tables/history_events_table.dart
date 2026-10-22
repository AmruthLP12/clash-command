import 'package:drift/drift.dart';

/// History events log table — records all significant state transitions.
@DataClassName('HistoryEventRow')
class HistoryEvents extends Table {
  TextColumn get id => text()();
  TextColumn get upgradeId => text().nullable()();
  TextColumn get villageId => text().nullable()();
  TextColumn get eventType => text()();
  TextColumn get description => text()();
  TextColumn get upgradeName => text().nullable()();
  TextColumn get villageName => text().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

