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
          plan.scheduledAtUtc,
          tz.local,
        );
        await _plugin.zonedSchedule(
          plan.id,
          plan.title,
          plan.body,
          scheduledTz,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'clash_command_upgrades',
              'Upgrade reminders',
              channelDescription:
                  'Notifications for Clash Command upgrade completions.',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: null,
        );
      } catch (e) {
        developer.log(
          'Failed to schedule notification id=${plan.id}: $e',
          name: 'notifications',
        );
      }
    }
  }

  @override
  Future<void> cancelForUpgrade(String upgradeId, {int maxPreAlerts = 4}) async {
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
    // Cancel any IDs that are no longer intended
    final intendedIds = intendedPlans.map((p) => p.id).toSet();
    for (final id in activeNotificationIds) {
      if (!intendedIds.contains(id)) {
        try {
          await _plugin.cancel(id);
        } catch (_) {}
      }
    }

    // Schedule any that are missing
    final pendingNotifications = await _plugin.pendingNotificationRequests();
    final pendingIds = pendingNotifications.map((n) => n.id).toSet();
    final toSchedule =
        intendedPlans.where((p) => !pendingIds.contains(p.id)).toList();
    await schedulePlans(toSchedule);
  }
}
