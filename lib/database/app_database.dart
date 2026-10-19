import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/models/upgrade.dart';
import '../domain/models/upgrade_category.dart';
import '../domain/models/upgrade_status.dart';
import '../domain/models/village.dart';
import 'tables/notification_preferences_table.dart';
import 'tables/upgrades_table.dart';
import 'tables/villages_table.dart';

part 'app_database.g.dart';

/// Opens the SQLite database file from the app's documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'clash_command.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [Villages, Upgrades, NotificationPreferences],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Accepts a custom [QueryExecutor] for use in tests (in-memory SQLite).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

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
