import 'package:drift/drift.dart';

/// Stores user-created custom upgrade suggestions locally for future autocomplete.
@DataClassName('CustomUpgradeSuggestionRow')
class CustomUpgradeSuggestions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get category => text()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

