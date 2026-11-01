import 'dart:convert';

import 'package:clash_command/core/ids/id_generator.dart';
import 'package:clash_command/database/app_database.dart';
import 'package:clash_command/database/daos/history_events_dao.dart';
import 'package:clash_command/database/daos/upgrades_dao.dart';
import 'package:clash_command/database/daos/village_imports_dao.dart';
import 'package:clash_command/database/daos/village_item_levels_dao.dart';
import 'package:clash_command/database/daos/villages_dao.dart';
import 'package:clash_command/domain/models/history_event.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/models/village_import.dart';
import 'package:clash_command/domain/models/village_item_level.dart';
import 'package:clash_command/services/notifications/notification_reconciler.dart';
import 'package:clash_command/services/widgets/home_widget_sync_service.dart';

import '../domain/coc_import_preview_model.dart';

/// Result of an executed Clash of Clans village import operation.
class CocImportResult {
  const CocImportResult({
    required this.success,
    required this.villageId,
    required this.villageTag,
    required this.importedLevelsCount,
    required this.importedUpgradesCount,
    required this.skippedUpgradesCount,
    required this.expiredTimersCount,
    required this.unmappedItemsCount,
    this.errorMessage,
  });

  final bool success;
  final String villageId;
  final String villageTag;
  final int importedLevelsCount;
  final int importedUpgradesCount;
  final int skippedUpgradesCount;
  final int expiredTimersCount;
  final int unmappedItemsCount;
  final String? errorMessage;
}

/// Service that performs transactional imports of parsed Clash of Clans village data.
class CocVillageImportService {
  const CocVillageImportService({
    required this.db,
    required this.villagesDao,
    required this.levelsDao,
    required this.upgradesDao,
    required this.importsDao,
    required this.historyEventsDao,
    this.notificationReconciler,
    this.homeWidgetSyncService,
  });

  final AppDatabase db;
  final VillagesDao villagesDao;
  final VillageItemLevelsDao levelsDao;
  final UpgradesDao upgradesDao;
  final VillageImportsDao importsDao;
  final HistoryEventsDao historyEventsDao;
  final NotificationReconciler? notificationReconciler;
  final HomeWidgetSyncService? homeWidgetSyncService;

  /// Checks if a snapshot with the given timestamp has already been imported for the village.
  Future<bool> hasExistingSnapshot({
    required String villageId,
    required int snapshotTimestamp,
  }) async {
    final existing = await importsDao.findBySnapshot(
      villageId,
      snapshotTimestamp,
    );
    return existing != null;
  }

