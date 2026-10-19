/// Upgrade categories supported by the app.
enum UpgradeCategory {
  building,
  hero,
  laboratory,
  troop,
  spell,
  pet,
  equipment,
  defense,
  other;

  String get displayName {
    switch (this) {
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

  static UpgradeCategory fromString(String value) {
    return UpgradeCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UpgradeCategory.other,
    );
  }
}
