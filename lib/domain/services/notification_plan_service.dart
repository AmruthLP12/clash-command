import '../models/upgrade.dart';
import '../models/upgrade_status.dart';

/// Generates deterministic notification IDs for upgrades.
///
/// Uses a stable mapping from upgrade ID + offset type to an integer,
/// since flutter_local_notifications requires integer IDs and they must
/// be stable across app restarts for cancellation to work.
///
/// Notification ID space:
///   completion:  base * 3
///   pre-alert 1: base * 3 + 1
///   pre-alert 2: base * 3 + 2
class NotificationPlanService {
  const NotificationPlanService();

  static const int _maxNotificationId = 2147483647; // int32 max

  /// Default reminder offsets (in minutes before completion).
  static const List<int> defaultReminderOffsets = [30, 5];

  /// Derives the integer base ID for an upgrade from its UUID.
  /// Uses a stable hash to keep IDs consistent across launches.
  int _baseId(String upgradeId) {
    return upgradeId.hashCode.abs() % (_maxNotificationId ~/ 3);
  }

  /// Returns the notification ID for the completion notification.
  int completionId(String upgradeId) => _baseId(upgradeId) * 3;

  /// Returns the notification ID for a pre-alert at [offsetIndex].
  int preAlertId(String upgradeId, int offsetIndex) =>
      _baseId(upgradeId) * 3 + 1 + offsetIndex;

  /// Builds the list of [NotificationPlan] entries for an upgrade given
  /// the current time and reminder offsets (in minutes).
  ///
  /// Plans whose scheduled time is in the past are omitted — we do not
  /// schedule notifications in the past.
  List<NotificationPlan> buildPlan(
    Upgrade upgrade,
    DateTime now, {
    List<int> reminderOffsetMinutes = defaultReminderOffsets,
    bool completionEnabled = true,
    String? villageName,
  }) {
    if (upgrade.status != UpgradeStatus.active) return [];

    final plans = <NotificationPlan>[];

    // Completion notification
    if (completionEnabled) {
      final scheduledAt = upgrade.expectedCompletionAtUtc;
      if (scheduledAt.isAfter(now)) {
        final vName = villageName ?? upgrade.villageId;
        plans.add(
          NotificationPlan(
            id: completionId(upgrade.id),
            upgradeId: upgrade.id,
            scheduledAtUtc: scheduledAt,
            type: NotificationPlanType.completion,
            title: '✅ ${upgrade.name} is done!',
            body:
                'Your ${upgrade.name} upgrade has completed in $vName.',
          ),
        );
      }
    }

    // Pre-alert notifications
    for (var i = 0; i < reminderOffsetMinutes.length; i++) {
      final offset = reminderOffsetMinutes[i];
      final scheduledAt = upgrade.expectedCompletionAtUtc
          .subtract(Duration(minutes: offset));
      if (scheduledAt.isAfter(now)) {
        final offsetText = offset >= 60
            ? '${offset ~/ 60} hour${offset >= 120 ? 's' : ''}'
            : '$offset minute${offset == 1 ? '' : 's'}';
        plans.add(
          NotificationPlan(
            id: preAlertId(upgrade.id, i),
            upgradeId: upgrade.id,
            scheduledAtUtc: scheduledAt,
            type: NotificationPlanType.preAlert,
            title: '⏰ ${upgrade.name} finishing soon',
            body:
                '${upgrade.name} completes in $offsetText.',
          ),
        );
      }
    }

    return plans;
  }

  /// Returns all notification IDs that should be cancelled for an upgrade.
  List<int> idsForUpgrade(
    String upgradeId, {
    int maxPreAlerts = 10,
  }) {
    return [
      completionId(upgradeId),
      for (var i = 0; i < maxPreAlerts; i++) preAlertId(upgradeId, i),
    ];
  }
}

enum NotificationPlanType { completion, preAlert }

/// A single scheduled notification plan entry.
class NotificationPlan {
  const NotificationPlan({
    required this.id,
    required this.upgradeId,
    required this.scheduledAtUtc,
    required this.type,
    required this.title,
    required this.body,
  });

  final int id;
  final String upgradeId;
  final DateTime scheduledAtUtc;
  final NotificationPlanType type;
  final String title;
  final String body;
}
