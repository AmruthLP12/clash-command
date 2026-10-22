/// Domain model representing a tracked village.
///
/// All timestamps are stored in UTC.
class Village {
  const Village({
    required this.id,
    required this.name,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.townHallLevel,
    this.builderCapacity = 1,
    this.sortOrder,
    this.isArchived = false,
    this.notes,
  });

  final String id;
  final String name;
  final int? townHallLevel;

  /// Number of active builder/upgrade slots this village can use simultaneously.
  final int builderCapacity;
  final int? sortOrder;
  final bool isArchived;
  final String? notes;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  Village copyWith({
    String? id,
    String? name,
    int? townHallLevel,
    bool clearTownHallLevel = false,
    int? builderCapacity,
    int? sortOrder,
    bool clearSortOrder = false,
    bool? isArchived,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) {
    return Village(
      id: id ?? this.id,
      name: name ?? this.name,
      townHallLevel:
          clearTownHallLevel ? null : (townHallLevel ?? this.townHallLevel),
      builderCapacity: builderCapacity ?? this.builderCapacity,
      sortOrder: clearSortOrder ? null : (sortOrder ?? this.sortOrder),
      isArchived: isArchived ?? this.isArchived,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Village && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Village(id: $id, name: $name)';
}
