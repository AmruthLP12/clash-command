import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/core/ids/id_generator.dart';
import 'package:clash_command/domain/models/history_event.dart';
import 'package:clash_command/domain/models/village.dart';

/// Provides the stream of all non-archived villages.
final villagesStreamProvider = StreamProvider<List<Village>>((ref) {
  return ref.watch(villagesDaoProvider).watchAll();
});

/// State notifier for creating, editing, archiving and deleting villages.
class VillagesNotifier extends AsyncNotifier<List<Village>> {
  @override
  Future<List<Village>> build() async {
    return ref.watch(villagesDaoProvider).getAll();
  }

  Future<void> createVillage({
    required String name,
    int? townHallLevel,
    int builderCapacity = 1,
    String? notes,
  }) async {
    final id = const IdGenerator().newId();
    final now = DateTime.now().toUtc();
    final village = Village(
      id: id,
      name: name.trim(),
      townHallLevel: townHallLevel,
      builderCapacity: builderCapacity,
      notes: notes?.trim().isEmpty ?? true ? null : notes?.trim(),
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    await ref.read(villagesDaoProvider).upsert(village);

    // Record history event
    await ref.read(historyEventsDaoProvider).insertEvent(
          HistoryEvent(
            id: const IdGenerator().newId(),
            villageId: id,
            villageName: village.name,
            eventType: HistoryEventType.villageCreated,
            description: 'Village "${village.name}" created',
            createdAtUtc: now,
          ),
        );

    ref.invalidateSelf();
    await ref.read(homeWidgetSyncServiceProvider).syncWidgets(specificVillageId: id);
  }

  Future<void> updateVillage(Village village) async {
    final now = DateTime.now().toUtc();
    final updated = village.copyWith(updatedAtUtc: now);
    await ref.read(villagesDaoProvider).upsert(updated);

    // Record history event
    await ref.read(historyEventsDaoProvider).insertEvent(
          HistoryEvent(
            id: const IdGenerator().newId(),
            villageId: village.id,
            villageName: village.name,
            eventType: HistoryEventType.villageEdited,
            description: 'Village "${village.name}" updated',
            createdAtUtc: now,
          ),
        );

    ref.invalidateSelf();
    await ref.read(homeWidgetSyncServiceProvider).syncWidgets(specificVillageId: village.id);
  }

  Future<void> archiveVillage(String id) async {
    final village = await ref.read(villagesDaoProvider).findById(id);
    await ref.read(villagesDaoProvider).archive(id);

    if (village != null) {
      await ref.read(historyEventsDaoProvider).insertEvent(
            HistoryEvent(
              id: const IdGenerator().newId(),
              villageId: id,
              villageName: village.name,
              eventType: HistoryEventType.villageArchived,
              description: 'Village "${village.name}" archived',
              createdAtUtc: DateTime.now().toUtc(),
            ),
          );
    }
    ref.invalidateSelf();
    await ref.read(homeWidgetSyncServiceProvider).syncWidgets();
  }

  Future<void> deleteVillage(String id) async {
    await ref.read(historyEventsDaoProvider).deleteForVillage(id);
    await ref.read(villagesDaoProvider).deleteVillage(id);
    ref.invalidateSelf();
    await ref.read(homeWidgetSyncServiceProvider).syncWidgets();
  }
}

final villagesNotifierProvider =
    AsyncNotifierProvider<VillagesNotifier, List<Village>>(
  VillagesNotifier.new,
);
