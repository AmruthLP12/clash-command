import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/services/notification_plan_service.dart';
import 'notification_service.dart';

/// Concrete implementation of [NotificationService] using
/// flutter_local_notifications.
///
/// Notification permission denial must not crash or block the app.
/// All failure paths are caught and logged.
class LocalNotificationService implements NotificationService {
  LocalNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
    _initialized = true;
    developer.log('NotificationService initialized', name: 'notifications');
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }
      return false;
    } catch (e) {
      developer.log(
        'requestPermission failed: $e',
        name: 'notifications',
      );
      return false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        // areNotificationsEnabled is available from FLN 9+
        return await android.areNotificationsEnabled() ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> schedulePlans(List<NotificationPlan> plans) async {
    for (final plan in plans) {
      try {
        final scheduledTz = tz.TZDateTime.from(
          plan.scheduledAtUtc.toUtc(),
          tz.UTC,
        );

        const notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'clash_command_upgrades',
            'Upgrade reminders',
            channelDescription:
                'Notifications for Clash Command upgrade completions.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        );

        try {
          // Attempt exact alarm scheduling while idle for exact-to-the-minute delivery
          await _plugin.zonedSchedule(
            plan.id,
            plan.title,
            plan.body,
            scheduledTz,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: null,
            payload: plan.upgradeId,
          );
          developer.log(
            'Scheduled exact notification id=${plan.id} at ${plan.scheduledAtUtc.toIso8601String()}',
            name: 'notifications',
          );
        } catch (exactErr) {
          developer.log(
            'Exact alarm scheduling failed, falling back to inexactAllowWhileIdle: $exactErr',
            name: 'notifications',
          );
          // Fallback to inexactAllowWhileIdle which does not require SCHEDULE_EXACT_ALARM permission
          await _plugin.zonedSchedule(
            plan.id,
            plan.title,
            plan.body,
            scheduledTz,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: null,
            payload: plan.upgradeId,
          );
        }
      } catch (e) {
        developer.log(
          'Failed to schedule notification id=${plan.id}: $e',
          name: 'notifications',
        );
      }
    }
  }

  @override
  Future<void> cancelForUpgrade(String upgradeId, {int maxPreAlerts = 10}) async {
    const planService = NotificationPlanService();
    final ids = planService.idsForUpgrade(
      upgradeId,
      maxPreAlerts: maxPreAlerts,
    );
    for (final id in ids) {
      try {
        await _plugin.cancel(id);
      } catch (e) {
        developer.log(
          'Failed to cancel notification id=$id: $e',
          name: 'notifications',
        );
      }
    }
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.canScheduleExactNotifications() ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestExactAlarmsPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final result = await android.requestExactAlarmsPermission();
        return result ?? false;
      }
      return false;
    } catch (e) {
      developer.log(
        'requestExactAlarmsPermission failed: $e',
        name: 'notifications',
      );
      return false;
    }
  }

  @override
  Future<int> getScheduledCount() async {
    try {
      final requests = await _plugin.pendingNotificationRequests();
      return requests.length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> showTestNotification() async {
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'clash_command_upgrades',
          'Upgrade reminders',
          channelDescription:
              'Notifications for Clash Command upgrade completions.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );
      await _plugin.show(
        999999,
        '🛡️ Clash Command Test Alert',
        'Notifications are working properly on your device!',
        details,
      );
    } catch (e) {
      developer.log(
        'Failed to show test notification: $e',
        name: 'notifications',
      );
    }
  }

  @override
  Future<void> reconcile(
    List<NotificationPlan> intendedPlans,
    List<int> activeNotificationIds,
  ) async {
    final intendedIds = intendedPlans.map((p) => p.id).toSet();

    // Query actual pending notifications held by Android AlarmManager/plugin cache
    try {
      final pendingNotifications = await _plugin.pendingNotificationRequests();
      for (final pending in pendingNotifications) {
        if (!intendedIds.contains(pending.id)) {
          try {
            await _plugin.cancel(pending.id);
            developer.log(
              'Canceled obsolete pending notification id=${pending.id}',
              name: 'notifications',
            );
          } catch (_) {}
        }
      }
    } catch (e) {
      developer.log(
        'Failed to query pending notifications in reconcile: $e',
        name: 'notifications',
      );
    }

    // Also cancel any ID from activeNotificationIds that is not intended
    for (final id in activeNotificationIds) {
      if (!intendedIds.contains(id)) {
        try {
          await _plugin.cancel(id);
        } catch (_) {}
      }
    }

    // Re-schedule all intended plans with their latest fire times
    await schedulePlans(intendedPlans);
  }
}
