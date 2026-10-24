import 'upgrade_category.dart';
import 'upgrade_status.dart';

/// Domain model representing a single upgrade being tracked.
///
/// All timestamps are stored in UTC. Remaining time is always derived
/// from [expectedCompletionAtUtc] minus the current clock — never stored
/// as a mutable countdown.
class Upgrade {
  const Upgrade({
    required this.id,
    required this.villageId,
    required this.name,
    required this.category,
    required this.startedAtUtc,
    required this.expectedCompletionAtUtc,
    required this.status,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.slotKey,
    this.catalogItemId,
    this.durationSeconds,
    this.completedAtUtc,
    this.notificationRevision = 0,
    this.notes,
    this.fromLevel,
    this.toLevel,
  });

  final String id;
  final String villageId;
  final String name;
  final UpgradeCategory category;
  final String? slotKey;
  final String? catalogItemId;
  final int? durationSeconds;
  final DateTime startedAtUtc;
  final DateTime expectedCompletionAtUtc;
  final UpgradeStatus status;
  final DateTime? completedAtUtc;
  final int notificationRevision;
  final String? notes;
  final int? fromLevel;
  final int? toLevel;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  /// Returns a compact representation of the upgrade name with its levels
  /// when available (e.g. "Archer Tower · Lv. 18 → 19").
  String get displayNameWithLevel {
    if (fromLevel != null && toLevel != null) {
      return '$name · Lv. $fromLevel → $toLevel';
    }
    if (toLevel != null) {
      return '$name · Lv. $toLevel';
    }
    if (fromLevel != null) {
      return '$name · From Lv. $fromLevel';
    }
    return name;
  }

  Upgrade copyWith({
    String? id,
    String? villageId,
    String? name,
    UpgradeCategory? category,
    String? slotKey,
    bool clearSlotKey = false,
    String? catalogItemId,
    bool clearCatalogItemId = false,
    int? durationSeconds,
    bool clearDurationSeconds = false,
    DateTime? startedAtUtc,
    DateTime? expectedCompletionAtUtc,
    UpgradeStatus? status,
    DateTime? completedAtUtc,
    bool clearCompletedAt = false,
    int? notificationRevision,
    String? notes,
    bool clearNotes = false,
    int? fromLevel,
    bool clearFromLevel = false,
    int? toLevel,
    bool clearToLevel = false,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) {
    return Upgrade(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      name: name ?? this.name,
      category: category ?? this.category,
      slotKey: clearSlotKey ? null : (slotKey ?? this.slotKey),
      catalogItemId:
          clearCatalogItemId ? null : (catalogItemId ?? this.catalogItemId),
      durationSeconds:
          clearDurationSeconds ? null : (durationSeconds ?? this.durationSeconds),
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      expectedCompletionAtUtc:
          expectedCompletionAtUtc ?? this.expectedCompletionAtUtc,
      status: status ?? this.status,
      completedAtUtc:
          clearCompletedAt ? null : (completedAtUtc ?? this.completedAtUtc),
      notificationRevision: notificationRevision ?? this.notificationRevision,
      notes: clearNotes ? null : (notes ?? this.notes),
      fromLevel: clearFromLevel ? null : (fromLevel ?? this.fromLevel),
      toLevel: clearToLevel ? null : (toLevel ?? this.toLevel),
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Upgrade && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Upgrade(id: $id, name: $displayNameWithLevel, status: $status)';
}
