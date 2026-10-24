import 'upgrade_category.dart';

/// Domain model representing a planned future upgrade.
class PlannerItem {
  const PlannerItem({
    required this.id,
    required this.villageId,
    required this.category,
    required this.name,
    this.targetLevel,
    this.priority = 'Medium',
    this.notes,
    this.sortOrder = 0,
    this.status = 'planned',
    this.isNext = false,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String villageId;
  final UpgradeCategory category;
  final String name;
  final int? targetLevel;
  final String priority; // 'High', 'Medium', 'Low'
  final String? notes;
  final int sortOrder;
  final String status; // 'planned', 'started', 'completed', 'cancelled'
  final bool isNext;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  String get displayNameWithLevel {
    if (targetLevel != null) {
      return '$name · Lv. $targetLevel';
    }
    return name;
  }

  PlannerItem copyWith({
    String? id,
    String? villageId,
    UpgradeCategory? category,
    String? name,
    int? targetLevel,
    bool clearTargetLevel = false,
    String? priority,
    String? notes,
    bool clearNotes = false,
    int? sortOrder,
    String? status,
    bool? isNext,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) {
    return PlannerItem(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      category: category ?? this.category,
      name: name ?? this.name,
      targetLevel:
          clearTargetLevel ? null : (targetLevel ?? this.targetLevel),
      priority: priority ?? this.priority,
      notes: clearNotes ? null : (notes ?? this.notes),
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      isNext: isNext ?? this.isNext,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PlannerItem && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PlannerItem(id: $id, name: $name, targetLevel: $targetLevel)';
}

