import '../models/upgrade_category.dart';

/// Represents a predefined or custom upgrade item in the catalogue.
class UpgradeCatalogItem {
  const UpgradeCatalogItem({
    required this.name,
    required this.category,
    required this.type,
    this.minTownHall,
    this.minBuilderHall,
    this.minLevel = 1,
    this.maxLevel,
    this.isCustom = false,
  });

  /// Name of the upgrade (e.g. "Town Hall", "Archer Tower", "P.E.K.K.A").
  final String name;

  /// Primary upgrade category.
  final UpgradeCategory category;

  /// High-level description of the upgrade type (e.g. "Defense", "Resource", "Troop", "Hero").
  final String type;

  /// Minimum Town Hall level at which this upgrade is unlocked.
  final int? minTownHall;

  /// Minimum Builder Hall level at which this upgrade is unlocked.
  final int? minBuilderHall;

  /// Minimum valid level (typically 1).
  final int minLevel;

  /// Maximum confirmed level in Clash of Clans. Null if unverified or custom.
  final int? maxLevel;

  /// True if this item was created dynamically by the user.
  final bool isCustom;

  /// Suggests the next level given a selected [fromLevel].
  int? suggestToLevel(int? fromLevel) {
    if (fromLevel == null) {
      return minLevel + 1 <= (maxLevel ?? minLevel + 1) ? minLevel + 1 : null;
    }
    final next = fromLevel + 1;
    if (maxLevel != null && next > maxLevel!) {
      return maxLevel;
    }
    return next;
  }

  /// Compact subtitle text for autocomplete suggestions (e.g. "Defense · Max Lv. 21").
  String get subtitle {
    final parts = <String>[];
    if (type.isNotEmpty) parts.add(type);
    if (maxLevel != null) {
      parts.add('Max Lv. $maxLevel');
    }
    if (isCustom) {
      parts.add('Custom');
    }
    return parts.join(' • ');
  }
}

