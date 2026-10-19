import '../models/upgrade.dart';

class UpgradeTimerService {
  Duration remainingTime(DateTime now, Upgrade upgrade) {
    if (upgrade.status == UpgradeStatus.completed ||
        upgrade.status == UpgradeStatus.cancelled) {
      return Duration.zero;
    }

    final remaining = upgrade.expectedCompletionAtUtc.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool isPastDue(DateTime now, Upgrade upgrade) {
    return upgrade.status == UpgradeStatus.active &&
        now.isAfter(upgrade.expectedCompletionAtUtc);
  }

  bool isCompleted(Upgrade upgrade) {
    return upgrade.status == UpgradeStatus.completed;
  }
}
