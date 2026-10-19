/// Lifecycle states for an upgrade record.
enum UpgradeStatus {
  active,
  completed,
  cancelled;

  static UpgradeStatus fromString(String value) {
    return UpgradeStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UpgradeStatus.active,
    );
  }
}
