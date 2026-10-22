import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/notification_preferences_table.dart';

part 'notification_preferences_dao.g.dart';

@DriftAccessor(tables: [NotificationPreferences])
class NotificationPreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationPreferencesDaoMixin {
  NotificationPreferencesDao(super.db);

  /// Watch notification preferences (row id = 1).
  Stream<NotificationPreference> watchPreferences() {
    return (select(notificationPreferences)..where((t) => t.id.equals(1)))
        .watchSingle();
  }

  /// Get current notification preferences.
  Future<NotificationPreference> getPreferences() {
    return (select(notificationPreferences)..where((t) => t.id.equals(1)))
        .getSingle();
  }

  /// Update preferences.
  Future<void> updatePreferences({
    bool? completionEnabled,
    bool? preAlertsEnabled,
    List<int>? reminderOffsetMinutes,
  }) async {
    final now = DateTime.now().toUtc();
    final companion = NotificationPreferencesCompanion(
      completionEnabled: completionEnabled != null
          ? Value(completionEnabled)
          : const Value.absent(),
      preAlertsEnabled: preAlertsEnabled != null
          ? Value(preAlertsEnabled)
          : const Value.absent(),
      reminderOffsetMinutesJson: reminderOffsetMinutes != null
          ? Value(jsonEncode(reminderOffsetMinutes))
          : const Value.absent(),
      updatedAtUtc: Value(now),
    );

    await (update(notificationPreferences)..where((t) => t.id.equals(1)))
        .write(companion);
  }
}

