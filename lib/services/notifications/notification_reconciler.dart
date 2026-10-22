import 'dart:convert';
import 'dart:developer' as developer;

import '../../database/daos/notification_preferences_dao.dart';
import '../../database/daos/upgrades_dao.dart';
import '../../database/daos/villages_dao.dart';
import '../../domain/services/notification_plan_service.dart';
import 'notification_service.dart';

/// Reconciles the notification schedule at app launch, after reboot, and on settings changes.
///
/// Steps:
/// 1. Fetch all active upgrades from the database.
/// 2. Build the intended notification plans from current preferences.
/// 3. Derive all IDs that should be active.
/// 4. Ask [NotificationService] to reconcile (cancel stale, schedule missing).
class NotificationReconciler {
  const NotificationReconciler({
    required this.upgradesDao,
    required this.notificationService,
    required this.planService,
    this.preferencesDao,
    this.villagesDao,
  });

  final UpgradesDao upgradesDao;
  final NotificationService notificationService;
  final NotificationPlanService planService;
  final NotificationPreferencesDao? preferencesDao;
  final VillagesDao? villagesDao;

  Future<void> reconcile() async {
    try {
      final now = DateTime.now().toUtc();
      final active = await upgradesDao.getAllActive();
      developer.log(
        'Reconciling notifications for ${active.length} active upgrades',
        name: 'notifications',
      );

      // Load preferences if available
      bool completionEnabled = true;
      bool preAlertsEnabled = true;
      List<int> reminderOffsets = NotificationPlanService.defaultReminderOffsets;

      if (preferencesDao != null) {
        try {
          final prefs = await preferencesDao!.getPreferences();
          completionEnabled = prefs.completionEnabled;
          preAlertsEnabled = prefs.preAlertsEnabled;
          try {
            final decoded = jsonDecode(prefs.reminderOffsetMinutesJson) as List<dynamic>;
            reminderOffsets = decoded.map((e) => e as int).toList();
          } catch (_) {}
        } catch (_) {}
      }

      // Load village names if available
      final villageNameMap = <String, String>{};
      if (villagesDao != null) {
        try {
          final villages = await villagesDao!.getAll();
          for (final v in villages) {
            villageNameMap[v.id] = v.name;
          }
        } catch (_) {}
      }

      final allPlans = <NotificationPlan>[];
      final allIds = <int>[];

      for (final upgrade in active) {
        allIds.addAll(planService.idsForUpgrade(upgrade.id));

        final plans = planService.buildPlan(
          upgrade,
          now,
          completionEnabled: completionEnabled,
          reminderOffsetMinutes: preAlertsEnabled ? reminderOffsets : const [],
          villageName: villageNameMap[upgrade.villageId],
        );
        allPlans.addAll(plans);
      }

      await notificationService.reconcile(allPlans, allIds);
      developer.log('Notification reconciliation complete', name: 'notifications');
    } catch (e) {
      // Reconciliation failures must not crash the app or block timers
      developer.log(
        'Notification reconciliation error: $e',
        name: 'notifications',
      );
    }
  }
}
