import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/upgrades_dao.dart';
import '../database/daos/villages_dao.dart';
import '../domain/services/notification_plan_service.dart';
import '../domain/services/upgrade_lifecycle_service.dart';
import '../domain/services/upgrade_timer_service.dart';
import '../domain/services/village_service.dart';
import '../services/notifications/local_notification_service.dart';
import '../services/notifications/notification_service.dart';

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

// ---------- Domain services ----------

final upgradeTimerServiceProvider = Provider<UpgradeTimerService>((ref) {
  return const UpgradeTimerService();
});

final villageServiceProvider = Provider<VillageService>((ref) {
  return const VillageService();
});

final upgradeLifecycleServiceProvider =
    Provider<UpgradeLifecycleService>((ref) {
  return const UpgradeLifecycleService();
});

final notificationPlanServiceProvider =
    Provider<NotificationPlanService>((ref) {
  return const NotificationPlanService();
});

// ---------- Notification service ----------

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationService();
});
