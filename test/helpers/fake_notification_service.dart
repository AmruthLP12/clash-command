import 'package:clash_command/domain/services/notification_plan_service.dart';
import 'package:clash_command/services/notifications/notification_service.dart';

/// No-op notification service for tests.
class FakeNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<void> schedulePlans(List<NotificationPlan> plans) async {}

  @override
  Future<void> cancelForUpgrade(String upgradeId, {int maxPreAlerts = 4}) async {}

  @override
  Future<void> reconcile(
    List<NotificationPlan> intendedPlans,
    List<int> activeNotificationIds,
  ) async {}

  @override
  Future<void> showTestNotification() async {}
}
