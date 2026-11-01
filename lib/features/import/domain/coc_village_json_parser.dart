import 'dart:convert';
import 'dart:math';

import 'package:clash_command/domain/catalog/coc_data_id_catalog.dart';
import 'package:clash_command/domain/models/village_realm.dart';

import 'coc_import_preview_model.dart';

/// Service for validating and parsing Clash of Clans village export JSON files.
class CocVillageJsonParser {
  const CocVillageJsonParser();

  /// Parses raw JSON string or decoded map and returns a structured [CocImportPreview].
  ///
  /// Uses [referenceNow] (defaults to current UTC time) to determine whether
  /// upgrade timers are active or expired relative to snapshot reference time.
  CocImportPreview parse(dynamic rawJson, {DateTime? referenceNow}) {
    final now = (referenceNow ?? DateTime.now()).toUtc();

    Map<String, dynamic> json;
    if (rawJson is String) {
      final trimmed = rawJson.trim();
      if (trimmed.isEmpty) {
        throw const FormatException('Empty JSON input provided.');
      }
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('JSON root must be an object.');
        }
        json = decoded;
      } catch (e) {
        if (e is FormatException) rethrow;
        throw FormatException('Malformed JSON structure: $e');
      }
    } else if (rawJson is Map<String, dynamic>) {
      json = rawJson;
    } else {
      throw const FormatException('Invalid JSON payload type.');
    }

    // Top-level fields
    final rawTag = json['tag'];
    if (rawTag == null || rawTag is! String || rawTag.trim().isEmpty) {
      throw const FormatException(
        'Missing or invalid "tag" field in village export.',
      );
    }
    final tag = rawTag.trim();

    final rawTimestamp = json['timestamp'];
    if (rawTimestamp == null || rawTimestamp is! int) {
      throw const FormatException(
        'Missing or invalid "timestamp" field in village export.',
      );
    }
    final timestamp = rawTimestamp;
    final snapshotDateTimeUtc = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
      isUtc: true,
    );

    int? detectedTownHallLevel;
    int? detectedBuilderHallLevel;

    // Use composite keys (category_name_level) to aggregate quantities for repeated item IDs
    final Map<String, ParsedLevelItem> homeLevelsMap = {};
    final Map<String, ParsedLevelItem> builderLevelsMap = {};
    final List<ParsedActiveUpgrade> activeUpgrades = [];
    final List<ParsedExpiredTimer> expiredTimers = [];
    final List<ParsedUnmappedItem> unmappedItems = [];
    final List<String> supportedSections = [];

    // Helper method to process a collection of items
    void processSection(String sectionKey, List<dynamic>? rawList) {
      if (rawList == null) return;
      supportedSections.add(sectionKey);

      for (final rawItem in rawList) {
        if (rawItem is! Map) continue;
        final itemMap = Map<String, dynamic>.from(rawItem);

        // Check for nested modules e.g. buildings[].types[].modules[]
        final nestedTypes = itemMap['types'];
        if (nestedTypes is List) {
          for (final t in nestedTypes) {
            if (t is Map && t['modules'] is List) {
              final modules = t['modules'] as List;
              for (final m in modules) {
                if (m is Map && m.containsKey('data')) {
                  // Process nested module as an item
                  _processItem(
                    Map<String, dynamic>.from(m),
                    sectionKey,
                    snapshotDateTimeUtc,
                    now,
                    homeLevelsMap,
                    builderLevelsMap,
                    activeUpgrades,
                    expiredTimers,
                    unmappedItems,
                    (th) => detectedTownHallLevel = max(
                      detectedTownHallLevel ?? 0,
                      th,
                    ),
                    (bh) => detectedBuilderHallLevel = max(
                      detectedBuilderHallLevel ?? 0,
                      bh,
                    ),
                  );
                }
              }
            }
          }
        }

        // Process main item
        _processItem(
          itemMap,
          sectionKey,
          snapshotDateTimeUtc,
          now,
          homeLevelsMap,
          builderLevelsMap,
          activeUpgrades,
          expiredTimers,
          unmappedItems,
          (th) => detectedTownHallLevel = max(detectedTownHallLevel ?? 0, th),
          (bh) =>
              detectedBuilderHallLevel = max(detectedBuilderHallLevel ?? 0, bh),
        );
      }
    }

    // Process all standard sections
    processSection('buildings', json['buildings'] as List<dynamic>?);
    processSection('traps', json['traps'] as List<dynamic>?);
    processSection('units', json['units'] as List<dynamic>?);
    processSection('siege_machines', json['siege_machines'] as List<dynamic>?);
    processSection('heroes', json['heroes'] as List<dynamic>?);
    processSection('spells', json['spells'] as List<dynamic>?);
    processSection('pets', json['pets'] as List<dynamic>?);
    processSection('equipment', json['equipment'] as List<dynamic>?);
    processSection('buildings2', json['buildings2'] as List<dynamic>?);
    processSection('traps2', json['traps2'] as List<dynamic>?);
    processSection('units2', json['units2'] as List<dynamic>?);
    processSection('heroes2', json['heroes2'] as List<dynamic>?);

    // Helpers count and metadata
    int helpersCount = 0;
    final rawHelpers = json['helpers'];
    if (rawHelpers is List) {
      helpersCount = rawHelpers.length;
      supportedSections.add('helpers');
    }

    // Boosts summary
    final Map<String, dynamic> boostsSummary = {};
    final rawBoosts = json['boosts'];
    if (rawBoosts is Map<String, dynamic>) {
      boostsSummary.addAll(rawBoosts);
      supportedSections.add('boosts');
    }

    // Decorations and obstacles counts
    int decosCount = 0;
    final decos = json['decos'];
    final decos2 = json['decos2'];
    if (decos is List) decosCount += decos.length;
    if (decos2 is List) decosCount += decos2.length;
    if (decos is List || decos2 is List) supportedSections.add('decos');

    int obstaclesCount = 0;
    final obstacles = json['obstacles'];
    final obstacles2 = json['obstacles2'];
    if (obstacles is List) obstaclesCount += obstacles.length;
    if (obstacles2 is List) obstaclesCount += obstacles2.length;
    if (obstacles is List || obstacles2 is List) {
      supportedSections.add('obstacles');
    }

    return CocImportPreview(
      tag: tag,
      snapshotTimestamp: timestamp,
      snapshotDateTimeUtc: snapshotDateTimeUtc,
      detectedTownHallLevel: detectedTownHallLevel,
      detectedBuilderHallLevel: detectedBuilderHallLevel,
      homeLevels: homeLevelsMap.values.toList(),
      builderLevels: builderLevelsMap.values.toList(),
      activeUpgrades: activeUpgrades,
      expiredTimers: expiredTimers,
      unmappedItems: unmappedItems,
      helpersCount: helpersCount,
      boostsSummary: boostsSummary,
      decorationsCount: decosCount,
      obstaclesCount: obstaclesCount,
      supportedSections: supportedSections,
    );
  }

  void _processItem(
    Map<String, dynamic> item,
    String sectionKey,
    DateTime snapshotDateTimeUtc,
    DateTime now,
    Map<String, ParsedLevelItem> homeLevelsMap,
    Map<String, ParsedLevelItem> builderLevelsMap,
    List<ParsedActiveUpgrade> activeUpgrades,
    List<ParsedExpiredTimer> expiredTimers,
    List<ParsedUnmappedItem> unmappedItems,
    void Function(int th) onTownHallDetected,
    void Function(int bh) onBuilderHallDetected,
  ) {
    final rawDataId = item['data'];
    if (rawDataId == null || rawDataId is! int) {
      return;
    }

    final dataId = rawDataId;
    final rawLevel = item['lvl'];
    final level = rawLevel is int ? rawLevel : null;
    final quantity = (item['cnt'] as int?) ?? 1;
    final timer = item['timer'] as int?;

    final mapping = CocDataIdCatalog.lookup(dataId, section: sectionKey);

    if (mapping == null) {
      // Unmapped item ID preserved for user review in import preview
      unmappedItems.add(
        ParsedUnmappedItem(
          dataId: dataId,
          section: sectionKey,
          level: level,
          quantity: quantity,
          timer: timer,
          metadata: item,
        ),
      );
      return;
    }

    // Detect Town Hall and Builder Hall levels
    if (mapping.name == 'Town Hall' && level != null) {
      onTownHallDetected(level);
    } else if (mapping.name == 'Builder Hall' && level != null) {
      onBuilderHallDetected(level);
    }

    // If item has a level, record or aggregate its quantity
    if (level != null && level > 0) {
      final key = '${mapping.category.name}__${mapping.name}__$level';
      final targetMap = mapping.realm == VillageRealm.builderBase
          ? builderLevelsMap
          : homeLevelsMap;

      if (targetMap.containsKey(key)) {
        final existing = targetMap[key]!;
        targetMap[key] = ParsedLevelItem(
          dataId: dataId,
          name: mapping.name,
          category: mapping.category,
          itemType: mapping.itemType,
          level: level,
          quantity: existing.quantity + quantity,
          realm: mapping.realm,
          maxLevel: mapping.maxLevel,
        );
      } else {
        targetMap[key] = ParsedLevelItem(
          dataId: dataId,
          name: mapping.name,
          category: mapping.category,
          itemType: mapping.itemType,
          level: level,
          quantity: quantity,
          realm: mapping.realm,
          maxLevel: mapping.maxLevel,
        );
      }
    }

    // Timer calculation:
    // snapshot_time = timestamp
    // remaining_seconds = timer
    // completion_time = snapshot_time + remaining_seconds
    if (timer != null && timer > 0) {
      final expectedCompletionAtUtc = snapshotDateTimeUtc.add(
        Duration(seconds: timer),
      );

      if (expectedCompletionAtUtc.isAfter(now)) {
        // Upgrade is actively in progress right now
        final remainingNowSeconds = expectedCompletionAtUtc
            .difference(now)
            .inSeconds;
        final fromLevel = level ?? 1;
        final toLevel =
            (mapping.maxLevel != null && fromLevel < mapping.maxLevel!)
            ? fromLevel + 1
            : fromLevel + 1;

        activeUpgrades.add(
          ParsedActiveUpgrade(
            dataId: dataId,
            name: mapping.name,
            category: mapping.category,
            itemType: mapping.itemType,
            fromLevel: fromLevel,
            toLevel: toLevel,
            remainingDurationSeconds: max(1, remainingNowSeconds),
            expectedCompletionAtUtc: expectedCompletionAtUtc,
            startedAtUtc: snapshotDateTimeUtc,
            realm: mapping.realm,
          ),
        );
      } else {
        // Timer completed prior to file import
        expiredTimers.add(
          ParsedExpiredTimer(
            dataId: dataId,
            name: mapping.name,
            category: mapping.category,
            level: level ?? 1,
            expiredAtUtc: expectedCompletionAtUtc,
            realm: mapping.realm,
          ),
        );
      }
    }
  }
}
