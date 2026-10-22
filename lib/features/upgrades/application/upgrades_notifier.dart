import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/core/ids/id_generator.dart';
import 'package:clash_command/domain/models/history_event.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/services/upgrade_timer_service.dart';

/// Provides a stream of active upgrades for a specific village.
final activeUpgradesForVillageProvider =
    StreamProvider.family<List<Upgrade>, String>((ref, villageId) {
  return ref.watch(upgradesDaoProvider).watchActiveForVillage(villageId);
});

/// Provides a stream of all active upgrades across all villages.
final allActiveUpgradesProvider = StreamProvider<List<Upgrade>>((ref) {
  return ref.watch(upgradesDaoProvider).watchAllActive();
});

/// Provides all upgrades (history) for a specific village.
final upgradeHistoryProvider =
    StreamProvider.family<List<Upgrade>, String>((ref, villageId) {
  return ref.watch(upgradesDaoProvider).watchAllForVillage(villageId);
});

/// Provides a stream of history events for a specific village.
final villageHistoryEventsProvider =
    StreamProvider.family<List<HistoryEvent>, String>((ref, villageId) {
  return ref.watch(historyEventsDaoProvider).watchForVillage(villageId);
});

/// Provides a stream of history events for a specific upgrade.
final upgradeHistoryEventsProvider =
    StreamProvider.family<List<HistoryEvent>, String>((ref, upgradeId) {
  return ref.watch(historyEventsDaoProvider).watchForUpgrade(upgradeId);
});

/// Provides a stream of all history events.
final allHistoryEventsProvider = StreamProvider<List<HistoryEvent>>((ref) {
  return ref.watch(historyEventsDaoProvider).watchAll();
});

