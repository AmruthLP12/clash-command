import 'package:clash_command/domain/catalog/upgrade_catalog.dart';
import 'package:clash_command/domain/models/game_constants.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('1. Town Hall 18 and Future Town Hall Support', () {
    test('supports Town Hall 18 and is not limited to 17', () {
      expect(TownHallConstants.maxSupportedLevel, 18);
      expect(TownHallConstants.availableLevels.contains(18), isTrue);
      expect(TownHallConstants.availableLevels.last, 18);
      expect(TownHallConstants.availableLevels.length, 18);
      expect(TownHallConstants.isValidLevel(18), isTrue);
      expect(TownHallConstants.isValidLevel(17), isTrue);
      expect(TownHallConstants.isValidLevel(1), isTrue);
      expect(TownHallConstants.isValidLevel(0), isFalse);
      expect(TownHallConstants.isValidLevel(-1), isFalse);
    });

    test('future Town Hall levels can be validated without rewriting code', () {
      // Town Hall constant represents the single source of truth for max supported TH
      expect(TownHallConstants.minLevel, 1);
      final generatedLevels = List.generate(
        TownHallConstants.maxSupportedLevel - TownHallConstants.minLevel + 1,
        (i) => TownHallConstants.minLevel + i,
      );
      expect(TownHallConstants.availableLevels, generatedLevels);
    });
  });

  group('2. Four Required Upgrade Categories and Suggestion Isolation', () {
    test('provides all 4 distinct primary categories with proper terminology', () {
      expect(UpgradeCategory.primaryCategories.length, 4);
      expect(
        UpgradeCategory.homeBuilder.displayName,
        'Home Village — Builder',
      );
      expect(
        UpgradeCategory.homeLab.displayName,
        'Home Village — Laboratory',
      );
      expect(
        UpgradeCategory.builderBaseBuilder.displayName,
        'Builder Base — Builder',
      );
      expect(
        UpgradeCategory.builderBaseStarLab.displayName,
        'Builder Base — Star Laboratory',
      );
    });

    test('suggestions are strictly partitioned by facility and category', () {
      // Home Village Builder suggestions must contain buildings/defenses, but NEVER lab troops
      final homeBuilderItems = UpgradeCatalog.search(
        query: '',
        category: UpgradeCategory.homeBuilder,
      );
      expect(
        homeBuilderItems.any((i) => i.name == 'Archer Tower'),
        isTrue,
      );
      expect(
        homeBuilderItems.any((i) => i.name == 'Town Hall'),
        isTrue,
      );
      expect(
        homeBuilderItems.any((i) => i.name == 'P.E.K.K.A'),
        isFalse, // Troop belongs to Home Lab
      );
      expect(
        homeBuilderItems.any((i) => i.name == 'Raged Barbarian'),
        isFalse, // Belongs to Star Lab
      );

      // Home Village Laboratory suggestions must contain troops/spells, but NEVER Builder Base items
      final homeLabItems = UpgradeCatalog.search(
        query: '',
        category: UpgradeCategory.homeLab,
      );
      expect(homeLabItems.any((i) => i.name == 'P.E.K.K.A'), isTrue);
      expect(homeLabItems.any((i) => i.name == 'Lightning Spell'), isTrue);
      expect(homeLabItems.any((i) => i.name == 'Archer Tower'), isFalse);
      expect(homeLabItems.any((i) => i.name == 'Clock Tower'), isFalse);

      // Builder Base Builder must contain Builder Base buildings, but NEVER Home Village buildings
      final bbBuilderItems = UpgradeCatalog.search(
        query: '',
        category: UpgradeCategory.builderBaseBuilder,
      );
      expect(bbBuilderItems.any((i) => i.name == 'Builder Hall'), isTrue);
      expect(bbBuilderItems.any((i) => i.name == 'Roaster'), isTrue);
      expect(bbBuilderItems.any((i) => i.name == 'Eagle Artillery'), isFalse);

      // Builder Base Star Laboratory must contain Builder Base troops
      final starLabItems = UpgradeCatalog.search(
        query: '',
        category: UpgradeCategory.builderBaseStarLab,
      );
      expect(starLabItems.any((i) => i.name == 'Raged Barbarian'), isTrue);
      expect(starLabItems.any((i) => i.name == 'Sneaky Archer'), isTrue);
      expect(starLabItems.any((i) => i.name == 'Barbarian'), isFalse);
      expect(starLabItems.any((i) => i.name == 'Builder Hall'), isFalse);
    });
  });

  group('3. Autocomplete Search and Matching', () {
    test('matches names case-insensitively with partial matching', () {
      final resultsLower = UpgradeCatalog.search(
        query: 'arc',
        category: UpgradeCategory.homeBuilder,
      );
      expect(resultsLower.any((i) => i.name == 'Archer Tower'), isTrue);
      expect(resultsLower.any((i) => i.name == 'Multi-Archer Tower'), isTrue);

      final resultsUpper = UpgradeCatalog.search(
        query: 'ARC',
        category: UpgradeCategory.homeBuilder,
      );
      expect(resultsUpper.any((i) => i.name == 'Archer Tower'), isTrue);
    });

    test('prioritizes prefix matches over contains matches', () {
      final results = UpgradeCatalog.search(
        query: 'cannon',
        category: UpgradeCategory.homeBuilder,
      );
      // "Cannon" starts with "cannon", "Ricochet Cannon" only contains it
      expect(results.first.name, 'Cannon');
    });

    test('prioritizes items unlocked by current Town Hall level', () {
      final th9Results = UpgradeCatalog.search(
        query: '',
        category: UpgradeCategory.homeBuilder,
        townHallLevel: 9,
      );
      // Items with minTownHall <= 9 should appear before items requiring TH15+
      final cannonIdx = th9Results.indexWhere((i) => i.name == 'Cannon');
      final monolithIdx = th9Results.indexWhere((i) => i.name == 'Monolith');
      expect(cannonIdx, isNonNegative);
      expect(monolithIdx, isNonNegative);
      expect(cannonIdx, lessThan(monolithIdx));
    });
  });

  group('4. Custom Suggestions and Deduplication', () {
    test('includes custom suggestions in autocomplete search', () {
      final results = UpgradeCatalog.search(
        query: 'custom',
        category: UpgradeCategory.homeBuilder,
        customNames: ['Custom Wall Trap', 'Custom Defense'],
      );
      expect(results.any((i) => i.name == 'Custom Wall Trap'), isTrue);
      expect(results.any((i) => i.name == 'Custom Defense'), isTrue);
      expect(results.firstWhere((i) => i.name == 'Custom Defense').isCustom, isTrue);
    });

    test('deduplicates custom suggestions against built-in catalogue case-insensitively', () {
      final results = UpgradeCatalog.search(
        query: 'archer tower',
        category: UpgradeCategory.homeBuilder,
        customNames: ['Archer Tower', 'archer tower', '   ARCHER TOWER   '],
      );
      // Should only contain the single built-in Archer Tower
      final matches = results.where((i) => i.name.toLowerCase() == 'archer tower');
      expect(matches.length, 1);
      expect(matches.first.isCustom, isFalse);
    });
  });

  group('5. Optional From Level and To Level Fields', () {
    test('both fromLevel and toLevel can be omitted', () {
      final upgrade = Upgrade(
        id: 'u1',
        villageId: 'v1',
        name: 'Army Camp',
        category: UpgradeCategory.homeBuilder,
        startedAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
        expectedCompletionAtUtc: DateTime.utc(2026, 10, 24, 10, 0),
        status: UpgradeStatus.active,
        createdAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
        updatedAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
      );
      expect(upgrade.fromLevel, isNull);
      expect(upgrade.toLevel, isNull);
      expect(upgrade.displayNameWithLevel, 'Army Camp');
    });

    test('formats compact title when both fromLevel and toLevel are supplied', () {
      final upgrade = Upgrade(
        id: 'u2',
        villageId: 'v1',
        name: 'Archer Tower',
        category: UpgradeCategory.homeBuilder,
        startedAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
        expectedCompletionAtUtc: DateTime.utc(2026, 10, 24, 10, 0),
        status: UpgradeStatus.active,
        fromLevel: 18,
        toLevel: 19,
        createdAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
        updatedAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
      );
      expect(upgrade.displayNameWithLevel, 'Archer Tower · Lv. 18 → 19');
    });

    test('formats title appropriately when only toLevel is supplied', () {
      final upgrade = Upgrade(
        id: 'u3',
        villageId: 'v1',
        name: 'Town Hall',
        category: UpgradeCategory.homeBuilder,
        startedAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
        expectedCompletionAtUtc: DateTime.utc(2026, 10, 24, 10, 0),
        status: UpgradeStatus.active,
        toLevel: 18,
        createdAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
        updatedAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
      );
      expect(upgrade.displayNameWithLevel, 'Town Hall · Lv. 18');
    });

    test('formats title appropriately when only fromLevel is supplied', () {
      final upgrade = Upgrade(
        id: 'u4',
        villageId: 'v1',
        name: 'Cannon',
        category: UpgradeCategory.homeBuilder,
        startedAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
        expectedCompletionAtUtc: DateTime.utc(2026, 10, 24, 10, 0),
        status: UpgradeStatus.active,
        fromLevel: 14,
        createdAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
        updatedAtUtc: DateTime.utc(2026, 10, 23, 10, 0),
      );
      expect(upgrade.displayNameWithLevel, 'Cannon · From Lv. 14');
    });

    test('suggests next valid To Level from From Level', () {
      final item = UpgradeCatalog.find('Archer Tower', UpgradeCategory.homeBuilder);
      expect(item, isNotNull);
      expect(item!.suggestToLevel(18), 19);
      expect(item.suggestToLevel(null), 2);
    });
  });
}
