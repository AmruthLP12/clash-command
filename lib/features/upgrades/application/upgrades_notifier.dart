import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/core/ids/id_generator.dart';
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
  }

  Future<void> cancelUpgrade(Upgrade upgrade) async {
    final now = DateTime.now().toUtc();
    final lifecycleService = ref.read(upgradeLifecycleServiceProvider);
    final result = lifecycleService.cancel(upgrade, now);
    if (result.isFailure) return;

    await ref.read(upgradesDaoProvider).upsert(result.value);
    await ref.read(notificationServiceProvider).cancelForUpgrade(upgrade.id);
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
  }

  Future<void> deleteUpgrade(String id) async {
    await ref.read(upgradesDaoProvider).deleteUpgrade(id);
    await ref.read(notificationServiceProvider).cancelForUpgrade(id);
  }
}

final upgradesNotifierProvider =
    AsyncNotifierProvider<UpgradesNotifier, void>(UpgradesNotifier.new);
