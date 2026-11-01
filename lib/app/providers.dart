import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/custom_upgrade_suggestions_dao.dart';
import '../database/daos/history_events_dao.dart';
import '../database/daos/notification_preferences_dao.dart';
import '../database/daos/planner_dao.dart';
import '../database/daos/upgrades_dao.dart';
import '../database/daos/village_imports_dao.dart';
import '../database/daos/village_item_levels_dao.dart';
import '../database/daos/villages_dao.dart';
import '../domain/models/planner_item.dart';
import '../domain/models/upgrade_category.dart';
import '../domain/models/village_import.dart';
import '../domain/models/village_item_level.dart';
import '../domain/services/notification_plan_service.dart';
import '../domain/services/upgrade_lifecycle_service.dart';
import '../domain/services/upgrade_timer_service.dart';
import '../domain/services/village_service.dart';
import '../features/backup/application/backup_service.dart';
import '../features/import/application/coc_village_import_service.dart';
import '../services/audio/audio_service.dart';
import '../services/notifications/local_notification_service.dart';
import '../services/notifications/notification_reconciler.dart';
import '../services/notifications/notification_service.dart';
import '../services/widgets/home_widget_sync_service.dart';

export '../core/formatting/display_preferences.dart';

// ---------- Database ----------

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ---------- DAOs ----------

final villagesDaoProvider = Provider<VillagesDao>((ref) {
  return VillagesDao(ref.watch(appDatabaseProvider));
});

final upgradesDaoProvider = Provider<UpgradesDao>((ref) {
  return UpgradesDao(ref.watch(appDatabaseProvider));
});

final historyEventsDaoProvider = Provider<HistoryEventsDao>((ref) {
  return HistoryEventsDao(ref.watch(appDatabaseProvider));
});

final notificationPreferencesDaoProvider = Provider<NotificationPreferencesDao>(
  (ref) {
    return NotificationPreferencesDao(ref.watch(appDatabaseProvider));
  },
);

final customUpgradeSuggestionsDaoProvider =
    Provider<CustomUpgradeSuggestionsDao>((ref) {
      return CustomUpgradeSuggestionsDao(ref.watch(appDatabaseProvider));
    });

final plannerDaoProvider = Provider<PlannerDao>((ref) {
  return PlannerDao(ref.watch(appDatabaseProvider));
});

final villageItemLevelsDaoProvider = Provider<VillageItemLevelsDao>((ref) {
  return VillageItemLevelsDao(ref.watch(appDatabaseProvider));
});

final villageImportsDaoProvider = Provider<VillageImportsDao>((ref) {
  return VillageImportsDao(ref.watch(appDatabaseProvider));
});

final plannerItemsForVillageProvider =
    StreamProvider.family<List<PlannerItem>, String>((ref, villageId) {
      return ref.watch(plannerDaoProvider).watchForVillage(villageId);
    });

final allPlannerItemsProvider = StreamProvider<List<PlannerItem>>((ref) {
  return ref.watch(plannerDaoProvider).watchAll();
});

final villageItemLevelsStreamProvider =
    StreamProvider.family<List<VillageItemLevel>, String>((ref, villageId) {
      return ref.watch(villageItemLevelsDaoProvider).watchForVillage(villageId);
    });

final villageImportsStreamProvider =
    StreamProvider.family<List<VillageImport>, String>((ref, villageId) {
      return ref.watch(villageImportsDaoProvider).watchForVillage(villageId);
    });

final allVillageImportsStreamProvider = StreamProvider<List<VillageImport>>((
  ref,
) {
  return ref.watch(villageImportsDaoProvider).watchAll();
});

final customUpgradeSuggestionsStreamProvider =
    StreamProvider.family<List<CustomUpgradeSuggestionRow>, UpgradeCategory>((
      ref,
      category,
    ) {
      return ref
          .watch(customUpgradeSuggestionsDaoProvider)
          .watchForCategory(category);
    });

final notificationPreferencesStreamProvider =
    StreamProvider<NotificationPreference>((ref) {
      return ref.watch(notificationPreferencesDaoProvider).watchPreferences();
    });

// ---------- Domain services ----------

final upgradeTimerServiceProvider = Provider<UpgradeTimerService>((ref) {
  return const UpgradeTimerService();
});

final villageServiceProvider = Provider<VillageService>((ref) {
  return const VillageService();
});

final upgradeLifecycleServiceProvider = Provider<UpgradeLifecycleService>((
  ref,
) {
  return const UpgradeLifecycleService();
});

final notificationPlanServiceProvider = Provider<NotificationPlanService>((
  ref,
) {
  return const NotificationPlanService();
});

// ---------- Notification service ----------

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationService();
});

final notificationReconcilerProvider = Provider<NotificationReconciler>((ref) {
  return NotificationReconciler(
    upgradesDao: ref.watch(upgradesDaoProvider),
    notificationService: ref.watch(notificationServiceProvider),
    planService: ref.watch(notificationPlanServiceProvider),
    preferencesDao: ref.watch(notificationPreferencesDaoProvider),
    villagesDao: ref.watch(villagesDaoProvider),
  );
});

// ---------- Home Screen Widgets ----------

final homeWidgetSyncServiceProvider = Provider<HomeWidgetSyncService>((ref) {
  return HomeWidgetSyncService(
    villagesDao: ref.watch(villagesDaoProvider),
    upgradesDao: ref.watch(upgradesDaoProvider),
  );
});

// ---------- Audio Service ----------

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

// ---------- Data Management & Import Services ----------

final cocVillageImportServiceProvider = Provider<CocVillageImportService>((
  ref,
) {
  return CocVillageImportService(
    db: ref.watch(appDatabaseProvider),
    villagesDao: ref.watch(villagesDaoProvider),
    levelsDao: ref.watch(villageItemLevelsDaoProvider),
    upgradesDao: ref.watch(upgradesDaoProvider),
    importsDao: ref.watch(villageImportsDaoProvider),
    historyEventsDao: ref.watch(historyEventsDaoProvider),
    notificationReconciler: ref.watch(notificationReconcilerProvider),
    homeWidgetSyncService: ref.watch(homeWidgetSyncServiceProvider),
  );
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    db: ref.watch(appDatabaseProvider),
    notificationReconciler: ref.watch(notificationReconcilerProvider),
    homeWidgetSyncService: ref.watch(homeWidgetSyncServiceProvider),
  );
});
