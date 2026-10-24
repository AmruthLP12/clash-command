import 'package:flutter/material.dart';

import 'upgrade_category.dart';

/// Defines supported item types and subcategory classifications across villages.
class LevelItemType {
  const LevelItemType._();

  // Canonical classification names
  static const String buildings = 'Buildings';
  static const String defences = 'Defences';
  static const String traps = 'Traps';
  static const String heroes = 'Heroes';
  static const String heroPets = 'Hero Pets';
  static const String troops = 'Troops';
  static const String spells = 'Spells';
  static const String siegeMachines = 'Siege Machines';
  static const String other = 'Other';

  /// Returns the valid item types for the given category.
  static List<String> typesForCategory(UpgradeCategory category) {
    switch (category.primaryCategory) {
      case UpgradeCategory.homeBuilder:
        return const [
          buildings,
          defences,
          traps,
          heroes,
          heroPets,
          other,
        ];
      case UpgradeCategory.homeLab:
        return const [
          troops,
          spells,
          siegeMachines,
          other,
        ];
      case UpgradeCategory.builderBaseBuilder:
        return const [
          buildings,
          defences,
          traps,
          heroes,
          other,
        ];
      case UpgradeCategory.builderBaseStarLab:
        return const [
          troops,
          other,
        ];
      default:
        return const [other];
    }
  }

  /// Checks if a catalogue item's `type` field matches a canonical [itemType].
  static bool matchesCatalogType(String itemType, String catalogType) {
    final catTypeLower = catalogType.trim().toLowerCase();
    switch (itemType) {
      case buildings:
        return catTypeLower == 'core' ||
            catTypeLower == 'army' ||
            catTypeLower == 'resource' ||
            catTypeLower == 'building' ||
            catTypeLower == 'buildings';
      case defences:
        return catTypeLower == 'defense' ||
            catTypeLower == 'defences' ||
            catTypeLower == 'defence' ||
            catTypeLower == 'merged defense';
      case traps:
        return catTypeLower == 'trap' || catTypeLower == 'traps';
      case heroes:
        return catTypeLower == 'hero' || catTypeLower == 'heroes';
      case heroPets:
        return catTypeLower == 'pet' ||
            catTypeLower == 'hero pet' ||
            catTypeLower == 'hero pets';
      case troops:
        return catTypeLower == 'troop' ||
            catTypeLower == 'troops' ||
            catTypeLower == 'dark troop';
      case spells:
        return catTypeLower == 'spell' ||
            catTypeLower == 'spells' ||
            catTypeLower == 'dark spell';
      case siegeMachines:
        return catTypeLower == 'siege machine' ||
            catTypeLower == 'siege machines' ||
            catTypeLower == 'siege';
      case other:
        return true;
      default:
        return false;
    }
  }

  /// Automatically infers the canonical [itemType] from a catalogue item's type.
  static String fromCatalogType(String catalogType, UpgradeCategory category) {
    final catTypeLower = catalogType.trim().toLowerCase();
    if (catTypeLower == 'defense' || catTypeLower == 'merged defense') {
      return defences;
    }
    if (catTypeLower == 'trap') return traps;
    if (catTypeLower == 'hero') return heroes;
    if (catTypeLower == 'pet' || catTypeLower == 'hero pet') return heroPets;
    if (catTypeLower == 'core' ||
        catTypeLower == 'army' ||
        catTypeLower == 'resource') {
      return buildings;
    }
    if (catTypeLower == 'troop' || catTypeLower == 'dark troop') return troops;
    if (catTypeLower == 'spell' || catTypeLower == 'dark spell') return spells;
    if (catTypeLower == 'siege machine') return siegeMachines;
    return other;
  }

  /// Returns an appropriate icon for an item type.
  static IconData iconForType(String itemType) {
    switch (itemType) {
      case buildings:
        return Icons.domain;
      case defences:
        return Icons.shield_outlined;
      case traps:
        return Icons.warning_amber_rounded;
      case heroes:
        return Icons.workspace_premium;
      case heroPets:
        return Icons.pets;
      case troops:
        return Icons.groups_outlined;
      case spells:
        return Icons.auto_fix_high;
      case siegeMachines:
        return Icons.precision_manufacturing_outlined;
      case other:
      default:
        return Icons.category_outlined;
    }
  }

  /// Returns a concise display label for an item type badge.
  static String conciseLabel(String itemType) {
    switch (itemType) {
      case buildings:
        return 'Building';
      case defences:
        return 'Defence';
      case traps:
        return 'Trap';
      case heroes:
        return 'Hero';
      case heroPets:
        return 'Pet';
      case troops:
        return 'Troop';
      case spells:
        return 'Spell';
      case siegeMachines:
        return 'Siege';
      case other:
      default:
        return 'Other';
    }
  }
}

