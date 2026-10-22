import 'package:drift/drift.dart';

import '../../domain/models/history_event.dart';
import '../app_database.dart';
import '../tables/history_events_table.dart';

part 'history_events_dao.g.dart';

@DriftAccessor(tables: [HistoryEvents])
class HistoryEventsDao extends DatabaseAccessor<AppDatabase>
    with _$HistoryEventsDaoMixin {
  HistoryEventsDao(super.db);

  /// Watch all events, newest first.
  Stream<List<HistoryEvent>> watchAll() {
    return (select(historyEvents)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtUtc)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Watch events for a specific village, newest first.
  Stream<List<HistoryEvent>> watchForVillage(String villageId) {
    return (select(historyEvents)
          ..where((t) => t.villageId.equals(villageId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtUtc)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Watch events for a specific upgrade, newest first.
  Stream<List<HistoryEvent>> watchForUpgrade(String upgradeId) {
    return (select(historyEvents)
          ..where((t) => t.upgradeId.equals(upgradeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtUtc)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Insert a history event.
  Future<void> insertEvent(HistoryEvent event) {
    return into(historyEvents).insert(
      HistoryEventsCompanion.insert(
        id: event.id,
        upgradeId: Value(event.upgradeId),
        villageId: Value(event.villageId),
        eventType: event.eventType.name,
        description: event.description,
        upgradeName: Value(event.upgradeName),
        villageName: Value(event.villageName),
        createdAtUtc: event.createdAtUtc,
      ),
    );
  }

  /// Delete all events for a village.
  Future<void> deleteForVillage(String villageId) {
    return (delete(historyEvents)
          ..where((t) => t.villageId.equals(villageId)))
        .go();
  }

  HistoryEvent _toDomain(HistoryEventRow row) {
    return HistoryEvent(
      id: row.id,
      upgradeId: row.upgradeId,
      villageId: row.villageId,
      eventType: HistoryEventType.fromString(row.eventType),
      description: row.description,
      upgradeName: row.upgradeName,
      villageName: row.villageName,
      createdAtUtc: row.createdAtUtc,
    );
  }
}

