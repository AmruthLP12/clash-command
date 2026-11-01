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
    this.quantity = 1,
    this.dataId,
    this.itemType,
    required this.updatedAtUtc,
  });

  final String id;
  final String villageId;
  final UpgradeCategory category;
  final String itemName;
  final int currentLevel;
  final int quantity;
  final int? dataId;
  final String? itemType;
  final DateTime updatedAtUtc;

  String get displayNameWithLevel {
    final base = '$itemName · Lv. $currentLevel';
    return quantity > 1 ? '$base (×$quantity)' : base;
  }

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
    int? quantity,
    int? dataId,
    bool clearDataId = false,
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
      quantity: quantity ?? this.quantity,
      dataId: clearDataId ? null : (dataId ?? this.dataId),
      itemType: clearItemType ? null : (itemType ?? this.itemType),
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'villageId': villageId,
      'category': category.name,
      'itemName': itemName,
      'currentLevel': currentLevel,
      'quantity': quantity,
      'dataId': dataId,
      'itemType': itemType,
      'updatedAtUtc': updatedAtUtc.toIso8601String(),
    };
  }

  factory VillageItemLevel.fromJson(Map<String, dynamic> json) {
    return VillageItemLevel(
      id: json['id'] as String,
      villageId: json['villageId'] as String,
      category: UpgradeCategory.fromString(json['category'] as String),
      itemName: json['itemName'] as String,
      currentLevel: json['currentLevel'] as int,
      quantity: (json['quantity'] as int?) ?? 1,
      dataId: json['dataId'] as int?,
      itemType: json['itemType'] as String?,
      updatedAtUtc: DateTime.parse(json['updatedAtUtc'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VillageItemLevel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VillageItemLevel(id: $id, villageId: $villageId, itemName: $itemName, type: $itemType, currentLevel: $currentLevel, quantity: $quantity, dataId: $dataId)';
}
