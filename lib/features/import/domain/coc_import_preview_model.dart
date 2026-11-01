import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village_realm.dart';

/// Represents a recognized level item parsed from Clash of Clans village JSON.
class ParsedLevelItem {
  const ParsedLevelItem({
    required this.dataId,
    required this.name,
    required this.category,
    required this.itemType,
    required this.level,
    required this.quantity,
    required this.realm,
    this.maxLevel,
  });

  final int dataId;
  final String name;
  final UpgradeCategory category;
  final String itemType;
  final int level;
  final int quantity;
  final VillageRealm realm;
  final int? maxLevel;

  String get displayNameWithQuantity =>
      quantity > 1 ? '$name · Lv. $level (×$quantity)' : '$name · Lv. $level';
}

/// Represents an active upgrade detected from an item with a future timer.
class ParsedActiveUpgrade {
  const ParsedActiveUpgrade({
    required this.dataId,
    required this.name,
    required this.category,
    required this.itemType,
    required this.fromLevel,
    this.toLevel,
    required this.remainingDurationSeconds,
    required this.expectedCompletionAtUtc,
    required this.startedAtUtc,
    required this.realm,
  });

  final int dataId;
  final String name;
  final UpgradeCategory category;
  final String itemType;
  final int fromLevel;
  final int? toLevel;
  final int remainingDurationSeconds;
  final DateTime expectedCompletionAtUtc;
  final DateTime startedAtUtc;
  final VillageRealm realm;

  String get levelProgression =>
      toLevel != null ? 'Lv. $fromLevel → Lv. $toLevel' : 'Lv. $fromLevel';
}

/// Represents an item whose timer expired before import time.
class ParsedExpiredTimer {
  const ParsedExpiredTimer({
    required this.dataId,
    required this.name,
    required this.category,
    required this.level,
    required this.expiredAtUtc,
    required this.realm,
  });

  final int dataId;
  final String name;
  final UpgradeCategory category;
  final int level;
  final DateTime expiredAtUtc;
  final VillageRealm realm;
}

/// Represents an unsupported or unrecognized item ID found in the JSON export.
class ParsedUnmappedItem {
  const ParsedUnmappedItem({
    required this.dataId,
    required this.section,
    this.level,
    this.quantity = 1,
    this.timer,
    this.metadata,
  });

  final int dataId;
  final String section;
  final int? level;
  final int quantity;
  final int? timer;
  final Map<String, dynamic>? metadata;
}

/// Complete preview model representing the parsed state of a Clash of Clans JSON export.
class CocImportPreview {
  const CocImportPreview({
    required this.tag,
    required this.snapshotTimestamp,
    required this.snapshotDateTimeUtc,
    this.detectedTownHallLevel,
    this.detectedBuilderHallLevel,
    required this.homeLevels,
    required this.builderLevels,
    required this.activeUpgrades,
    required this.expiredTimers,
    required this.unmappedItems,
    this.helpersCount = 0,
    this.boostsSummary = const {},
    this.decorationsCount = 0,
    this.obstaclesCount = 0,
    this.supportedSections = const [],
  });

  final String tag;
  final int snapshotTimestamp;
  final DateTime snapshotDateTimeUtc;
  final int? detectedTownHallLevel;
  final int? detectedBuilderHallLevel;

  final List<ParsedLevelItem> homeLevels;
  final List<ParsedLevelItem> builderLevels;
  final List<ParsedActiveUpgrade> activeUpgrades;
  final List<ParsedExpiredTimer> expiredTimers;
  final List<ParsedUnmappedItem> unmappedItems;

  final int helpersCount;
  final Map<String, dynamic> boostsSummary;
  final int decorationsCount;
  final int obstaclesCount;
  final List<String> supportedSections;

  int get totalLevelsCount => homeLevels.length + builderLevels.length;
  int get totalActiveUpgradesCount => activeUpgrades.length;
  int get totalExpiredTimersCount => expiredTimers.length;
  int get totalUnmappedCount => unmappedItems.length;
}
