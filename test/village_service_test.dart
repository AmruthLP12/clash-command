import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/services/village_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VillageService', () {
    final service = VillageService();
    final now = DateTime.utc(2026, 10, 19, 12, 0, 0);

    test('counts only active upgrades and finds the next completion', () {
      final village = Village(
        id: 'village-1',
        name: 'North Village',
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      final upgrades = [
        Upgrade(
          id: 'upgrade-1',
          villageId: village.id,
          name: 'Laboratory',
          category: 'building',
          startedAtUtc: now.subtract(const Duration(hours: 1)),
          expectedCompletionAtUtc: now.add(const Duration(hours: 2)),
          status: UpgradeStatus.active,
        ),
        Upgrade(
          id: 'upgrade-2',
          villageId: village.id,
          name: 'Barracks',
          category: 'building',
          startedAtUtc: now.subtract(const Duration(hours: 3)),
          expectedCompletionAtUtc: now.add(const Duration(minutes: 45)),
          status: UpgradeStatus.active,
        ),
        Upgrade(
          id: 'upgrade-3',
          villageId: village.id,
          name: 'Wall',
          category: 'defense',
          startedAtUtc: now.subtract(const Duration(days: 1)),
          expectedCompletionAtUtc: now.subtract(const Duration(minutes: 15)),
          status: UpgradeStatus.completed,
          completedAtUtc: now.subtract(const Duration(minutes: 15)),
        ),
      ];

      expect(service.activeUpgradeCount(upgrades), 2);
      expect(
        service.nextCompletionAtUtc(upgrades),
        now.add(const Duration(minutes: 45)),
      );
    });
  });
}
