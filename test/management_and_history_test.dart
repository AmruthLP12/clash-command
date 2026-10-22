import 'package:clash_command/domain/models/history_event.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/services/upgrade_timer_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 22, 10, 0, 0);

  group('Village Management', () {
    test('Village can be created with custom properties and notes', () {
      final village = Village(
        id: 'v-custom',
        name: 'War Base',
        townHallLevel: 16,
        builderCapacity: 6,
        notes: 'Priority: Heroes and Defenses',
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      expect(village.name, 'War Base');
      expect(village.townHallLevel, 16);
      expect(village.builderCapacity, 6);
      expect(village.notes, 'Priority: Heroes and Defenses');
    });

    test('Village can be updated with new builder capacity and town hall', () {
      final village = Village(
        id: 'v1',
        name: 'Builder Hall',
        townHallLevel: 9,
        builderCapacity: 2,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      final updated = village.copyWith(
        name: 'Builder Base 2.0',
        townHallLevel: 10,
        builderCapacity: 3,
        notes: '6th builder unlocked',
      );

      expect(updated.name, 'Builder Base 2.0');
      expect(updated.townHallLevel, 10);
      expect(updated.builderCapacity, 3);
      expect(updated.notes, '6th builder unlocked');
    });
  });

  group('Upgrade Editing and Timing', () {
    test('Editing upgrade name and builder does not alter original timestamps', () {
      final upgrade = Upgrade(
        id: 'up-1',
        villageId: 'v1',
        name: 'Archer Queen Level 70',
        category: UpgradeCategory.hero,
        slotKey: 'Builder 1',
        notes: 'Need for CWL',
        startedAtUtc: now,
        expectedCompletionAtUtc: now.add(const Duration(days: 7)),
        status: UpgradeStatus.active,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      final edited = upgrade.copyWith(
        name: 'Archer Queen Level 71',
        slotKey: 'Master Builder',
        notes: 'Using Hero Potion',
      );

      // Name and slot updated
      expect(edited.name, 'Archer Queen Level 71');
      expect(edited.slotKey, 'Master Builder');
      expect(edited.notes, 'Using Hero Potion');

      // Original start time and expected completion time preserved exactly
      expect(edited.startedAtUtc, upgrade.startedAtUtc);
      expect(edited.expectedCompletionAtUtc, upgrade.expectedCompletionAtUtc);
    });

    test('Upgrade timer calculation works with user-defined remaining duration', () {
      const timerService = UpgradeTimerService();
      final startTime = now.subtract(const Duration(hours: 4));
      final expectedEnd = startTime.add(const Duration(hours: 12));

      final upgrade = Upgrade(
        id: 'up-2',
        villageId: 'v1',
        name: 'Custom Defense Weapon',
        category: UpgradeCategory.defense,
        startedAtUtc: startTime,
        expectedCompletionAtUtc: expectedEnd,
        status: UpgradeStatus.active,
        createdAtUtc: startTime,
        updatedAtUtc: startTime,
      );

      final remaining = timerService.remainingTime(now, upgrade);
      // 12 hours total - 4 hours elapsed = 8 hours remaining
      expect(remaining.inHours, 8);
      expect(timerService.isPastDue(now, upgrade), isFalse);
    });
  });

  group('History Events Logging', () {
    test('HistoryEvent holds rich metadata about state transitions', () {
      final event = HistoryEvent(
        id: 'evt-1',
        upgradeId: 'up-1',
        villageId: 'v1',
        upgradeName: 'Eagle Artillery',
        villageName: 'Main Base',
        eventType: HistoryEventType.upgradeCompleted,
        description: 'Completed upgrade "Eagle Artillery"',
        createdAtUtc: now,
      );

      expect(event.eventType, HistoryEventType.upgradeCompleted);
      expect(event.upgradeName, 'Eagle Artillery');
      expect(event.villageName, 'Main Base');
      expect(event.description, contains('Completed upgrade'));
    });
  });
}

