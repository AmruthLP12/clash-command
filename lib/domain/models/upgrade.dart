enum UpgradeStatus {
  active,
  completed,
  cancelled,
}

class Upgrade {
  const Upgrade({
    required this.id,
    required this.villageId,
    required this.name,
    required this.category,
    required this.startedAtUtc,
    required this.expectedCompletionAtUtc,
    required this.status,
    this.completedAtUtc,
    this.notes,
  });

  final String id;
  final String villageId;
  final String name;
  final String category;
  final DateTime startedAtUtc;
  final DateTime expectedCompletionAtUtc;
  final UpgradeStatus status;
  final DateTime? completedAtUtc;
  final String? notes;
}
