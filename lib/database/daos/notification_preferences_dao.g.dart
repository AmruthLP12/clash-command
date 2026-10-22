// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_dao.dart';

// ignore_for_file: type=lint
mixin _$NotificationPreferencesDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotificationPreferencesTable get notificationPreferences =>
      attachedDatabase.notificationPreferences;
  NotificationPreferencesDaoManager get managers =>
      NotificationPreferencesDaoManager(this);
}

class NotificationPreferencesDaoManager {
  final _$NotificationPreferencesDaoMixin _db;
  NotificationPreferencesDaoManager(this._db);
  $$NotificationPreferencesTableTableManager get notificationPreferences =>
      $$NotificationPreferencesTableTableManager(
        _db.attachedDatabase,
        _db.notificationPreferences,
      );
}
