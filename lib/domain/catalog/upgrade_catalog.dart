import '../models/upgrade_category.dart';
import 'upgrade_catalog_item.dart';

/// Predefined local catalogue of Clash of Clans upgrades.
///
/// Kept completely offline and separate from user data so that updating
/// the built-in catalogue does not touch or delete user custom suggestions.
class UpgradeCatalog {
  const UpgradeCatalog._();

  /// All verified built-in catalogue items.
  static const List<UpgradeCatalogItem> builtInItems = [
    // -------------------------------------------------------------------------
    // HOME VILLAGE — BUILDER
    // -------------------------------------------------------------------------
    UpgradeCatalogItem(
      name: 'Town Hall',
      category: UpgradeCategory.homeBuilder,
      type: 'Core',
      minTownHall: 1,
      maxLevel: 18,
    ),
    UpgradeCatalogItem(
      name: 'Clan Castle',
      category: UpgradeCategory.homeBuilder,
      type: 'Army',
      minTownHall: 1,
      maxLevel: 12,
    ),
    UpgradeCatalogItem(
      name: 'Laboratory',
      category: UpgradeCategory.homeBuilder,
      type: 'Army',
      minTownHall: 1,
      maxLevel: 15,
    ),
    UpgradeCatalogItem(
      name: 'Army Camp',
      category: UpgradeCategory.homeBuilder,
      type: 'Army',
      minTownHall: 1,
      maxLevel: 13,
    ),
    UpgradeCatalogItem(
      name: 'Barracks',
      category: UpgradeCategory.homeBuilder,
      type: 'Army',
      minTownHall: 1,
      maxLevel: 17,
    ),
    UpgradeCatalogItem(
      name: 'Dark Barracks',
      category: UpgradeCategory.homeBuilder,
      type: 'Army',
      minTownHall: 7,
      maxLevel: 11,
    ),
    UpgradeCatalogItem(
      name: 'Spell Factory',
      category: UpgradeCategory.homeBuilder,
      type: 'Army',
      minTownHall: 5,
      maxLevel: 8,
    ),
    UpgradeCatalogItem(
      name: 'Dark Spell Factory',
      category: UpgradeCategory.homeBuilder,
      type: 'Army',
      minTownHall: 8,
      maxLevel: 6,
    ),
    UpgradeCatalogItem(
      name: 'Workshop',
      category: UpgradeCategory.homeBuilder,
      type: 'Army',
      minTownHall: 12,
      maxLevel: 7,
    ),
    UpgradeCatalogItem(
      name: 'Pet House',
      category: UpgradeCategory.homeBuilder,
      type: 'Army',
      minTownHall: 14,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Blacksmith',
      category: UpgradeCategory.homeBuilder,
      type: 'Army',
      minTownHall: 8,
      maxLevel: 9,
    ),
    UpgradeCatalogItem(
      name: 'Gold Mine',
      category: UpgradeCategory.homeBuilder,
      type: 'Resource',
      minTownHall: 1,
      maxLevel: 15,
    ),
    UpgradeCatalogItem(
      name: 'Elixir Collector',
      category: UpgradeCategory.homeBuilder,
      type: 'Resource',
      minTownHall: 1,
      maxLevel: 15,
    ),
    UpgradeCatalogItem(
      name: 'Dark Elixir Drill',
      category: UpgradeCategory.homeBuilder,
      type: 'Resource',
      minTownHall: 7,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Gold Storage',
      category: UpgradeCategory.homeBuilder,
      type: 'Resource',
      minTownHall: 1,
      maxLevel: 17,
    ),
    UpgradeCatalogItem(
      name: 'Elixir Storage',
      category: UpgradeCategory.homeBuilder,
      type: 'Resource',
      minTownHall: 1,
      maxLevel: 17,
    ),
    UpgradeCatalogItem(
      name: 'Dark Elixir Storage',
      category: UpgradeCategory.homeBuilder,
      type: 'Resource',
      minTownHall: 7,
      maxLevel: 11,
    ),
    UpgradeCatalogItem(
      name: 'Cannon',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 1,
      maxLevel: 21,
    ),
    UpgradeCatalogItem(
      name: 'Archer Tower',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 2,
      maxLevel: 21,
    ),
    UpgradeCatalogItem(
      name: 'Walls',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 2,
      maxLevel: 18,
    ),
    UpgradeCatalogItem(
      name: 'Mortar',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 3,
      maxLevel: 16,
    ),
    UpgradeCatalogItem(
      name: 'Air Defense',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 4,
      maxLevel: 14,
    ),
    UpgradeCatalogItem(
      name: 'Wizard Tower',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 5,
      maxLevel: 16,
    ),
    UpgradeCatalogItem(
      name: 'Air Sweeper',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 6,
      maxLevel: 7,
    ),
    UpgradeCatalogItem(
      name: 'Hidden Tesla',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 7,
      maxLevel: 14,
    ),
    UpgradeCatalogItem(
      name: 'Bomb Tower',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 8,
      maxLevel: 11,
    ),
    UpgradeCatalogItem(
      name: 'X-Bow',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 9,
      maxLevel: 12,
    ),
    UpgradeCatalogItem(
      name: 'Inferno Tower',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 10,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Eagle Artillery',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 11,
      maxLevel: 7,
    ),
    UpgradeCatalogItem(
      name: 'Scattershot',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 13,
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Monolith',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 15,
      maxLevel: 3,
    ),
    UpgradeCatalogItem(
      name: 'Spell Tower',
      category: UpgradeCategory.homeBuilder,
      type: 'Defense',
      minTownHall: 15,
      maxLevel: 4,
    ),
    UpgradeCatalogItem(
      name: 'Ricochet Cannon',
      category: UpgradeCategory.homeBuilder,
      type: 'Merged Defense',
      minTownHall: 16,
      maxLevel: 3,
    ),
    UpgradeCatalogItem(
      name: 'Multi-Archer Tower',
      category: UpgradeCategory.homeBuilder,
      type: 'Merged Defense',
      minTownHall: 16,
      maxLevel: 3,
    ),
    UpgradeCatalogItem(
      name: 'Barbarian King',
      category: UpgradeCategory.homeBuilder,
      type: 'Hero',
      minTownHall: 7,
      maxLevel: 95,
    ),
    UpgradeCatalogItem(
      name: 'Archer Queen',
      category: UpgradeCategory.homeBuilder,
      type: 'Hero',
      minTownHall: 9,
      maxLevel: 95,
    ),
    UpgradeCatalogItem(
      name: 'Grand Warden',
      category: UpgradeCategory.homeBuilder,
      type: 'Hero',
      minTownHall: 11,
      maxLevel: 70,
    ),
    UpgradeCatalogItem(
      name: 'Royal Champion',
      category: UpgradeCategory.homeBuilder,
      type: 'Hero',
      minTownHall: 13,
      maxLevel: 45,
    ),
    UpgradeCatalogItem(
      name: 'Minion Prince',
      category: UpgradeCategory.homeBuilder,
      type: 'Hero',
      minTownHall: 9,
      maxLevel: 40,
    ),
    UpgradeCatalogItem(
      name: 'Bomb',
      category: UpgradeCategory.homeBuilder,
      type: 'Trap',
      minTownHall: 1,
      maxLevel: 13,
    ),
    UpgradeCatalogItem(
      name: 'Spring Trap',
      category: UpgradeCategory.homeBuilder,
      type: 'Trap',
      minTownHall: 3,
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Giant Bomb',
      category: UpgradeCategory.homeBuilder,
      type: 'Trap',
      minTownHall: 6,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Air Bomb',
      category: UpgradeCategory.homeBuilder,
      type: 'Trap',
      minTownHall: 5,
      maxLevel: 12,
    ),
    UpgradeCatalogItem(
      name: 'Seeking Air Mine',
      category: UpgradeCategory.homeBuilder,
      type: 'Trap',
      minTownHall: 7,
      maxLevel: 6,
    ),
    UpgradeCatalogItem(
      name: 'Skeleton Trap',
      category: UpgradeCategory.homeBuilder,
      type: 'Trap',
      minTownHall: 8,
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Tornado Trap',
      category: UpgradeCategory.homeBuilder,
      type: 'Trap',
      minTownHall: 11,
      maxLevel: 3,
    ),

    // -------------------------------------------------------------------------
    // HOME VILLAGE — LABORATORY
    // -------------------------------------------------------------------------
    UpgradeCatalogItem(
      name: 'Barbarian',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 12,
    ),
    UpgradeCatalogItem(
      name: 'Archer',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 12,
    ),
    UpgradeCatalogItem(
      name: 'Giant',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 12,
    ),
    UpgradeCatalogItem(
      name: 'Goblin',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 9,
    ),
    UpgradeCatalogItem(
      name: 'Wall Breaker',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 12,
    ),
    UpgradeCatalogItem(
      name: 'Balloon',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 11,
    ),
    UpgradeCatalogItem(
      name: 'Wizard',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 12,
    ),
    UpgradeCatalogItem(
      name: 'Healer',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 9,
    ),
    UpgradeCatalogItem(
      name: 'Dragon',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 11,
    ),
    UpgradeCatalogItem(
      name: 'P.E.K.K.A',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 11,
    ),
    UpgradeCatalogItem(
      name: 'Baby Dragon',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Miner',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Electro Dragon',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 7,
    ),
    UpgradeCatalogItem(
      name: 'Yeti',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 6,
    ),
    UpgradeCatalogItem(
      name: 'Dragon Rider',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 4,
    ),
    UpgradeCatalogItem(
      name: 'Electro Titan',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 4,
    ),
    UpgradeCatalogItem(
      name: 'Root Rider',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 3,
    ),
    UpgradeCatalogItem(
      name: 'Thrower',
      category: UpgradeCategory.homeLab,
      type: 'Troop',
      maxLevel: 2,
    ),
    UpgradeCatalogItem(
      name: 'Minion',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 12,
    ),
    UpgradeCatalogItem(
      name: 'Hog Rider',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 13,
    ),
    UpgradeCatalogItem(
      name: 'Valkyrie',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 11,
    ),
    UpgradeCatalogItem(
      name: 'Golem',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 13,
    ),
    UpgradeCatalogItem(
      name: 'Witch',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 7,
    ),
    UpgradeCatalogItem(
      name: 'Lava Hound',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 7,
    ),
    UpgradeCatalogItem(
      name: 'Bowler',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 8,
    ),
    UpgradeCatalogItem(
      name: 'Ice Golem',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 7,
    ),
    UpgradeCatalogItem(
      name: 'Headhunter',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 3,
    ),
    UpgradeCatalogItem(
      name: 'Apprentice Warden',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 4,
    ),
    UpgradeCatalogItem(
      name: 'Druid',
      category: UpgradeCategory.homeLab,
      type: 'Dark Troop',
      maxLevel: 3,
    ),
    UpgradeCatalogItem(
      name: 'Lightning Spell',
      category: UpgradeCategory.homeLab,
      type: 'Spell',
      maxLevel: 11,
    ),
    UpgradeCatalogItem(
      name: 'Healing Spell',
      category: UpgradeCategory.homeLab,
      type: 'Spell',
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Rage Spell',
      category: UpgradeCategory.homeLab,
      type: 'Spell',
      maxLevel: 6,
    ),
    UpgradeCatalogItem(
      name: 'Jump Spell',
      category: UpgradeCategory.homeLab,
      type: 'Spell',
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Freeze Spell',
      category: UpgradeCategory.homeLab,
      type: 'Spell',
      maxLevel: 7,
    ),
    UpgradeCatalogItem(
      name: 'Clone Spell',
      category: UpgradeCategory.homeLab,
      type: 'Spell',
      maxLevel: 8,
    ),
    UpgradeCatalogItem(
      name: 'Invisibility Spell',
      category: UpgradeCategory.homeLab,
      type: 'Spell',
      maxLevel: 4,
    ),
    UpgradeCatalogItem(
      name: 'Recall Spell',
      category: UpgradeCategory.homeLab,
      type: 'Spell',
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Revive Spell',
      category: UpgradeCategory.homeLab,
      type: 'Spell',
      maxLevel: 2,
    ),
    UpgradeCatalogItem(
      name: 'Poison Spell',
      category: UpgradeCategory.homeLab,
      type: 'Dark Spell',
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Earthquake Spell',
      category: UpgradeCategory.homeLab,
      type: 'Dark Spell',
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Haste Spell',
      category: UpgradeCategory.homeLab,
      type: 'Dark Spell',
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Skeleton Spell',
      category: UpgradeCategory.homeLab,
      type: 'Dark Spell',
      maxLevel: 8,
    ),
    UpgradeCatalogItem(
      name: 'Bat Spell',
      category: UpgradeCategory.homeLab,
      type: 'Dark Spell',
      maxLevel: 6,
    ),
    UpgradeCatalogItem(
      name: 'Overgrowth Spell',
      category: UpgradeCategory.homeLab,
      type: 'Dark Spell',
      maxLevel: 4,
    ),
    UpgradeCatalogItem(
      name: 'Wall Wrecker',
      category: UpgradeCategory.homeLab,
      type: 'Siege Machine',
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Battle Blimp',
      category: UpgradeCategory.homeLab,
      type: 'Siege Machine',
      maxLevel: 4,
    ),
    UpgradeCatalogItem(
      name: 'Stone Slammer',
      category: UpgradeCategory.homeLab,
      type: 'Siege Machine',
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Siege Barracks',
      category: UpgradeCategory.homeLab,
      type: 'Siege Machine',
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Log Launcher',
      category: UpgradeCategory.homeLab,
      type: 'Siege Machine',
      maxLevel: 4,
    ),
    UpgradeCatalogItem(
      name: 'Flame Flinger',
      category: UpgradeCategory.homeLab,
      type: 'Siege Machine',
      maxLevel: 4,
    ),
    UpgradeCatalogItem(
      name: 'Battle Drill',
      category: UpgradeCategory.homeLab,
      type: 'Siege Machine',
      maxLevel: 4,
    ),

    // -------------------------------------------------------------------------
    // BUILDER BASE — BUILDER
    // -------------------------------------------------------------------------
    UpgradeCatalogItem(
      name: 'Builder Hall',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Core',
      minBuilderHall: 1,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Builder Barracks',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Army',
      minBuilderHall: 2,
      maxLevel: 12,
    ),
    UpgradeCatalogItem(
      name: 'Star Laboratory',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Army',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Gem Mine',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Resource',
      minBuilderHall: 3,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Clock Tower',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Army',
      minBuilderHall: 4,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Healing Hut',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Army',
      minBuilderHall: 6,
      maxLevel: 6,
    ),
    UpgradeCatalogItem(
      name: 'Gold Mine',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Resource',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Elixir Collector',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Resource',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Gold Storage',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Resource',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Elixir Storage',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Resource',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Cannon',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Double Cannon',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Archer Tower',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Hidden Tesla',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 3,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Firecrackers',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 3,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Crusher',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 3,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Guard Post',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 4,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Air Bombs',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 4,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Multi Mortar',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 5,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Roaster',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 6,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Giant Cannon',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 7,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Mega Tesla',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 8,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Lava Launcher',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 9,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'X-Bow',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 10,
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Battle Machine',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Hero',
      minBuilderHall: 5,
      maxLevel: 35,
    ),
    UpgradeCatalogItem(
      name: 'Battle Copter',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Hero',
      minBuilderHall: 8,
      maxLevel: 35,
    ),
    UpgradeCatalogItem(
      name: 'Walls',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Defense',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Push Trap',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Trap',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Spring Trap',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Trap',
      minBuilderHall: 3,
      maxLevel: 5,
    ),
    UpgradeCatalogItem(
      name: 'Mine',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Trap',
      minBuilderHall: 2,
      maxLevel: 10,
    ),
    UpgradeCatalogItem(
      name: 'Mega Mine',
      category: UpgradeCategory.builderBaseBuilder,
      type: 'Trap',
      minBuilderHall: 4,
      maxLevel: 10,
    ),

    // -------------------------------------------------------------------------
    // BUILDER BASE — STAR LABORATORY
    // -------------------------------------------------------------------------
    UpgradeCatalogItem(
      name: 'Raged Barbarian',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Sneaky Archer',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Boxer Giant',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Beta Minion',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Bomber',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Baby Dragon',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Cannon Cart',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Night Witch',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Drop Ship',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Power P.E.K.K.A',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Hog Glider',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
    UpgradeCatalogItem(
      name: 'Electrofire Wizard',
      category: UpgradeCategory.builderBaseStarLab,
      type: 'Troop',
      maxLevel: 20,
    ),
  ];

  /// Finds a built-in catalog item by exact case-insensitive name and category.
  static UpgradeCatalogItem? find(String name, UpgradeCategory category) {
    final clean = name.trim().toLowerCase();
    final prim = category.primaryCategory;
    final items = _categoryCache[prim] ?? const [];
    for (final item in items) {
      if (item.name.toLowerCase() == clean) {
        return item;
      }
    }
    return null;
  }

  /// Pre-indexed category cache to eliminate search latency and repeated full-list scans.
  static final Map<UpgradeCategory, List<UpgradeCatalogItem>> _categoryCache = () {
    final map = <UpgradeCategory, List<UpgradeCatalogItem>>{};
    for (final cat in UpgradeCategory.primaryCategories) {
      map[cat] = builtInItems
          .where((item) => item.category == cat)
          .toList(growable: false);
    }
    return map;
  }();

  static final Map<UpgradeCategory, Set<String>> _categoryLowerNamesCache = () {
    final map = <UpgradeCategory, Set<String>>{};
    for (final entry in _categoryCache.entries) {
      map[entry.key] =
          entry.value.map((e) => e.name.toLowerCase()).toSet();
    }
    return map;
  }();

  /// Searches and prioritizes suggestions for the given query, category, and village context.
  ///
  /// - Case-insensitive partial matching.
  /// - Strict category separation (e.g. Home Lab never shows Builder Base buildings).
  /// - Prioritizes prefix matches over contains matches.
  /// - If [townHallLevel] is provided, items unlockable at or below this level are prioritized.
  /// - Merges custom user suggestions (deduplicated against built-in items).
  static List<UpgradeCatalogItem> search({
    required String query,
    required UpgradeCategory category,
    int? townHallLevel,
    List<String> customNames = const [],
  }) {
    final cleanQuery = query.trim().toLowerCase();
    final targetCategory = category.primaryCategory;

    // 1. Retrieve pre-indexed items for this specific primary category (O(1))
    final categoryItems = _categoryCache[targetCategory] ?? const [];
    final builtInLowerNames =
        _categoryLowerNamesCache[targetCategory] ?? const {};
    final customItems = <UpgradeCatalogItem>[];

    for (final customName in customNames) {
      final trimmed = customName.trim();
      if (trimmed.isEmpty) continue;
      final lower = trimmed.toLowerCase();
      if (!builtInLowerNames.contains(lower)) {
        customItems.add(
          UpgradeCatalogItem(
            name: trimmed,
            category: targetCategory,
            type: 'Custom',
            isCustom: true,
          ),
        );
      }
    }

    final allItems = [...categoryItems, ...customItems];

    if (cleanQuery.isEmpty) {
      // Return top items prioritized by Town Hall if available
      allItems.sort((a, b) {
        if (townHallLevel != null) {
          final aTh = a.minTownHall ?? 1;
          final bTh = b.minTownHall ?? 1;
          final aMatch = aTh <= townHallLevel ? 0 : 1;
          final bMatch = bTh <= townHallLevel ? 0 : 1;
          if (aMatch != bMatch) return aMatch.compareTo(bMatch);
        }
        return a.name.compareTo(b.name);
      });
      return allItems;
    }

    // Filter matching items
    final matching = allItems.where((item) {
      return item.name.toLowerCase().contains(cleanQuery);
    }).toList();

    // Sort with strategic ranking:
    // 1. Exact match
    // 2. Starts with query
    // 3. Unlocked by current Town Hall
    // 4. Alphabetical
    matching.sort((a, b) {
      final aLower = a.name.toLowerCase();
      final bLower = b.name.toLowerCase();

      final aExact = aLower == cleanQuery;
      final bExact = bLower == cleanQuery;
      if (aExact != bExact) return aExact ? -1 : 1;

      final aPrefix = aLower.startsWith(cleanQuery);
      final bPrefix = bLower.startsWith(cleanQuery);
      if (aPrefix != bPrefix) return aPrefix ? -1 : 1;

      if (townHallLevel != null) {
        final aTh = a.minTownHall ?? 1;
        final bTh = b.minTownHall ?? 1;
        final aUnlocked = aTh <= townHallLevel;
        final bUnlocked = bTh <= townHallLevel;
        if (aUnlocked != bUnlocked) return aUnlocked ? -1 : 1;
      }

      return a.name.compareTo(b.name);
    });

    return matching;
  }
}

