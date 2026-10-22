import 'package:clash_command/database/daos/history_events_dao.dart';
import 'package:clash_command/domain/models/history_event.dart';

/// In-test fake that returns fixed history event lists without a real database.
class FakeHistoryEventsDao implements HistoryEventsDao {
  FakeHistoryEventsDao([this._events = const []]);

  final List<HistoryEvent> _events;

  @override
  Stream<List<HistoryEvent>> watchAll() => Stream.value(_events);

  @override
  Stream<List<HistoryEvent>> watchForVillage(String villageId) =>
      Stream.value(_events.where((e) => e.villageId == villageId).toList());

  @override
  Stream<List<HistoryEvent>> watchForUpgrade(String upgradeId) =>
      Stream.value(_events.where((e) => e.upgradeId == upgradeId).toList());

  @override
  Future<void> insertEvent(HistoryEvent event) async {}

  @override
  Future<void> deleteForVillage(String villageId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

