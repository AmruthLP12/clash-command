// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_events_dao.dart';

// ignore_for_file: type=lint
mixin _$HistoryEventsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HistoryEventsTable get historyEvents => attachedDatabase.historyEvents;
  HistoryEventsDaoManager get managers => HistoryEventsDaoManager(this);
}

class HistoryEventsDaoManager {
  final _$HistoryEventsDaoMixin _db;
  HistoryEventsDaoManager(this._db);
  $$HistoryEventsTableTableManager get historyEvents =>
      $$HistoryEventsTableTableManager(_db.attachedDatabase, _db.historyEvents);
}
