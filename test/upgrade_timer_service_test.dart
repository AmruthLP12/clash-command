import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/services/upgrade_timer_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = UpgradeTimerService();

  // Helper to build a minimal active upgrade
  Upgrade makeActive({
    required DateTime now,
    required Duration remainingFromNow,
    String id = 'u1',
  }) {
    return Upgrade(
      id: id,
      villageId: 'v1',
      name: 'Test upgrade',
      category: UpgradeCategory.building,
      startedAtUtc: now.subtract(const Duration(hours: 1)),
      expectedCompletionAtUtc: now.add(remainingFromNow),
      status: UpgradeStatus.active,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
  }

  Upgrade makeCompleted({required DateTime now}) {
    return Upgrade(
      id: 'u2',
      villageId: 'v1',
      name: 'Done upgrade',
      category: UpgradeCategory.building,
      startedAtUtc: now.subtract(const Duration(hours: 3)),
      expectedCompletionAtUtc: now.subtract(const Duration(minutes: 5)),
      status: UpgradeStatus.completed,
      completedAtUtc: now.subtract(const Duration(minutes: 5)),
      createdAtUtc: now,
      updatedAtUtc: now,
    );
  }

  Upgrade makeCancelled({required DateTime now}) {
    return Upgrade(
      id: 'u3',
      villageId: 'v1',
      name: 'Cancelled upgrade',
      category: UpgradeCategory.building,
      startedAtUtc: now.subtract(const Duration(hours: 2)),
      expectedCompletionAtUtc: now.add(const Duration(hours: 1)),
      status: UpgradeStatus.cancelled,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
  }

  group('UpgradeTimerService.remainingTime', () {
    test('returns correct remaining duration for an active upgrade', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      final upgrade = makeActive(now: now, remainingFromNow: const Duration(hours: 2));
      expect(service.remainingTime(now, upgrade), const Duration(hours: 2));
    });

    test('returns zero for a completed upgrade', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      expect(service.remainingTime(now, makeCompleted(now: now)), Duration.zero);
    });

    test('returns zero for a cancelled upgrade', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      expect(service.remainingTime(now, makeCancelled(now: now)), Duration.zero);
    });

    test('returns zero (not negative) when an active upgrade is past due', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      final upgrade = makeActive(now: now, remainingFromNow: const Duration(minutes: -30));
      expect(service.remainingTime(now, upgrade), Duration.zero);
    });

    test('remaining time decreases correctly over time', () {
      final start = DateTime.utc(2026, 10, 19, 12, 0, 0);
      final upgrade = makeActive(
          now: start, remainingFromNow: const Duration(hours: 3));
      final twoHoursLater = start.add(const Duration(hours: 2));
      final remaining = service.remainingTime(twoHoursLater, upgrade);
      expect(remaining, const Duration(hours: 1));
    });
  });

  group('UpgradeTimerService.isPastDue', () {
    test('returns true when active and past expected completion', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      final upgrade = makeActive(now: now, remainingFromNow: const Duration(minutes: -1));
      expect(service.isPastDue(now, upgrade), isTrue);
    });

    test('returns false when active and not yet past completion', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      final upgrade = makeActive(now: now, remainingFromNow: const Duration(minutes: 30));
      expect(service.isPastDue(now, upgrade), isFalse);
    });

    test('returns false for a completed upgrade even if time is past', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      expect(service.isPastDue(now, makeCompleted(now: now)), isFalse);
    });

    test('returns false for a cancelled upgrade', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      expect(service.isPastDue(now, makeCancelled(now: now)), isFalse);
    });
  });

  group('UpgradeTimerService.isCompleted / isCancelled', () {
    test('isCompleted is true only for completed status', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      expect(service.isCompleted(makeCompleted(now: now)), isTrue);
      expect(service.isCompleted(makeActive(now: now, remainingFromNow: const Duration(hours: 1))), isFalse);
      expect(service.isCompleted(makeCancelled(now: now)), isFalse);
    });

    test('isCancelled is true only for cancelled status', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      expect(service.isCancelled(makeCancelled(now: now)), isTrue);
      expect(service.isCancelled(makeCompleted(now: now)), isFalse);
      expect(service.isCancelled(makeActive(now: now, remainingFromNow: const Duration(hours: 1))), isFalse);
    });
  });

  group('UpgradeTimerService.computeExpectedCompletion', () {
    test('adds duration to start time correctly', () {
      final start = DateTime.utc(2026, 10, 19, 10, 0, 0);
      final completion = service.computeExpectedCompletion(
        startedAtUtc: start,
        duration: const Duration(hours: 4, minutes: 30),
      );
      expect(completion, DateTime.utc(2026, 10, 19, 14, 30, 0));
    });
  });

  group('UpgradeTimerService.computeCompletionFromRemaining', () {
    test('adds remaining time to now', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      final completion = service.computeCompletionFromRemaining(
        now: now,
        remaining: const Duration(hours: 2, minutes: 15),
      );
      expect(completion, DateTime.utc(2026, 10, 19, 14, 15, 0));
    });
  });

  group('UpgradeTimerService.elapsedTime', () {
    test('returns time since start', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      final start = now.subtract(const Duration(hours: 1, minutes: 30));
      final upgrade = Upgrade(
        id: 'u4',
        villageId: 'v1',
        name: 'Elapsed test',
        category: UpgradeCategory.building,
        startedAtUtc: start,
        expectedCompletionAtUtc: now.add(const Duration(hours: 1)),
        status: UpgradeStatus.active,
        createdAtUtc: now,
        updatedAtUtc: now,
      );
      expect(
        service.elapsedTime(now, upgrade),
        const Duration(hours: 1, minutes: 30),
      );
    });

    test('returns zero if start is in the future', () {
      final now = DateTime.utc(2026, 10, 19, 12, 0, 0);
      final upgrade = Upgrade(
        id: 'u5',
        villageId: 'v1',
        name: 'Future start',
        category: UpgradeCategory.building,
        startedAtUtc: now.add(const Duration(hours: 1)),
        expectedCompletionAtUtc: now.add(const Duration(hours: 3)),
        status: UpgradeStatus.active,
        createdAtUtc: now,
        updatedAtUtc: now,
      );
      expect(service.elapsedTime(now, upgrade), Duration.zero);
    });
  });
}
