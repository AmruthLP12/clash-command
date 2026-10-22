import 'package:drift/drift.dart';

import '../domain/models/upgrade.dart';
import '../domain/models/upgrade_category.dart';
import '../domain/models/upgrade_status.dart';
import '../domain/models/village.dart';
import 'openers.dart';
import 'tables/history_events_table.dart';
import 'tables/notification_preferences_table.dart';
import 'tables/upgrades_table.dart';
import 'tables/villages_table.dart';

part 'app_database.g.dart';

/// Opens the SQLite database used by the app.
///
/// On native platforms this runs SQLite through the native `sqlite3` library;
/// on the web it uses the WebAssembly build of SQLite via drift's `WasmDatabase`.
@DriftDatabase(
  tables: [Villages, Upgrades, NotificationPreferences, HistoryEvents],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabase());

  /// Accepts a custom [QueryExecutor] for use in tests (in-memory SQLite).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        // Seed default notification preferences row
        await into(notificationPreferences).insertOnConflictUpdate(
          NotificationPreferencesCompanion.insert(
            id: const Value(1),
            updatedAtUtc: DateTime.now().toUtc(),
          ),
        );
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(historyEvents);
        }
      },
    );
  }
}

// ---------- Mapper helpers ----------

extension VillageRowMapper on VillageRow {
  Village toDomain() {
    return Village(
      id: id,
      name: name,
      townHallLevel: townHallLevel,
      builderCapacity: builderCapacity,
      sortOrder: sortOrder,
      isArchived: isArchived,
      notes: notes,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }
}

extension VillageDomainMapper on Village {
  VillagesCompanion toCompanion() {
    return VillagesCompanion(
      id: Value(id),
      name: Value(name),
      townHallLevel: Value(townHallLevel),
      builderCapacity: Value(builderCapacity),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      notes: Value(notes),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }
}

extension UpgradeRowMapper on UpgradeRow {
  Upgrade toDomain() {
    return Upgrade(
      id: id,
      villageId: villageId,
      name: name,
      category: UpgradeCategory.fromString(category),
      slotKey: slotKey,
      catalogItemId: catalogItemId,
      durationSeconds: durationSeconds,
      startedAtUtc: startedAtUtc,
      expectedCompletionAtUtc: expectedCompletionAtUtc,
      status: UpgradeStatus.fromString(status),
      completedAtUtc: completedAtUtc,
      notificationRevision: notificationRevision,
      notes: notes,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }
}

extension UpgradeDomainMapper on Upgrade {
  UpgradesCompanion toCompanion() {
    return UpgradesCompanion(
      id: Value(id),
      villageId: Value(villageId),
      name: Value(name),
      category: Value(category.name),
      slotKey: Value(slotKey),
      catalogItemId: Value(catalogItemId),
      durationSeconds: Value(durationSeconds),
      startedAtUtc: Value(startedAtUtc),
      expectedCompletionAtUtc: Value(expectedCompletionAtUtc),
      status: Value(status.name),
      completedAtUtc: Value(completedAtUtc),
      notificationRevision: Value(notificationRevision),
      notes: Value(notes),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }
}
