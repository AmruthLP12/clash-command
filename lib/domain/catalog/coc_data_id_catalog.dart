import 'package:clash_command/domain/models/level_item_type.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village_realm.dart';

/// Descriptor for a Clash of Clans game item identified by its numeric `data` ID.
class CocItemMapping {
  const CocItemMapping({
    required this.dataId,
    required this.name,
    required this.category,
    required this.itemType,
    required this.realm,
    this.maxLevel,
    this.isWall = false,
  });

  final int dataId;
  final String name;
  final UpgradeCategory category;
  final String itemType;
  final VillageRealm realm;
  final int? maxLevel;
  final bool isWall;
}

/// Maintainable game-data catalogue mapping numeric `data` IDs to verified
/// Clash of Clans item names, upgrade categories, and item types.
class CocDataIdCatalog {
  const CocDataIdCatalog._();

  static final Map<int, CocItemMapping> _mappings = {
    // -------------------------------------------------------------------------
    // HOME VILLAGE BUILDINGS & DEFENCES (1000000 series)
    // -------------------------------------------------------------------------
    1000000: const CocItemMapping(
      dataId: 1000000,
      name: 'Town Hall',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 18,
    ),
    1000001: const CocItemMapping(
      dataId: 1000001,
      name: 'Clan Castle',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 12,
    ),
    1000002: const CocItemMapping(
      dataId: 1000002,
      name: 'Barracks',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 17,
    ),
    1000003: const CocItemMapping(
      dataId: 1000003,
      name: 'Laboratory',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 15,
    ),
    1000004: const CocItemMapping(
      dataId: 1000004,
      name: 'Cannon',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 21,
    ),
    1000005: const CocItemMapping(
      dataId: 1000005,
      name: 'Archer Tower',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 21,
    ),
    1000006: const CocItemMapping(
      dataId: 1000006,
      name: 'Elixir Collector',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 16,
    ),
    1000007: const CocItemMapping(
      dataId: 1000007,
      name: 'Elixir Storage',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 17,
    ),
    1000008: const CocItemMapping(
      dataId: 1000008,
      name: 'Gold Mine',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 16,
    ),
    1000009: const CocItemMapping(
      dataId: 1000009,
      name: 'Gold Storage',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 17,
    ),
    1000010: const CocItemMapping(
      dataId: 1000010,
      name: 'Wall',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 18,
      isWall: true,
    ),
    1000011: const CocItemMapping(
      dataId: 1000011,
      name: 'Wizard Tower',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 16,
    ),
    1000012: const CocItemMapping(
      dataId: 1000012,
      name: 'Air Defense',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 14,
    ),
    1000013: const CocItemMapping(
      dataId: 1000013,
      name: 'Mortar',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 16,
    ),
    1000014: const CocItemMapping(
      dataId: 1000014,
      name: 'Air Sweeper',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 7,
    ),
    1000015: const CocItemMapping(
      dataId: 1000015,
      name: 'Hidden Tesla',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 15,
    ),
    1000016: const CocItemMapping(
      dataId: 1000016,
      name: 'Bomb Tower',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 11,
    ),
    1000017: const CocItemMapping(
      dataId: 1000017,
      name: 'X-Bow',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 12,
    ),
    1000018: const CocItemMapping(
      dataId: 1000018,
      name: 'Inferno Tower',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 11,
    ),
    1000019: const CocItemMapping(
      dataId: 1000019,
      name: 'Eagle Artillery',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 7,
    ),
    1000020: const CocItemMapping(
      dataId: 1000020,
      name: 'Scattershot',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 5,
    ),
    1000021: const CocItemMapping(
      dataId: 1000021,
      name: 'Spell Tower',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),
    1000022: const CocItemMapping(
      dataId: 1000022,
      name: 'Monolith',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 3,
    ),
    1000023: const CocItemMapping(
      dataId: 1000023,
      name: 'Multi-Archer Tower',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 3,
    ),
    1000024: const CocItemMapping(
      dataId: 1000024,
      name: 'Ricochet Cannon',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.homeVillage,
      maxLevel: 3,
    ),
    1000025: const CocItemMapping(
      dataId: 1000025,
      name: 'Army Camp',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 13,
    ),
    1000026: const CocItemMapping(
      dataId: 1000026,
      name: 'Dark Barracks',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 11,
    ),
    1000027: const CocItemMapping(
      dataId: 1000027,
      name: 'Dark Elixir Drill',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    1000028: const CocItemMapping(
      dataId: 1000028,
      name: 'Dark Elixir Storage',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 11,
    ),
    1000029: const CocItemMapping(
      dataId: 1000029,
      name: 'Dark Spell Factory',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 6,
    ),
    1000030: const CocItemMapping(
      dataId: 1000030,
      name: 'Spell Factory',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 8,
    ),
    1000031: const CocItemMapping(
      dataId: 1000031,
      name: 'Workshop',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 8,
    ),
    1000032: const CocItemMapping(
      dataId: 1000032,
      name: 'Pet House',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 9,
    ),
    1000033: const CocItemMapping(
      dataId: 1000033,
      name: 'Blacksmith',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 9,
    ),
    1000034: const CocItemMapping(
      dataId: 1000034,
      name: 'Hero Hall',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.homeVillage,
      maxLevel: 2,
    ),

    // -------------------------------------------------------------------------
    // HOME VILLAGE TRAPS (1200000 series)
    // -------------------------------------------------------------------------
    1200000: const CocItemMapping(
      dataId: 1200000,
      name: 'Bomb',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.homeVillage,
      maxLevel: 13,
    ),
    1200001: const CocItemMapping(
      dataId: 1200001,
      name: 'Spring Trap',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.homeVillage,
      maxLevel: 6,
    ),
    1200002: const CocItemMapping(
      dataId: 1200002,
      name: 'Air Bomb',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.homeVillage,
      maxLevel: 12,
    ),
    1200003: const CocItemMapping(
      dataId: 1200003,
      name: 'Giant Bomb',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    1200004: const CocItemMapping(
      dataId: 1200004,
      name: 'Seeking Air Mine',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.homeVillage,
      maxLevel: 6,
    ),
    1200005: const CocItemMapping(
      dataId: 1200005,
      name: 'Skeleton Trap',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.homeVillage,
      maxLevel: 5,
    ),
    1200006: const CocItemMapping(
      dataId: 1200006,
      name: 'Tornado Trap',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.homeVillage,
      maxLevel: 3,
    ),

    // -------------------------------------------------------------------------
    // HOME VILLAGE TROOPS (4000000 series)
    // -------------------------------------------------------------------------
    4000000: const CocItemMapping(
      dataId: 4000000,
      name: 'Barbarian',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 12,
    ),
    4000001: const CocItemMapping(
      dataId: 4000001,
      name: 'Archer',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 12,
    ),
    4000002: const CocItemMapping(
      dataId: 4000002,
      name: 'Goblin',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    4000003: const CocItemMapping(
      dataId: 4000003,
      name: 'Giant',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 12,
    ),
    4000004: const CocItemMapping(
      dataId: 4000004,
      name: 'Wall Breaker',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 12,
    ),
    4000005: const CocItemMapping(
      dataId: 4000005,
      name: 'Balloon',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 11,
    ),
    4000006: const CocItemMapping(
      dataId: 4000006,
      name: 'Wizard',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 12,
    ),
    4000007: const CocItemMapping(
      dataId: 4000007,
      name: 'Healer',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 9,
    ),
    4000008: const CocItemMapping(
      dataId: 4000008,
      name: 'Dragon',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 11,
    ),
    4000009: const CocItemMapping(
      dataId: 4000009,
      name: 'P.E.K.K.A',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 11,
    ),
    4000010: const CocItemMapping(
      dataId: 4000010,
      name: 'Minion',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 12,
    ),
    4000011: const CocItemMapping(
      dataId: 4000011,
      name: 'Hog Rider',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 13,
    ),
    4000012: const CocItemMapping(
      dataId: 4000012,
      name: 'Valkyrie',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 11,
    ),
    4000013: const CocItemMapping(
      dataId: 4000013,
      name: 'Golem',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 13,
    ),
    4000014: const CocItemMapping(
      dataId: 4000014,
      name: 'Witch',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 7,
    ),
    4000015: const CocItemMapping(
      dataId: 4000015,
      name: 'Lava Hound',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 7,
    ),
    4000016: const CocItemMapping(
      dataId: 4000016,
      name: 'Bowler',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 8,
    ),
    4000017: const CocItemMapping(
      dataId: 4000017,
      name: 'Baby Dragon',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    4000018: const CocItemMapping(
      dataId: 4000018,
      name: 'Miner',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    4000021: const CocItemMapping(
      dataId: 4000021,
      name: 'Electro Dragon',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 7,
    ),
    4000022: const CocItemMapping(
      dataId: 4000022,
      name: 'Yeti',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 6,
    ),
    4000023: const CocItemMapping(
      dataId: 4000023,
      name: 'Ice Golem',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 8,
    ),
    4000024: const CocItemMapping(
      dataId: 4000024,
      name: 'Headhunter',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 3,
    ),
    4000025: const CocItemMapping(
      dataId: 4000025,
      name: 'Dragon Rider',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),
    4000026: const CocItemMapping(
      dataId: 4000026,
      name: 'Electro Titan',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),
    4000027: const CocItemMapping(
      dataId: 4000027,
      name: 'Root Rider',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 3,
    ),
    4000028: const CocItemMapping(
      dataId: 4000028,
      name: 'Apprentice Warden',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),
    4000029: const CocItemMapping(
      dataId: 4000029,
      name: 'Druid',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),

    // -------------------------------------------------------------------------
    // SIEGE MACHINES (4000050 series)
    // -------------------------------------------------------------------------
    4000051: const CocItemMapping(
      dataId: 4000051,
      name: 'Wall Wrecker',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.siegeMachines,
      realm: VillageRealm.homeVillage,
      maxLevel: 5,
    ),
    4000052: const CocItemMapping(
      dataId: 4000052,
      name: 'Battle Blimp',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.siegeMachines,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),
    4000053: const CocItemMapping(
      dataId: 4000053,
      name: 'Stone Slammer',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.siegeMachines,
      realm: VillageRealm.homeVillage,
      maxLevel: 5,
    ),
    4000054: const CocItemMapping(
      dataId: 4000054,
      name: 'Siege Barracks',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.siegeMachines,
      realm: VillageRealm.homeVillage,
      maxLevel: 5,
    ),
    4000055: const CocItemMapping(
      dataId: 4000055,
      name: 'Log Launcher',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.siegeMachines,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),
    4000056: const CocItemMapping(
      dataId: 4000056,
      name: 'Flame Flinger',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.siegeMachines,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),
    4000057: const CocItemMapping(
      dataId: 4000057,
      name: 'Battle Drill',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.siegeMachines,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),

    // -------------------------------------------------------------------------
    // SPELLS (26000000 series & 2600000 series)
    // -------------------------------------------------------------------------
    26000000: const CocItemMapping(
      dataId: 26000000,
      name: 'Lightning Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 11,
    ),
    26000001: const CocItemMapping(
      dataId: 26000001,
      name: 'Healing Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 9,
    ),
    26000002: const CocItemMapping(
      dataId: 26000002,
      name: 'Rage Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 6,
    ),
    26000003: const CocItemMapping(
      dataId: 26000003,
      name: 'Jump Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 5,
    ),
    26000004: const CocItemMapping(
      dataId: 26000004,
      name: 'Freeze Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 7,
    ),
    26000005: const CocItemMapping(
      dataId: 26000005,
      name: 'Poison Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    26000006: const CocItemMapping(
      dataId: 26000006,
      name: 'Earthquake Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 5,
    ),
    26000007: const CocItemMapping(
      dataId: 26000007,
      name: 'Haste Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 5,
    ),
    26000008: const CocItemMapping(
      dataId: 26000008,
      name: 'Clone Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 8,
    ),
    26000009: const CocItemMapping(
      dataId: 26000009,
      name: 'Skeleton Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 8,
    ),
    26000010: const CocItemMapping(
      dataId: 26000010,
      name: 'Bat Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 6,
    ),
    26000011: const CocItemMapping(
      dataId: 26000011,
      name: 'Invisibility Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),
    26000012: const CocItemMapping(
      dataId: 26000012,
      name: 'Recall Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),
    26000013: const CocItemMapping(
      dataId: 26000013,
      name: 'Overgrowth Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 4,
    ),
    26000014: const CocItemMapping(
      dataId: 26000014,
      name: 'Revive Spell',
      category: UpgradeCategory.homeLab,
      itemType: LevelItemType.spells,
      realm: VillageRealm.homeVillage,
      maxLevel: 3,
    ),

    // -------------------------------------------------------------------------
    // HEROES (28000000 series)
    // -------------------------------------------------------------------------
    28000000: const CocItemMapping(
      dataId: 28000000,
      name: 'Barbarian King',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroes,
      realm: VillageRealm.homeVillage,
      maxLevel: 95,
    ),
    28000001: const CocItemMapping(
      dataId: 28000001,
      name: 'Archer Queen',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroes,
      realm: VillageRealm.homeVillage,
      maxLevel: 95,
    ),
    28000002: const CocItemMapping(
      dataId: 28000002,
      name: 'Grand Warden',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroes,
      realm: VillageRealm.homeVillage,
      maxLevel: 70,
    ),
    28000003: const CocItemMapping(
      dataId: 28000003,
      name: 'Royal Champion',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroes,
      realm: VillageRealm.homeVillage,
      maxLevel: 45,
    ),
    28000004: const CocItemMapping(
      dataId: 28000004,
      name: 'Minion Prince',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroes,
      realm: VillageRealm.homeVillage,
      maxLevel: 80,
    ),

    // -------------------------------------------------------------------------
    // HERO PETS (73000000 series)
    // -------------------------------------------------------------------------
    73000000: const CocItemMapping(
      dataId: 73000000,
      name: 'L.A.S.S.I',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroPets,
      realm: VillageRealm.homeVillage,
      maxLevel: 15,
    ),
    73000001: const CocItemMapping(
      dataId: 73000001,
      name: 'Electro Owl',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroPets,
      realm: VillageRealm.homeVillage,
      maxLevel: 15,
    ),
    73000002: const CocItemMapping(
      dataId: 73000002,
      name: 'Mighty Yak',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroPets,
      realm: VillageRealm.homeVillage,
      maxLevel: 15,
    ),
    73000003: const CocItemMapping(
      dataId: 73000003,
      name: 'Unicorn',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroPets,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    73000004: const CocItemMapping(
      dataId: 73000004,
      name: 'Frosty',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroPets,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    73000005: const CocItemMapping(
      dataId: 73000005,
      name: 'Diggy',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroPets,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    73000006: const CocItemMapping(
      dataId: 73000006,
      name: 'Poison Lizard',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroPets,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    73000007: const CocItemMapping(
      dataId: 73000007,
      name: 'Phoenix',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroPets,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    73000008: const CocItemMapping(
      dataId: 73000008,
      name: 'Spirit Fox',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroPets,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),
    73000009: const CocItemMapping(
      dataId: 73000009,
      name: 'Angry Jelly',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.heroPets,
      realm: VillageRealm.homeVillage,
      maxLevel: 10,
    ),

    // -------------------------------------------------------------------------
    // HERO EQUIPMENT (88000000 series)
    // -------------------------------------------------------------------------
    88000000: const CocItemMapping(
      dataId: 88000000,
      name: 'Barbarian Puppet',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 18,
    ),
    88000001: const CocItemMapping(
      dataId: 88000001,
      name: 'Rage Vial',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 18,
    ),
    88000002: const CocItemMapping(
      dataId: 88000002,
      name: 'Archer Puppet',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 18,
    ),
    88000003: const CocItemMapping(
      dataId: 88000003,
      name: 'Invisibility Vial',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 18,
    ),
    88000004: const CocItemMapping(
      dataId: 88000004,
      name: 'Eternal Tome',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 18,
    ),
    88000005: const CocItemMapping(
      dataId: 88000005,
      name: 'Life Gem',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 18,
    ),
    88000006: const CocItemMapping(
      dataId: 88000006,
      name: 'Seeking Shield',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 18,
    ),
    88000007: const CocItemMapping(
      dataId: 88000007,
      name: 'Royal Gem',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 18,
    ),
    88000008: const CocItemMapping(
      dataId: 88000008,
      name: 'Giant Gauntlet',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 27,
    ),
    88000009: const CocItemMapping(
      dataId: 88000009,
      name: 'Frozen Arrow',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 27,
    ),
    88000010: const CocItemMapping(
      dataId: 88000010,
      name: 'Fireball',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 27,
    ),
    88000011: const CocItemMapping(
      dataId: 88000011,
      name: 'Spiky Ball',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 27,
    ),
    88000012: const CocItemMapping(
      dataId: 88000012,
      name: 'Rocket Spears',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 27,
    ),
    88000013: const CocItemMapping(
      dataId: 88000013,
      name: 'Magic Mirror',
      category: UpgradeCategory.homeBuilder,
      itemType: LevelItemType.other,
      realm: VillageRealm.homeVillage,
      maxLevel: 27,
    ),

    // -------------------------------------------------------------------------
    // BUILDER BASE BUILDINGS (1000050 series / buildings2)
    // -------------------------------------------------------------------------
    1000050: const CocItemMapping(
      dataId: 1000050,
      name: 'Builder Hall',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000051: const CocItemMapping(
      dataId: 1000051,
      name: 'Builder Hall',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000052: const CocItemMapping(
      dataId: 1000052,
      name: 'Crusher',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000053: const CocItemMapping(
      dataId: 1000053,
      name: 'Double Cannon',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000054: const CocItemMapping(
      dataId: 1000054,
      name: 'Archer Tower',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000055: const CocItemMapping(
      dataId: 1000055,
      name: 'Hidden Tesla',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000056: const CocItemMapping(
      dataId: 1000056,
      name: 'Firecrackers',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000057: const CocItemMapping(
      dataId: 1000057,
      name: 'Multi Mortar',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000058: const CocItemMapping(
      dataId: 1000058,
      name: 'Roaster',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000059: const CocItemMapping(
      dataId: 1000059,
      name: 'Giant Cannon',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000060: const CocItemMapping(
      dataId: 1000060,
      name: 'Mega Tesla',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000061: const CocItemMapping(
      dataId: 1000061,
      name: 'Lava Launcher',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000062: const CocItemMapping(
      dataId: 1000062,
      name: 'Guard Post',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000063: const CocItemMapping(
      dataId: 1000063,
      name: 'Star Laboratory',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000064: const CocItemMapping(
      dataId: 1000064,
      name: 'Gem Mine',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000065: const CocItemMapping(
      dataId: 1000065,
      name: 'Elixir Collector',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000066: const CocItemMapping(
      dataId: 1000066,
      name: 'Gold Mine',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000067: const CocItemMapping(
      dataId: 1000067,
      name: 'Elixir Storage',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000068: const CocItemMapping(
      dataId: 1000068,
      name: 'Gold Storage',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000069: const CocItemMapping(
      dataId: 1000069,
      name: 'Wall',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
      isWall: true,
    ),
    1000070: const CocItemMapping(
      dataId: 1000070,
      name: 'Clock Tower',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1000071: const CocItemMapping(
      dataId: 1000071,
      name: 'Healing Hut',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 6,
    ),
    1000072: const CocItemMapping(
      dataId: 1000072,
      name: 'X-Bow',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.defences,
      realm: VillageRealm.builderBase,
      maxLevel: 6,
    ),
    1000073: const CocItemMapping(
      dataId: 1000073,
      name: "O.T.T.O's Outpost",
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.buildings,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),

    // -------------------------------------------------------------------------
    // BUILDER BASE TRAPS (1200050 series / traps2)
    // -------------------------------------------------------------------------
    1200050: const CocItemMapping(
      dataId: 1200050,
      name: 'Spring Trap',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.builderBase,
      maxLevel: 5,
    ),
    1200051: const CocItemMapping(
      dataId: 1200051,
      name: 'Push Trap',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1200052: const CocItemMapping(
      dataId: 1200052,
      name: 'Mine',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),
    1200053: const CocItemMapping(
      dataId: 1200053,
      name: 'Mega Mine',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.traps,
      realm: VillageRealm.builderBase,
      maxLevel: 10,
    ),

    // -------------------------------------------------------------------------
    // BUILDER BASE TROOPS (4000030 series / units2)
    // -------------------------------------------------------------------------
    4000030: const CocItemMapping(
      dataId: 4000030,
      name: 'Raged Barbarian',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000031: const CocItemMapping(
      dataId: 4000031,
      name: 'Sneaky Archer',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000032: const CocItemMapping(
      dataId: 4000032,
      name: 'Boxer Giant',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000033: const CocItemMapping(
      dataId: 4000033,
      name: 'Beta Minion',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000034: const CocItemMapping(
      dataId: 4000034,
      name: 'Bomber',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000035: const CocItemMapping(
      dataId: 4000035,
      name: 'Baby Dragon',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000036: const CocItemMapping(
      dataId: 4000036,
      name: 'Cannon Cart',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000037: const CocItemMapping(
      dataId: 4000037,
      name: 'Night Witch',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000038: const CocItemMapping(
      dataId: 4000038,
      name: 'Drop Ship',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000039: const CocItemMapping(
      dataId: 4000039,
      name: 'Super P.E.K.K.A',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000040: const CocItemMapping(
      dataId: 4000040,
      name: 'Hog Glider',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),
    4000041: const CocItemMapping(
      dataId: 4000041,
      name: 'Electrofire Wizard',
      category: UpgradeCategory.builderBaseStarLab,
      itemType: LevelItemType.troops,
      realm: VillageRealm.builderBase,
      maxLevel: 20,
    ),

    // -------------------------------------------------------------------------
    // BUILDER BASE HEROES (28000010 series / heroes2)
    // -------------------------------------------------------------------------
    28000010: const CocItemMapping(
      dataId: 28000010,
      name: 'Battle Machine',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.heroes,
      realm: VillageRealm.builderBase,
      maxLevel: 35,
    ),
    28000011: const CocItemMapping(
      dataId: 28000011,
      name: 'Battle Copter',
      category: UpgradeCategory.builderBaseBuilder,
      itemType: LevelItemType.heroes,
      realm: VillageRealm.builderBase,
      maxLevel: 35,
    ),
  };

  /// Looks up a verified item mapping by its numeric [dataId].
  /// Optionally uses the JSON [section] to disambiguate or infer context.
  static CocItemMapping? lookup(int dataId, {String? section}) {
    // Direct exact lookup
    final direct = _mappings[dataId];
    if (direct != null) {
      if (section != null) {
        // Disambiguate if section indicates Builder Base vs Home Village
        final isBBSection = section.endsWith('2');
        if (isBBSection && direct.realm == VillageRealm.homeVillage) {
          // If in BB section, check for BB specific mapping offset
          final bbAlternative =
              _mappings[dataId + 50] ??
              _mappings.values.firstWhere(
                (m) =>
                    m.realm == VillageRealm.builderBase &&
                    m.name == direct.name,
                orElse: () => direct,
              );
          return bbAlternative;
        }
      }
      return direct;
    }

    // Handle 7-digit vs 8-digit format variations (e.g. 26000000 vs 2600000)
    if (dataId >= 2600000 && dataId < 2700000) {
      final expanded = 26000000 + (dataId - 2600000);
      return _mappings[expanded];
    }
    if (dataId >= 2800000 && dataId < 2900000) {
      final expanded = 28000000 + (dataId - 2800000);
      return _mappings[expanded];
    }
    if (dataId >= 7300000 && dataId < 7400000) {
      final expanded = 73000000 + (dataId - 7300000);
      return _mappings[expanded];
    }
    if (dataId >= 8800000 && dataId < 8900000) {
      final expanded = 88000000 + (dataId - 8800000);
      return _mappings[expanded];
    }

    return null;
  }

  /// Extends the catalogue dynamically with custom or newly discovered items.
  static void registerMapping(CocItemMapping mapping) {
    _mappings[mapping.dataId] = mapping;
  }

  /// Returns all currently registered mappings.
  static List<CocItemMapping> get allMappings => _mappings.values.toList();
}
