import 'upgrade_category.dart';

/// Domain model representing the current level of an upgradeable item in a village.
class VillageItemLevel {
  const VillageItemLevel({
    required this.id,
    required this.villageId,
    required this.category,
    required this.itemName,
    required this.currentLevel,
    required this.updatedAtUtc,
  });

  final String id;
  final String villageId;
  final UpgradeCategory category;
  final String itemName;
  final int currentLevel;
  final DateTime updatedAtUtc;

  String get displayNameWithLevel => '$itemName · Lv. $currentLevel';

  VillageItemLevel copyWith({
    String? id,
    String? villageId,
    UpgradeCategory? category,
    String? itemName,
    int? currentLevel,
    DateTime? updatedAtUtc,
  }) {
    return VillageItemLevel(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      category: category ?? this.category,
      itemName: itemName ?? this.itemName,
      currentLevel: currentLevel ?? this.currentLevel,
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
      'VillageItemLevel(id: $id, villageId: $villageId, itemName: $itemName, currentLevel: $currentLevel)';
}

