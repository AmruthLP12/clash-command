import 'dart:developer' as developer;

import '../../database/daos/upgrades_dao.dart';
import '../../domain/services/notification_plan_service.dart';
import 'notification_service.dart';

/// Reconciles the notification schedule at app launch and after reboot.
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
  });

  final UpgradesDao upgradesDao;
  final NotificationService notificationService;
  final NotificationPlanService planService;

  Future<void> reconcile() async {
    try {
      final now = DateTime.now().toUtc();
      final active = await upgradesDao.getAllActive();
      developer.log(
        'Reconciling notifications for ${active.length} active upgrades',
        name: 'notifications',
      );

      final allPlans = <NotificationPlan>[];
      final allIds = <int>[];

      for (final upgrade in active) {
        final plans = planService.buildPlan(upgrade, now);
        allPlans.addAll(plans);
        allIds.addAll(planService.idsForUpgrade(upgrade.id));
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
