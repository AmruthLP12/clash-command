import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/services/upgrade_timer_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpgradeTimerService', () {
    final service = UpgradeTimerService();

    test('derives remaining time from the absolute completion timestamp', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      final upgrade = Upgrade(
        id: 'upgrade-1',
        villageId: 'village-1',
        name: 'Barracks upgrade',
        category: 'building',
        startedAtUtc: now.subtract(const Duration(hours: 1)),
        expectedCompletionAtUtc: now.add(const Duration(hours: 2)),
        status: UpgradeStatus.active,
      );

      expect(service.remainingTime(now, upgrade), const Duration(hours: 2));
      expect(service.isPastDue(now.add(const Duration(hours: 3)), upgrade), isTrue);
      expect(service.isPastDue(now.add(const Duration(minutes: 30)), upgrade), isFalse);
    });

    test('treats completed timers as not active and not overdue', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      final upgrade = Upgrade(
        id: 'upgrade-2',
        villageId: 'village-1',
        name: 'Laboratory upgrade',
        category: 'building',
        startedAtUtc: now.subtract(const Duration(hours: 2)),
        expectedCompletionAtUtc: now.subtract(const Duration(minutes: 5)),
        status: UpgradeStatus.completed,
        completedAtUtc: now.subtract(const Duration(minutes: 5)),
      );

      expect(service.remainingTime(now, upgrade), Duration.zero);
      expect(service.isPastDue(now, upgrade), isFalse);
      expect(service.isCompleted(upgrade), isTrue);
    });
  });
}
