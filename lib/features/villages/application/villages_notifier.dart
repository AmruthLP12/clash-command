import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/core/ids/id_generator.dart';
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
      notes: notes,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    await ref.read(villagesDaoProvider).upsert(village);
    ref.invalidateSelf();
  }

  Future<void> updateVillage(Village village) async {
    final updated = village.copyWith(updatedAtUtc: DateTime.now().toUtc());
    await ref.read(villagesDaoProvider).upsert(updated);
    ref.invalidateSelf();
  }

  Future<void> archiveVillage(String id) async {
    await ref.read(villagesDaoProvider).archive(id);
    ref.invalidateSelf();
  }

  Future<void> deleteVillage(String id) async {
    await ref.read(villagesDaoProvider).deleteVillage(id);
    ref.invalidateSelf();
  }
}

final villagesNotifierProvider =
    AsyncNotifierProvider<VillagesNotifier, List<Village>>(
  VillagesNotifier.new,
);
