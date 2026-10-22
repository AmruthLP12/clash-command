/// Types of events recorded in the history log.
enum HistoryEventType {
  upgradeStarted,
  upgradeCompleted,
  upgradeCancelled,
  upgradeDeleted,
  upgradeEdited,
  upgradeTimerEdited,
  upgradeReopened,
  villageCreated,
  villageEdited,
  villageArchived,
  villageDeleted;

  String get displayName {
    switch (this) {
      case upgradeStarted:
        return 'Upgrade Started';
      case upgradeCompleted:
        return 'Upgrade Completed';
      case upgradeCancelled:
        return 'Upgrade Cancelled';
      case upgradeDeleted:
        return 'Upgrade Deleted';
      case upgradeEdited:
        return 'Upgrade Edited';
      case upgradeTimerEdited:
        return 'Timer Adjusted';
      case upgradeReopened:
        return 'Upgrade Reopened';
      case villageCreated:
        return 'Village Created';
      case villageEdited:
        return 'Village Edited';
      case villageArchived:
        return 'Village Archived';
      case villageDeleted:
        return 'Village Deleted';
    }
  }

  static HistoryEventType fromString(String value) {
    return HistoryEventType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HistoryEventType.upgradeEdited,
    );
  }
}

/// Domain model for a recorded history event.
class HistoryEvent {
  const HistoryEvent({
    required this.id,
    required this.eventType,
    required this.description,
    required this.createdAtUtc,
    this.upgradeId,
    this.villageId,
    this.upgradeName,
    this.villageName,
  });

  final String id;
  final String? upgradeId;
  final String? villageId;
  final HistoryEventType eventType;
  final String description;
  final String? upgradeName;
  final String? villageName;
  final DateTime createdAtUtc;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is HistoryEvent && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'HistoryEvent(id: $id, type: ${eventType.name}, desc: $description)';
}