/// Manages upgrade creation, editing, completion, and cancellation.
class UpgradesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String> startUpgrade({
    required String villageId,
    required String name,
    required UpgradeCategory category,
    required Duration duration,
    DateTime? startedAtUtc,
    String? slotKey,
    String? notes,
  }) async {
    final id = const IdGenerator().newId();
    final now = DateTime.now().toUtc();
    final start = (startedAtUtc ?? now).toUtc();

    const timerService = UpgradeTimerService();
    final upgrade = Upgrade(
      id: id,
      villageId: villageId,
      name: name.trim(),
      category: category,
      slotKey: slotKey,
      notes: notes?.trim().isEmpty ?? true ? null : notes?.trim(),
      startedAtUtc: start,
      expectedCompletionAtUtc: timerService.computeExpectedCompletion(
        startedAtUtc: start,
        duration: duration,
      ),
      status: UpgradeStatus.active,
      createdAtUtc: now,
      updatedAtUtc: now,
    );

    await ref.read(upgradesDaoProvider).upsert(upgrade);

    // Record history event
    final village = await ref.read(villagesDaoProvider).findById(villageId);
    await ref.read(historyEventsDaoProvider).insertEvent(
          HistoryEvent(
            id: const IdGenerator().newId(),
            upgradeId: id,
            villageId: villageId,
            upgradeName: upgrade.name,
            villageName: village?.name,
            eventType: HistoryEventType.upgradeStarted,
            description: 'Started upgrade "${upgrade.name}"',
            createdAtUtc: now,
          ),
        );

    // Schedule notifications
    final planService = ref.read(notificationPlanServiceProvider);
    final notifService = ref.read(notificationServiceProvider);
    final plans = planService.buildPlan(upgrade, now);
    await notifService.schedulePlans(plans);

    return id;
  }

  Future<void> startUpgradeFromRemaining({
    required String villageId,
    required String name,
    required UpgradeCategory category,
    required Duration remaining,
    String? slotKey,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    await startUpgrade(
      villageId: villageId,
      name: name,
      category: category,
      duration: remaining,
      startedAtUtc: now,
      slotKey: slotKey,
      notes: notes,
    );
  }

  Future<void> completeUpgrade(Upgrade upgrade) async {
    final now = DateTime.now().toUtc();
    final lifecycleService = ref.read(upgradeLifecycleServiceProvider);
    final result = lifecycleService.complete(upgrade, now);
    if (result.isFailure) return;

    await ref.read(upgradesDaoProvider).upsert(result.value);
    await ref.read(notificationServiceProvider).cancelForUpgrade(upgrade.id);

    final village =
        await ref.read(villagesDaoProvider).findById(upgrade.villageId);
    await ref.read(historyEventsDaoProvider).insertEvent(
          HistoryEvent(
            id: const IdGenerator().newId(),
            upgradeId: upgrade.id,
            villageId: upgrade.villageId,
            upgradeName: upgrade.name,
            villageName: village?.name,
            eventType: HistoryEventType.upgradeCompleted,
            description: 'Completed upgrade "${upgrade.name}"',
            createdAtUtc: now,
          ),
        );
  }

  Future<void> cancelUpgrade(Upgrade upgrade) async {
    final now = DateTime.now().toUtc();
    final lifecycleService = ref.read(upgradeLifecycleServiceProvider);
    final result = lifecycleService.cancel(upgrade, now);
    if (result.isFailure) return;

    await ref.read(upgradesDaoProvider).upsert(result.value);
    await ref.read(notificationServiceProvider).cancelForUpgrade(upgrade.id);

    final village =
        await ref.read(villagesDaoProvider).findById(upgrade.villageId);
    await ref.read(historyEventsDaoProvider).insertEvent(
          HistoryEvent(
            id: const IdGenerator().newId(),
            upgradeId: upgrade.id,
            villageId: upgrade.villageId,
            upgradeName: upgrade.name,
            villageName: village?.name,
            eventType: HistoryEventType.upgradeCancelled,
            description: 'Cancelled upgrade "${upgrade.name}"',
            createdAtUtc: now,
          ),
        );
  }

  Future<void> reopenUpgrade(
    Upgrade upgrade,
    DateTime newExpectedCompletionAtUtc,
  ) async {
    final now = DateTime.now().toUtc();
    final lifecycleService = ref.read(upgradeLifecycleServiceProvider);
    final result = lifecycleService.reopen(
      upgrade,
      newExpectedCompletionAtUtc,
      now,
    );
    if (result.isFailure) return;

    await ref.read(upgradesDaoProvider).upsert(result.value);

    // Schedule notifications for reopened upgrade
    final planService = ref.read(notificationPlanServiceProvider);
    final notifService = ref.read(notificationServiceProvider);
    final plans = planService.buildPlan(result.value, now);
    await notifService.schedulePlans(plans);

    final village =
        await ref.read(villagesDaoProvider).findById(upgrade.villageId);
    await ref.read(historyEventsDaoProvider).insertEvent(
          HistoryEvent(
            id: const IdGenerator().newId(),
            upgradeId: upgrade.id,
            villageId: upgrade.villageId,
            upgradeName: upgrade.name,
            villageName: village?.name,
            eventType: HistoryEventType.upgradeReopened,
            description: 'Reopened upgrade "${upgrade.name}"',
            createdAtUtc: now,
          ),
        );
  }

  Future<void> editTimer(
    Upgrade upgrade,
    DateTime newExpectedCompletionAtUtc,
  ) async {
    final now = DateTime.now().toUtc();
    final lifecycleService = ref.read(upgradeLifecycleServiceProvider);
    final result = lifecycleService.editTimer(
      upgrade,
      newExpectedCompletionAtUtc,
      now,
    );
    if (result.isFailure) return;

    await ref.read(upgradesDaoProvider).upsert(result.value);

    // Reschedule notifications
    final planService = ref.read(notificationPlanServiceProvider);
    final notifService = ref.read(notificationServiceProvider);
    await notifService.cancelForUpgrade(upgrade.id);
    final plans = planService.buildPlan(result.value, now);
    await notifService.schedulePlans(plans);

    final village =
        await ref.read(villagesDaoProvider).findById(upgrade.villageId);
    await ref.read(historyEventsDaoProvider).insertEvent(
          HistoryEvent(
            id: const IdGenerator().newId(),
            upgradeId: upgrade.id,
            villageId: upgrade.villageId,
            upgradeName: upgrade.name,
            villageName: village?.name,
            eventType: HistoryEventType.upgradeTimerEdited,
            description: 'Adjusted timer for "${upgrade.name}"',
            createdAtUtc: now,
          ),
        );
  }

  /// Edits non-timer fields on an upgrade (name, category, slot, notes).
  /// If [newExpectedCompletionAtUtc] is provided, the timer is also adjusted.
  Future<void> editUpgradeDetails(
    Upgrade upgrade, {
    String? name,
    UpgradeCategory? category,
    String? slotKey,
    bool clearSlotKey = false,
    String? notes,
    bool clearNotes = false,
    DateTime? newExpectedCompletionAtUtc,
  }) async {
    final now = DateTime.now().toUtc();
    Upgrade updated = upgrade.copyWith(
      name: name,
      category: category,
      slotKey: slotKey,
      clearSlotKey: clearSlotKey,
      notes: notes,
      clearNotes: clearNotes,
      updatedAtUtc: now,
    );

    // If the timer is being adjusted, validate via lifecycle service
    if (newExpectedCompletionAtUtc != null &&
        newExpectedCompletionAtUtc != upgrade.expectedCompletionAtUtc) {
      final lifecycleService = ref.read(upgradeLifecycleServiceProvider);
      final result = lifecycleService.editTimer(
        updated,
        newExpectedCompletionAtUtc,
        now,
      );
      if (result.isFailure) return;
      updated = result.value;

      // Reschedule notifications for the new timer
      final planService = ref.read(notificationPlanServiceProvider);
      final notifService = ref.read(notificationServiceProvider);
      await notifService.cancelForUpgrade(upgrade.id);
      final plans = planService.buildPlan(updated, now);
      await notifService.schedulePlans(plans);
    }

    await ref.read(upgradesDaoProvider).upsert(updated);

    final village =
        await ref.read(villagesDaoProvider).findById(upgrade.villageId);
    await ref.read(historyEventsDaoProvider).insertEvent(
          HistoryEvent(
            id: const IdGenerator().newId(),
            upgradeId: upgrade.id,
            villageId: upgrade.villageId,
            upgradeName: updated.name,
            villageName: village?.name,
            eventType: HistoryEventType.upgradeEdited,
            description: 'Updated details for "${updated.name}"',
            createdAtUtc: now,
          ),
        );
  }

  Future<void> deleteUpgrade(String id) async {
    final upgrade = await ref.read(upgradesDaoProvider).findById(id);
    await ref.read(upgradesDaoProvider).deleteUpgrade(id);
    await ref.read(notificationServiceProvider).cancelForUpgrade(id);

    if (upgrade != null) {
      final village =
          await ref.read(villagesDaoProvider).findById(upgrade.villageId);
      await ref.read(historyEventsDaoProvider).insertEvent(
            HistoryEvent(
              id: const IdGenerator().newId(),
              upgradeId: id,
              villageId: upgrade.villageId,
              upgradeName: upgrade.name,
              villageName: village?.name,
              eventType: HistoryEventType.upgradeDeleted,
              description: 'Deleted upgrade "${upgrade.name}"',
              createdAtUtc: DateTime.now().toUtc(),
            ),
          );
    }
  }
}

final upgradesNotifierProvider =
    AsyncNotifierProvider<UpgradesNotifier, void>(UpgradesNotifier.new);
