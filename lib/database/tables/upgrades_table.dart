import 'package:drift/drift.dart';

import 'villages_table.dart';

/// Upgrades table — each row is one upgrade record.
@DataClassName('UpgradeRow')
class Upgrades extends Table {
  TextColumn get id => text()();
  TextColumn get villageId =>
      text().references(Villages, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// Stores the [UpgradeCategory] enum name as a string.
  TextColumn get category => text()();

  TextColumn get slotKey => text().nullable()();
  TextColumn get catalogItemId => text().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  DateTimeColumn get startedAtUtc => dateTime()();
  DateTimeColumn get expectedCompletionAtUtc => dateTime()();

  /// Stores the [UpgradeStatus] enum name as a string.
  TextColumn get status => text()();

  DateTimeColumn get completedAtUtc => dateTime().nullable()();
  IntColumn get notificationRevision =>
      integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  IntColumn get fromLevel => integer().nullable()();
  IntColumn get toLevel => integer().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
