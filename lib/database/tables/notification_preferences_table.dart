import 'package:drift/drift.dart';

/// Notification preferences stored locally.
///
/// A single row with a fixed id = 1 acts as the settings record.
class NotificationPreferences extends Table {
  IntColumn get id => integer()();
  BoolColumn get completionEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get preAlertsEnabled =>
      boolean().withDefault(const Constant(true))();

  /// JSON-encoded list of integer minute offsets, e.g. "[30,5]".
  TextColumn get reminderOffsetMinutesJson =>
      text().withDefault(const Constant('[30,5]'))();

  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
