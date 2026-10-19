import '../models/upgrade.dart';
import '../models/upgrade_status.dart';

/// Domain service for village-level summary logic.
///
/// All methods are pure functions — no database access, no Flutter dependency.
class VillageService {
  const VillageService();

  /// Returns the count of currently active upgrades.
  int activeUpgradeCount(List<Upgrade> upgrades) {
    return upgrades
        .where((u) => u.status == UpgradeStatus.active)
        .length;
  }

  /// Returns the expected completion time of the soonest active upgrade,
  /// or null when there are no active upgrades.
  DateTime? nextCompletionAtUtc(List<Upgrade> upgrades) {
    final active = upgrades
        .where((u) => u.status == UpgradeStatus.active)
        .toList();

    if (active.isEmpty) return null;

    return active
        .map((u) => u.expectedCompletionAtUtc)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Returns true if any active upgrade has already passed its expected
  /// completion time (i.e. it is past due).
  bool hasPastDueUpgrade(List<Upgrade> upgrades) {
    final now = DateTime.now().toUtc();
    return upgrades.any(
      (u) =>
          u.status == UpgradeStatus.active &&
          u.expectedCompletionAtUtc.isBefore(now),
    );
  }

  /// Returns true if the village has available builder slots based on its
  /// configured [builderCapacity] and the number of currently active upgrades.
  bool hasAvailableSlot(List<Upgrade> upgrades, int builderCapacity) {
    return activeUpgradeCount(upgrades) < builderCapacity;
  }

  /// Returns the number of free builder slots.
  int availableSlots(List<Upgrade> upgrades, int builderCapacity) {
    final active = activeUpgradeCount(upgrades);
    final free = builderCapacity - active;
    return free < 0 ? 0 : free;
  }

  /// Returns upgrades sorted by expected completion time (earliest first),
  /// filtering only active upgrades.
  List<Upgrade> activeUpgradesSortedByCompletion(List<Upgrade> upgrades) {
    final active = upgrades
        .where((u) => u.status == UpgradeStatus.active)
        .toList();
    active.sort(
      (a, b) =>
          a.expectedCompletionAtUtc.compareTo(b.expectedCompletionAtUtc),
    );
    return active;
  }
}