  /// Executes the import transactionally.
  ///
  /// [mode] must be either `'merge'` or `'replace'`.
  Future<CocImportResult> executeImport({
    required Village village,
    required CocImportPreview preview,
    required String mode,
    bool updateHallLevels = true,
  }) async {
    final now = DateTime.now().toUtc();
    int importedUpgrades = 0;
    int skippedUpgrades = 0;

    try {
      await db.transaction(() async {
        // 1. Update village Town Hall / Builder Hall levels if detected & requested
        if (updateHallLevels) {
          final updatedVillage = village.copyWith(
            townHallLevel:
                preview.detectedTownHallLevel ?? village.townHallLevel,
            builderHallLevel:
                preview.detectedBuilderHallLevel ?? village.builderHallLevel,
            updatedAtUtc: now,
          );
          await villagesDao.upsert(updatedVillage);
        }

        // 2. Handle Levels table
        if (mode == 'replace') {
          // In replace mode, delete previously tracked levels for this village
          await levelsDao.deleteForVillage(village.id);
        }

        final allParsedLevels = [
          ...preview.homeLevels,
          ...preview.builderLevels,
        ];

        for (final item in allParsedLevels) {
          final record = VillageItemLevel(
            id: const IdGenerator().newId(),
            villageId: village.id,
            category: item.category,
            itemName: item.name,
            currentLevel: item.level,
            quantity: item.quantity,
            dataId: item.dataId,
            itemType: item.itemType,
            updatedAtUtc: now,
          );
          await levelsDao.upsert(record);
        }

        // 3. Handle Active Upgrades
        if (mode == 'replace') {
          await upgradesDao.deleteActiveForVillage(village.id);
        }

        final existingActives = await upgradesDao.getActiveForVillage(
          village.id,
        );

        for (final up in preview.activeUpgrades) {
          // Prevent duplicate active upgrades for the same category and item
          final isDuplicate = existingActives.any(
            (e) =>
                e.category == up.category &&
                e.name.toLowerCase() == up.name.toLowerCase(),
          );

          if (isDuplicate) {
            skippedUpgrades++;
            continue;
          }

          final upgradeRecord = Upgrade(
            id: const IdGenerator().newId(),
            villageId: village.id,
            name: up.name,
            category: up.category,
            durationSeconds: up.remainingDurationSeconds,
            startedAtUtc: up.startedAtUtc,
            expectedCompletionAtUtc: up.expectedCompletionAtUtc,
            status: UpgradeStatus.active,
            fromLevel: up.fromLevel,
            toLevel: up.toLevel ?? (up.fromLevel + 1),
            notes: 'Imported from snapshot (${preview.tag})',
            createdAtUtc: now,
            updatedAtUtc: now,
          );

          await upgradesDao.upsert(upgradeRecord);
          importedUpgrades++;
        }

        // 4. Record audit in VillageImports
        final summaryMap = {
          'tag': preview.tag,
          'snapshotTimestamp': preview.snapshotTimestamp,
          'detectedTH': preview.detectedTownHallLevel,
          'detectedBH': preview.detectedBuilderHallLevel,
          'homeLevelsCount': preview.homeLevels.length,
          'builderLevelsCount': preview.builderLevels.length,
          'activeUpgradesCount': importedUpgrades,
          'expiredTimersCount': preview.expiredTimers.length,
          'unmappedItemsCount': preview.unmappedItems.length,
        };

        final importRecord = VillageImport(
          id: const IdGenerator().newId(),
          villageId: village.id,
          villageTag: preview.tag,
          snapshotTimestamp: preview.snapshotTimestamp,
          importedAtUtc: now,
          importedRecordCount: allParsedLevels.length,
          skippedRecordCount: preview.unmappedItems.length,
          activeUpgradesCount: importedUpgrades,
          importMode: mode,
          result: 'success',
          summaryJson: jsonEncode(summaryMap),
        );

        await importsDao.insertImport(importRecord);

        // 5. Record activity history event
        final history = HistoryEvent(
          id: const IdGenerator().newId(),
          villageId: village.id,
          villageName: village.name,
          eventType: HistoryEventType.villageImported,
          description:
              'Imported ${preview.tag} ($mode): ${allParsedLevels.length} levels, $importedUpgrades active timers.',
          createdAtUtc: now,
        );
        await historyEventsDao.insertEvent(history);
      });

      // 6. Post-transaction notification reconciliation & widget sync
      if (notificationReconciler != null) {
        await notificationReconciler!.reconcile();
      }
      if (homeWidgetSyncService != null) {
        await homeWidgetSyncService!.syncWidgets(specificVillageId: village.id);
      }

      return CocImportResult(
        success: true,
        villageId: village.id,
        villageTag: preview.tag,
        importedLevelsCount: preview.totalLevelsCount,
        importedUpgradesCount: importedUpgrades,
        skippedUpgradesCount: skippedUpgrades,
        expiredTimersCount: preview.expiredTimers.length,
        unmappedItemsCount: preview.unmappedItems.length,
      );
    } catch (e) {
      return CocImportResult(
        success: false,
        villageId: village.id,
        villageTag: preview.tag,
        importedLevelsCount: 0,
        importedUpgradesCount: 0,
        skippedUpgradesCount: 0,
        expiredTimersCount: 0,
        unmappedItemsCount: 0,
        errorMessage: e.toString(),
      );
    }
  }
}
