import '../models/upgrade.dart';

class VillageService {
  int activeUpgradeCount(List<Upgrade> upgrades) {
    return upgrades
        .where((upgrade) => upgrade.status == UpgradeStatus.active)
        .length;
  }

  DateTime? nextCompletionAtUtc(List<Upgrade> upgrades) {
    final activeUpgrades = upgrades
        .where((upgrade) => upgrade.status == UpgradeStatus.active)
        .toList();

    if (activeUpgrades.isEmpty) {
      return null;
    }

    final earliest = activeUpgrades.reduce((current, next) {
      return current.expectedCompletionAtUtc.isBefore(
            next.expectedCompletionAtUtc,
          )
          ? current
          : next;
    });

    return earliest.expectedCompletionAtUtc;
  }

  bool hasPastDueUpgrade(List<Upgrade> upgrades) {
    return upgrades.any(
      (upgrade) =>
          upgrade.status == UpgradeStatus.active &&
          upgrade.expectedCompletionAtUtc.isBefore(DateTime.now()),
    );
  }
}
