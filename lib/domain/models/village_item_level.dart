import '../catalog/upgrade_catalog.dart';
import 'level_item_type.dart';
import 'upgrade_category.dart';

/// Domain model representing the current level of an upgradeable item in a village.
class VillageItemLevel {
  const VillageItemLevel({
    required this.id,
    required this.villageId,
    required this.category,
    required this.itemName,
    required this.currentLevel,
    this.itemType,
    required this.updatedAtUtc,
  });

  final String id;
  final String villageId;
  final UpgradeCategory category;
  final String itemName;
  final int currentLevel;
  final String? itemType;
  final DateTime updatedAtUtc;

  String get displayNameWithLevel => '$itemName · Lv. $currentLevel';

  /// Returns the stored [itemType] if present, or dynamically infers it from the catalogue.
  String get effectiveItemType {
    if (itemType != null && itemType!.trim().isNotEmpty) {
      return itemType!;
    }
    final catalogItem = UpgradeCatalog.find(itemName, category);
    if (catalogItem != null) {
      return LevelItemType.fromCatalogType(catalogItem.type, category);
    }
    return LevelItemType.other;
  }

  VillageItemLevel copyWith({
    String? id,
    String? villageId,
    UpgradeCategory? category,
    String? itemName,
    int? currentLevel,
    String? itemType,
    bool clearItemType = false,
    DateTime? updatedAtUtc,
  }) {
    return VillageItemLevel(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      category: category ?? this.category,
      itemName: itemName ?? this.itemName,
      currentLevel: currentLevel ?? this.currentLevel,
      itemType: clearItemType ? null : (itemType ?? this.itemType),
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VillageItemLevel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VillageItemLevel(id: $id, villageId: $villageId, itemName: $itemName, type: $itemType, currentLevel: $currentLevel)';
}
