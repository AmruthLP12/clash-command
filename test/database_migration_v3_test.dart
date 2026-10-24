import 'package:clash_command/database/app_database.dart';
import 'package:clash_command/database/daos/custom_upgrade_suggestions_dao.dart';
import 'package:clash_command/database/daos/upgrades_dao.dart';
import 'package:clash_command/database/daos/villages_dao.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late VillagesDao villagesDao;
  late UpgradesDao upgradesDao;
  late CustomUpgradeSuggestionsDao suggestionsDao;

  final now = DateTime.utc(2026, 10, 23, 12, 0, 0);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    villagesDao = VillagesDao(db);
    upgradesDao = UpgradesDao(db);
    suggestionsDao = CustomUpgradeSuggestionsDao(db);

    // Create a test village
    await villagesDao.upsert(
      Village(
        id: 'v1',
        name: 'Main Village',
        townHallLevel: 18,
        builderCapacity: 6,
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Database Schema v3 & Upgrade Levels Persistence', () {
    test('schemaVersion is 3', () {
      expect(db.schemaVersion, 3);
    });

    test('persists upgrade with fromLevel and toLevel', () async {
      final upgrade = Upgrade(
        id: 'up-1',
        villageId: 'v1',
        name: 'Archer Tower',
        category: UpgradeCategory.homeBuilder,
        startedAtUtc: now,
        expectedCompletionAtUtc: now.add(const Duration(days: 3)),
        status: UpgradeStatus.active,
        fromLevel: 18,
        toLevel: 19,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      await upgradesDao.upsert(upgrade);

      final loaded = await upgradesDao.findById('up-1');
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Archer Tower');
      expect(loaded.fromLevel, 18);
      expect(loaded.toLevel, 19);
      expect(loaded.displayNameWithLevel, 'Archer Tower · Lv. 18 → 19');
    });

    test('persists upgrade with omitted level fields', () async {
      final upgrade = Upgrade(
        id: 'up-2',
        villageId: 'v1',
        name: 'Laboratory Research',
        category: UpgradeCategory.homeLab,
        startedAtUtc: now,
        expectedCompletionAtUtc: now.add(const Duration(hours: 12)),
        status: UpgradeStatus.active,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      await upgradesDao.upsert(upgrade);

      final loaded = await upgradesDao.findById('up-2');
      expect(loaded, isNotNull);
      expect(loaded!.fromLevel, isNull);
      expect(loaded.toLevel, isNull);
      expect(loaded.displayNameWithLevel, 'Laboratory Research');
    });

    test('updates fromLevel and toLevel upon editing', () async {
      final upgrade = Upgrade(
        id: 'up-3',
        villageId: 'v1',
        name: 'Cannon',
        category: UpgradeCategory.homeBuilder,
        startedAtUtc: now,
        expectedCompletionAtUtc: now.add(const Duration(days: 1)),
        status: UpgradeStatus.active,
        fromLevel: 14,
        toLevel: 15,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      await upgradesDao.upsert(upgrade);

      final edited = upgrade.copyWith(
        fromLevel: 15,
        toLevel: 16,
      );
      await upgradesDao.upsert(edited);

      final loaded = await upgradesDao.findById('up-3');
      expect(loaded!.fromLevel, 15);
      expect(loaded.toLevel, 16);
      expect(loaded.displayNameWithLevel, 'Cannon · Lv. 15 → 16');
    });
  });

  group('Custom Upgrade Suggestions DAO & Deduplication', () {
    test('saves custom suggestion and retrieves it for the category', () async {
      final added = await suggestionsDao.addSuggestion(
        'Super Crafted Tower',
        UpgradeCategory.homeBuilder,
      );
      expect(added, isTrue);

      final names = await suggestionsDao.getNamesForCategory(
        UpgradeCategory.homeBuilder,
      );
      expect(names.contains('Super Crafted Tower'), isTrue);
    });

    test('does not save built-in catalogue items as custom suggestions', () async {
      // "Archer Tower" already exists in built-in catalogue
      final added = await suggestionsDao.addSuggestion(
        'Archer Tower',
        UpgradeCategory.homeBuilder,
      );
      expect(added, isFalse);

      final names = await suggestionsDao.getNamesForCategory(
        UpgradeCategory.homeBuilder,
      );
      expect(names.contains('Archer Tower'), isFalse);
    });

    test('handles case-insensitivity and whitespace duplicates for custom names', () async {
      final first = await suggestionsDao.addSuggestion(
        'Custom Trap',
        UpgradeCategory.homeBuilder,
      );
      expect(first, isTrue);

      // Same name with different casing and whitespace
      final duplicate = await suggestionsDao.addSuggestion(
        '  custom trap  ',
        UpgradeCategory.homeBuilder,
      );
      expect(duplicate, isFalse);

      final names = await suggestionsDao.getNamesForCategory(
        UpgradeCategory.homeBuilder,
      );
      expect(names.where((n) => n.toLowerCase() == 'custom trap').length, 1);
    });

    test('isolates custom suggestions across different categories', () async {
      await suggestionsDao.addSuggestion(
        'Custom Spell',
        UpgradeCategory.homeLab,
      );

      final homeBuilderNames = await suggestionsDao.getNamesForCategory(
        UpgradeCategory.homeBuilder,
      );
      final homeLabNames = await suggestionsDao.getNamesForCategory(
        UpgradeCategory.homeLab,
      );

      expect(homeLabNames.contains('Custom Spell'), isTrue);
      expect(homeBuilderNames.contains('Custom Spell'), isFalse);
    });
  });
}
