class Village {
  const Village({
    required this.id,
    required this.name,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.townHallLevel,
    this.builderCapacity,
    this.isArchived = false,
    this.notes,
  });

  final String id;
  final String name;
  final int? townHallLevel;
  final int? builderCapacity;
  final bool isArchived;
  final String? notes;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}
