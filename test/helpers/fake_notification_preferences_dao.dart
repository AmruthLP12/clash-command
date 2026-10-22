import 'package:clash_command/database/app_database.dart';
import 'package:clash_command/database/daos/notification_preferences_dao.dart';

/// In-test fake that returns fixed preferences without a real database.
class FakeNotificationPreferencesDao implements NotificationPreferencesDao {
  FakeNotificationPreferencesDao({
    this.completionEnabled = true,
    this.preAlertsEnabled = true,
    this.offsetsJson = '[30,5]',
  });

  bool completionEnabled;
  bool preAlertsEnabled;
  String offsetsJson;

  NotificationPreference get _current => NotificationPreference(
        id: 1,
        completionEnabled: completionEnabled,
        preAlertsEnabled: preAlertsEnabled,
        reminderOffsetMinutesJson: offsetsJson,
        updatedAtUtc: DateTime.utc(2026, 1, 1),
      );

  @override
  Stream<NotificationPreference> watchPreferences() => Stream.value(_current);

  @override
  Future<NotificationPreference> getPreferences() async => _current;

  @override
  Future<void> updatePreferences({
    bool? completionEnabled,
    bool? preAlertsEnabled,
    List<int>? reminderOffsetMinutes,
  }) async {
    if (completionEnabled != null) this.completionEnabled = completionEnabled;
    if (preAlertsEnabled != null) this.preAlertsEnabled = preAlertsEnabled;
    if (reminderOffsetMinutes != null) {
      offsetsJson = reminderOffsetMinutes.toString();
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

