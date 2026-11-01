/// Domain model representing an imported Clash of Clans village snapshot history record.
class VillageImport {
  const VillageImport({
    required this.id,
    required this.villageId,
    required this.villageTag,
    required this.snapshotTimestamp,
    required this.importedAtUtc,
    this.importedRecordCount = 0,
    this.skippedRecordCount = 0,
    this.activeUpgradesCount = 0,
    required this.importMode,
    this.result = 'success',
    this.summaryJson,
  });

  final String id;
  final String villageId;
  final String villageTag;
  final int snapshotTimestamp;
  final DateTime importedAtUtc;
  final int importedRecordCount;
  final int skippedRecordCount;
  final int activeUpgradesCount;
  final String importMode;
  final String result;
  final String? summaryJson;

  DateTime get snapshotDateTimeUtc => DateTime.fromMillisecondsSinceEpoch(
    snapshotTimestamp * 1000,
    isUtc: true,
  );

  VillageImport copyWith({
    String? id,
    String? villageId,
    String? villageTag,
    int? snapshotTimestamp,
    DateTime? importedAtUtc,
    int? importedRecordCount,
    int? skippedRecordCount,
    int? activeUpgradesCount,
    String? importMode,
    String? result,
    String? summaryJson,
  }) {
    return VillageImport(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      villageTag: villageTag ?? this.villageTag,
      snapshotTimestamp: snapshotTimestamp ?? this.snapshotTimestamp,
      importedAtUtc: importedAtUtc ?? this.importedAtUtc,
      importedRecordCount: importedRecordCount ?? this.importedRecordCount,
      skippedRecordCount: skippedRecordCount ?? this.skippedRecordCount,
      activeUpgradesCount: activeUpgradesCount ?? this.activeUpgradesCount,
      importMode: importMode ?? this.importMode,
      result: result ?? this.result,
      summaryJson: summaryJson ?? this.summaryJson,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'villageId': villageId,
      'villageTag': villageTag,
      'snapshotTimestamp': snapshotTimestamp,
      'importedAtUtc': importedAtUtc.toIso8601String(),
      'importedRecordCount': importedRecordCount,
      'skippedRecordCount': skippedRecordCount,
      'activeUpgradesCount': activeUpgradesCount,
      'importMode': importMode,
      'result': result,
      'summaryJson': summaryJson,
    };
  }

  factory VillageImport.fromJson(Map<String, dynamic> json) {
    return VillageImport(
      id: json['id'] as String,
      villageId: json['villageId'] as String,
      villageTag: json['villageTag'] as String,
      snapshotTimestamp: json['snapshotTimestamp'] as int,
      importedAtUtc: DateTime.parse(json['importedAtUtc'] as String),
      importedRecordCount: (json['importedRecordCount'] as int?) ?? 0,
      skippedRecordCount: (json['skippedRecordCount'] as int?) ?? 0,
      activeUpgradesCount: (json['activeUpgradesCount'] as int?) ?? 0,
      importMode: json['importMode'] as String,
      result: (json['result'] as String?) ?? 'success',
      summaryJson: json['summaryJson'] as String?,
    );
  }
}
