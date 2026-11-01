/// Metadata manifest describing a Clash Command portable backup archive.
class BackupManifest {
  const BackupManifest({
    required this.appName,
    required this.appVersion,
    required this.backupFormatVersion,
    required this.createdAtUtc,
    required this.databaseSchemaVersion,
    required this.recordCounts,
  });

  static const String currentAppName = 'Clash Command';
  static const String currentAppVersion = '1.0.8';
  static const int currentBackupFormatVersion = 1;
  static const int currentDatabaseSchemaVersion = 7;

  final String appName;
  final String appVersion;
  final int backupFormatVersion;
  final DateTime createdAtUtc;
  final int databaseSchemaVersion;
  final Map<String, int> recordCounts;

  int get backupVersion => backupFormatVersion;
  int get villageCount => recordCounts['villages'] ?? 0;
  Map<String, int> get tables => recordCounts;

  int get totalRecordsCount =>
      recordCounts.values.fold<int>(0, (sum, count) => sum + count);

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'backupFormatVersion': backupFormatVersion,
      'createdAtUtc': createdAtUtc.toIso8601String(),
      'databaseSchemaVersion': databaseSchemaVersion,
      'recordCounts': recordCounts,
    };
  }

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['recordCounts'];
    final Map<String, int> counts = {};
    if (rawCounts is Map) {
      rawCounts.forEach((k, v) {
        counts[k.toString()] = (v as num).toInt();
      });
    }

    return BackupManifest(
      appName: (json['appName'] as String?) ?? currentAppName,
      appVersion: (json['appVersion'] as String?) ?? currentAppVersion,
      backupFormatVersion: (json['backupFormatVersion'] as int?) ?? 1,
      createdAtUtc:
          DateTime.tryParse(json['createdAtUtc'] as String? ?? '') ??
          DateTime.now().toUtc(),
      databaseSchemaVersion: (json['databaseSchemaVersion'] as int?) ?? 7,
      recordCounts: counts,
    );
  }
}
