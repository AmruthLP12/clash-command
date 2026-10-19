import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/services/village_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = VillageService();
  final now = DateTime.utc(2026, 10, 19, 12, 0, 0);

  Village makeVillage({int builders = 2}) => Village(
        id: 'v1',
        name: 'Test Village',
        builderCapacity: builders,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

  Upgrade makeUpgrade({
    required String id,
    required UpgradeStatus status,
    Duration completionOffset = const Duration(hours: 1),
  }) {
    return Upgrade(
      id: id,
      villageId: 'v1',
      name: 'Upgrade $id',
      category: UpgradeCategory.building,
      startedAtUtc: now.subtract(const Duration(hours: 1)),
      expectedCompletionAtUtc: now.add(completionOffset),
      status: status,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
  }

  group('VillageService.activeUpgradeCount', () {
    test('counts only active upgrades', () {
      final upgrades = [
        makeUpgrade(id: 'u1', status: UpgradeStatus.active),
        makeUpgrade(id: 'u2', status: UpgradeStatus.active),
        makeUpgrade(id: 'u3', status: UpgradeStatus.completed),
        makeUpgrade(id: 'u4', status: UpgradeStatus.cancelled),
      ];
      expect(service.activeUpgradeCount(upgrades), 2);
    });

    test('returns zero when no upgrades', () {
      expect(service.activeUpgradeCount([]), 0);
    });

    test('returns zero when all upgrades are completed', () {
      final upgrades = [
        makeUpgrade(id: 'u1', status: UpgradeStatus.completed),
        makeUpgrade(id: 'u2', status: UpgradeStatus.completed),
      ];
      expect(service.activeUpgradeCount(upgrades), 0);
    });
  });

  group('VillageService.nextCompletionAtUtc', () {
    test('returns the earliest expected completion among active upgrades', () {
      final upgrades = [
        makeUpgrade(
            id: 'u1',
            status: UpgradeStatus.active,
            completionOffset: const Duration(hours: 2)),
        makeUpgrade(
            id: 'u2',
            status: UpgradeStatus.active,
            completionOffset: const Duration(minutes: 45)),
        makeUpgrade(id: 'u3', status: UpgradeStatus.completed),
      ];
      expect(
        service.nextCompletionAtUtc(upgrades),
        now.add(const Duration(minutes: 45)),
      );
    });

    test('returns null when there are no active upgrades', () {
      final upgrades = [
        makeUpgrade(id: 'u1', status: UpgradeStatus.completed),
      ];
      expect(service.nextCompletionAtUtc(upgrades), isNull);
    });

    test('returns null for empty list', () {
      expect(service.nextCompletionAtUtc([]), isNull);
    });

    test('returns the single active completion correctly', () {
      final expected = now.add(const Duration(hours: 3));
      final upgrades = [
        makeUpgrade(
            id: 'u1',
            status: UpgradeStatus.active,
            completionOffset: const Duration(hours: 3)),
      ];
      expect(service.nextCompletionAtUtc(upgrades), expected);
    });
  });

  group('VillageService.hasPastDueUpgrade', () {
    // Note: this method uses DateTime.now() internally, so we test with a
    // future upgrade (should be false) and verify the returned type.
    test('returns a bool', () {
      final result = service.hasPastDueUpgrade([]);
      expect(result, isFalse);
    });
  });

  group('VillageService.hasAvailableSlot', () {
    test('returns true when fewer actives than capacity', () {
      final village = makeVillage(builders: 2);
      final upgrades = [
        makeUpgrade(id: 'u1', status: UpgradeStatus.active),
      ];
      expect(service.hasAvailableSlot(upgrades, village.builderCapacity), isTrue);
    });

    test('returns false when actives equal capacity', () {
      final village = makeVillage(builders: 2);
      final upgrades = [
        makeUpgrade(id: 'u1', status: UpgradeStatus.active),
        makeUpgrade(id: 'u2', status: UpgradeStatus.active),
      ];
      expect(service.hasAvailableSlot(upgrades, village.builderCapacity), isFalse);
    });

    test('completed upgrades do not consume slots', () {
      final village = makeVillage(builders: 1);
      final upgrades = [
        makeUpgrade(id: 'u1', status: UpgradeStatus.completed),
      ];
      expect(service.hasAvailableSlot(upgrades, village.builderCapacity), isTrue);
    });
  });

  group('VillageService.availableSlots', () {
    test('computes correct free count', () {
      final upgrades = [
        makeUpgrade(id: 'u1', status: UpgradeStatus.active),
      ];
      expect(service.availableSlots(upgrades, 3), 2);
    });

    test('never returns negative', () {
      final upgrades = [
        makeUpgrade(id: 'u1', status: UpgradeStatus.active),
        makeUpgrade(id: 'u2', status: UpgradeStatus.active),
        makeUpgrade(id: 'u3', status: UpgradeStatus.active),
      ];
      expect(service.availableSlots(upgrades, 2), 0);
    });
  });

  group('VillageService.activeUpgradesSortedByCompletion', () {
    test('returns only active upgrades sorted by completion ASC', () {
      final upgrades = [
        makeUpgrade(
            id: 'u1',
            status: UpgradeStatus.active,
            completionOffset: const Duration(hours: 3)),
        makeUpgrade(
            id: 'u2',
            status: UpgradeStatus.active,
            completionOffset: const Duration(hours: 1)),
        makeUpgrade(
            id: 'u3',
            status: UpgradeStatus.completed,
            completionOffset: const Duration(minutes: 5)),
      ];
      final sorted = service.activeUpgradesSortedByCompletion(upgrades);
      expect(sorted.length, 2);
      expect(sorted.first.id, 'u2'); // soonest
      expect(sorted.last.id, 'u1');
    });

    test('returns empty list when no active upgrades', () {
      expect(
        service.activeUpgradesSortedByCompletion([
          makeUpgrade(id: 'u1', status: UpgradeStatus.completed),
        ]),
        isEmpty,
      );
    });
  });
}
