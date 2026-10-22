import 'package:clash_command/domain/models/history_event.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Village', () {
    final now = DateTime.utc(2026, 1, 1);
    final village = Village(
      id: 'v1',
      name: 'Main',
      townHallLevel: 15,
      builderCapacity: 5,
      sortOrder: 2,
      notes: 'Some notes',
      createdAtUtc: now,
      updatedAtUtc: now,
    );

    test('copyWith updates values and preserves others', () {
      final updated = village.copyWith(name: 'New Name', builderCapacity: 6);
      expect(updated.name, 'New Name');
      expect(updated.builderCapacity, 6);
      expect(updated.townHallLevel, 15);
      expect(updated.notes, 'Some notes');
    });

    test('copyWith clears optional fields when clear flags are set', () {
      final cleared = village.copyWith(
        clearTownHallLevel: true,
        clearSortOrder: true,
        clearNotes: true,
      );
      expect(cleared.townHallLevel, isNull);
      expect(cleared.sortOrder, isNull);
      expect(cleared.notes, isNull);
      expect(cleared.name, 'Main');
    });
  });

  group('Upgrade', () {
    final now = DateTime.utc(2026, 1, 1);
    final upgrade = Upgrade(
      id: 'u1',
      villageId: 'v1',
      name: 'Archer Queen',
      category: UpgradeCategory.hero,
      slotKey: 'Builder 1',
      catalogItemId: 'cat_aq',
      durationSeconds: 3600,
      notes: 'Upgrade to level 40',
      startedAtUtc: now,
      expectedCompletionAtUtc: now.add(const Duration(hours: 1)),
      status: UpgradeStatus.active,
      createdAtUtc: now,
      updatedAtUtc: now,
    );

    test('copyWith updates values and preserves others', () {
      final updated = upgrade.copyWith(name: 'Barbarian King');
      expect(updated.name, 'Barbarian King');
      expect(updated.category, UpgradeCategory.hero);
      expect(updated.slotKey, 'Builder 1');
    });

    test('copyWith clears optional fields when clear flags are set', () {
      final cleared = upgrade.copyWith(
        clearSlotKey: true,
        clearCatalogItemId: true,
        clearDurationSeconds: true,
        clearNotes: true,
      );
      expect(cleared.slotKey, isNull);
      expect(cleared.catalogItemId, isNull);
      expect(cleared.durationSeconds, isNull);
      expect(cleared.notes, isNull);
      expect(cleared.name, 'Archer Queen');
    });
  });

  group('HistoryEvent', () {
    test('fromString returns correct type', () {
      expect(
        HistoryEventType.fromString('upgradeStarted'),
        HistoryEventType.upgradeStarted,
      );
      expect(
        HistoryEventType.fromString('unknown'),
        HistoryEventType.upgradeEdited,
      );
    });

    test('displayName is non-empty for all types', () {
      for (final type in HistoryEventType.values) {
        expect(type.displayName, isNotEmpty);
      }
    });
  });

  group('UpgradeCategory', () {
    test('fromString returns correct category', () {
      expect(UpgradeCategory.fromString('building'), UpgradeCategory.building);
      expect(UpgradeCategory.fromString('hero'), UpgradeCategory.hero);
      expect(UpgradeCategory.fromString('defense'), UpgradeCategory.defense);
    });

    test('fromString returns other for unknown value', () {
      expect(UpgradeCategory.fromString('unknown'), UpgradeCategory.other);
    });

    test('displayName is non-empty for all categories', () {
      for (final category in UpgradeCategory.values) {
        expect(category.displayName, isNotEmpty);
      }
    });
  });

  group('UpgradeStatus', () {
    test('fromString returns correct status', () {
      expect(UpgradeStatus.fromString('active'), UpgradeStatus.active);
      expect(UpgradeStatus.fromString('completed'), UpgradeStatus.completed);
      expect(UpgradeStatus.fromString('cancelled'), UpgradeStatus.cancelled);
    });

    test('fromString returns active for unknown value', () {
      expect(UpgradeStatus.fromString('unknown'), UpgradeStatus.active);
    });
  });
}
