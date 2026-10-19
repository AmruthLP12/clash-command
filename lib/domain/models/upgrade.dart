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
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  Upgrade copyWith({
    String? id,
    String? villageId,
    String? name,
    UpgradeCategory? category,
    String? slotKey,
    String? catalogItemId,
    int? durationSeconds,
    DateTime? startedAtUtc,
    DateTime? expectedCompletionAtUtc,
    UpgradeStatus? status,
    DateTime? completedAtUtc,
    bool clearCompletedAt = false,
    int? notificationRevision,
    String? notes,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) {
    return Upgrade(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      name: name ?? this.name,
      category: category ?? this.category,
      slotKey: slotKey ?? this.slotKey,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      expectedCompletionAtUtc:
          expectedCompletionAtUtc ?? this.expectedCompletionAtUtc,
      status: status ?? this.status,
      completedAtUtc:
          clearCompletedAt ? null : (completedAtUtc ?? this.completedAtUtc),
      notificationRevision: notificationRevision ?? this.notificationRevision,
      notes: notes ?? this.notes,
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
  String toString() => 'Upgrade(id: $id, name: $name, status: $status)';
}
