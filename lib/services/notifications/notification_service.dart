import '../../domain/services/notification_plan_service.dart';

/// Interface for all notification operations in the app.
///
/// UI and domain code call this interface; only the concrete implementation
/// depends on flutter_local_notifications.
abstract class NotificationService {
  /// Initialize platform notification support. Call once at app startup.
  Future<void> initialize();

  /// Request notification permission contextually.
  Future<bool> requestPermission();

  /// Returns true if the app currently has notification permission.
  Future<bool> hasPermission();

  /// Schedules all notifications from [plans].
  Future<void> schedulePlans(List<NotificationPlan> plans);

  /// Cancels all notifications for a given upgrade ID.
  Future<void> cancelForUpgrade(String upgradeId, {int maxPreAlerts = 4});

  /// Reconcile the scheduled notifications against the [activeUpgradeIds] list.
  /// Cancels stale entries and schedules any missing ones.
  Future<void> reconcile(
    List<NotificationPlan> intendedPlans,
    List<int> activeNotificationIds,
  );
}
