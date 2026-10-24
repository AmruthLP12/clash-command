/// Upgrade categories supported by the app across Home Village and Builder Base.
///
/// Supports the 4 distinct facilities/village scopes:
/// 1. Home Village — Builder
/// 2. Home Village — Laboratory
/// 3. Builder Base — Builder
/// 4. Builder Base — Star Laboratory
///
/// Legacy values (building, hero, defense, laboratory, troop, spell, etc.) are
/// preserved so existing databases and stored upgrade rows continue to load without data loss.
enum UpgradeCategory {
  // Primary categories
  homeBuilder,
  homeLab,
  builderBaseBuilder,
  builderBaseStarLab,

  // Legacy values preserved for backward compatibility
  building,
  hero,
  laboratory,
  troop,
  spell,
  pet,
  equipment,
  defense,
  other;

  /// The four primary user-facing tracking categories.
  static const List<UpgradeCategory> primaryCategories = [
    UpgradeCategory.homeBuilder,
    UpgradeCategory.homeLab,
    UpgradeCategory.builderBaseBuilder,
    UpgradeCategory.builderBaseStarLab,
  ];

  String get displayName {
    switch (this) {
      case UpgradeCategory.homeBuilder:
        return 'Home Village — Builder';
      case UpgradeCategory.homeLab:
        return 'Home Village — Laboratory';
      case UpgradeCategory.builderBaseBuilder:
        return 'Builder Base — Builder';
      case UpgradeCategory.builderBaseStarLab:
        return 'Builder Base — Star Laboratory';

      // Legacy names
      case UpgradeCategory.building:
        return 'Building';
      case UpgradeCategory.hero:
        return 'Hero';
      case UpgradeCategory.laboratory:
        return 'Laboratory';
      case UpgradeCategory.troop:
        return 'Troop';
      case UpgradeCategory.spell:
        return 'Spell';
      case UpgradeCategory.pet:
        return 'Pet';
      case UpgradeCategory.equipment:
        return 'Equipment';
      case UpgradeCategory.defense:
        return 'Defense';
      case UpgradeCategory.other:
        return 'Other';
    }
  }

  /// Compact label for badges and space-constrained cards.
  String get shortLabel {
    switch (this) {
      case UpgradeCategory.homeBuilder:
      case UpgradeCategory.building:
      case UpgradeCategory.hero:
      case UpgradeCategory.defense:
        return 'Home Builder';
      case UpgradeCategory.homeLab:
      case UpgradeCategory.laboratory:
      case UpgradeCategory.troop:
      case UpgradeCategory.spell:
        return 'Home Lab';
      case UpgradeCategory.builderBaseBuilder:
        return 'BB Builder';
      case UpgradeCategory.builderBaseStarLab:
        return 'Star Lab';
      default:
        return displayName;
    }
  }

  /// Maps legacy granular categories to their primary facility scope.
  UpgradeCategory get primaryCategory {
    switch (this) {
      case UpgradeCategory.homeBuilder:
      case UpgradeCategory.building:
      case UpgradeCategory.hero:
      case UpgradeCategory.defense:
      case UpgradeCategory.pet:
      case UpgradeCategory.equipment:
        return UpgradeCategory.homeBuilder;

      case UpgradeCategory.homeLab:
      case UpgradeCategory.laboratory:
      case UpgradeCategory.troop:
      case UpgradeCategory.spell:
        return UpgradeCategory.homeLab;

      case UpgradeCategory.builderBaseBuilder:
        return UpgradeCategory.builderBaseBuilder;

      case UpgradeCategory.builderBaseStarLab:
        return UpgradeCategory.builderBaseStarLab;

      case UpgradeCategory.other:
        return UpgradeCategory.homeBuilder;
    }
  }

  /// Returns true if this category belongs to Builder Base.
  bool get isBuilderBase {
    final prim = primaryCategory;
    return prim == UpgradeCategory.builderBaseBuilder ||
        prim == UpgradeCategory.builderBaseStarLab;
  }

  /// Returns true if this category is research-based (Laboratory).
  bool get isLaboratory {
    final prim = primaryCategory;
    return prim == UpgradeCategory.homeLab ||
        prim == UpgradeCategory.builderBaseStarLab;
  }

  static UpgradeCategory fromString(String value) {
    return UpgradeCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UpgradeCategory.other,
    );
  }
}
