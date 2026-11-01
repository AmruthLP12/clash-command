import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:clash_command/database/app_database.dart';
import 'package:clash_command/database/daos/history_events_dao.dart';
import 'package:clash_command/database/daos/upgrades_dao.dart';
import 'package:clash_command/database/daos/village_imports_dao.dart';
import 'package:clash_command/database/daos/village_item_levels_dao.dart';
import 'package:clash_command/database/daos/villages_dao.dart';
import 'package:clash_command/domain/catalog/coc_data_id_catalog.dart';
import 'package:clash_command/domain/models/level_item_type.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/models/village_item_level.dart';
import 'package:clash_command/domain/models/village_realm.dart';
import 'package:clash_command/features/backup/application/backup_service.dart';
import 'package:clash_command/features/backup/domain/backup_manifest.dart';
import 'package:clash_command/features/import/application/coc_village_import_service.dart';
import 'package:clash_command/features/import/domain/coc_import_preview_model.dart';
import 'package:clash_command/features/import/domain/coc_village_json_parser.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CocDataIdCatalog Tests', () {
    test('resolves core Town Hall, buildings, and defenses', () {
      final townHall = CocDataIdCatalog.lookup(1000000);
      expect(townHall, isNotNull);
      expect(townHall!.name, 'Town Hall');
      expect(townHall.category, UpgradeCategory.homeBuilder);
      expect(townHall.itemType, LevelItemType.buildings);

      final eagle = CocDataIdCatalog.lookup(1000019);
      expect(eagle, isNotNull);
      expect(eagle!.name, 'Eagle Artillery');
      expect(eagle.itemType, LevelItemType.defences);

      final wall = CocDataIdCatalog.lookup(1000010);
      expect(wall, isNotNull);
      expect(wall!.name, 'Wall');
      expect(wall.itemType, LevelItemType.defences);
    });

    test(
      'resolves troops, siege machines, spells, heroes, pets, and equipment',
      () {
        final barb = CocDataIdCatalog.lookup(4000000);
        expect(barb, isNotNull);
        expect(barb!.name, 'Barbarian');
        expect(barb.category, UpgradeCategory.homeLab);
        expect(barb.itemType, LevelItemType.troops);

        final logLauncher = CocDataIdCatalog.lookup(4000055);
        expect(logLauncher, isNotNull);
        expect(logLauncher!.name, 'Log Launcher');
        expect(logLauncher.itemType, LevelItemType.siegeMachines);

        final king = CocDataIdCatalog.lookup(28000000);
        expect(king, isNotNull);
        expect(king!.name, 'Barbarian King');
        expect(king.category, UpgradeCategory.homeBuilder);
        expect(king.itemType, LevelItemType.heroes);

        final lassi = CocDataIdCatalog.lookup(73000000);
        expect(lassi, isNotNull);
        expect(lassi!.name, 'L.A.S.S.I');
        expect(lassi.category, UpgradeCategory.homeBuilder);
        expect(lassi.itemType, LevelItemType.heroPets);

        final giantGauntlet = CocDataIdCatalog.lookup(88000008);
        expect(giantGauntlet, isNotNull);
        expect(giantGauntlet!.name, 'Giant Gauntlet');
      },
    );

    test('resolves builder base buildings, traps, troops, and heroes', () {
      final bh = CocDataIdCatalog.lookup(1000050);
      expect(bh, isNotNull);
      expect(bh!.name, 'Builder Hall');
      expect(bh.category, UpgradeCategory.builderBaseBuilder);

      final bbBarb = CocDataIdCatalog.lookup(4000030);
      expect(bbBarb, isNotNull);
      expect(bbBarb!.name, 'Raged Barbarian');
      expect(bbBarb.category, UpgradeCategory.builderBaseStarLab);
      expect(bbBarb.itemType, LevelItemType.troops);

      final battleMachine = CocDataIdCatalog.lookup(28000010);
      expect(battleMachine, isNotNull);
      expect(battleMachine!.name, 'Battle Machine');
      expect(battleMachine.category, UpgradeCategory.builderBaseBuilder);
      expect(battleMachine.itemType, LevelItemType.heroes);
    });

    test('gracefully handles normalized 7-digit IDs for high classes', () {
      // 2800000 -> 28000000 (King)
      final king = CocDataIdCatalog.lookup(2800000);
      expect(king, isNotNull);
      expect(king!.name, 'Barbarian King');

      // 7300000 -> 73000000 (L.A.S.S.I)
      final lassi = CocDataIdCatalog.lookup(7300000);
      expect(lassi, isNotNull);
      expect(lassi!.name, 'L.A.S.S.I');
    });

    test('returns null for unknown IDs', () {
      expect(CocDataIdCatalog.lookup(999999999), isNull);
    });
  });

  group('CocVillageJsonParser Tests', () {
    late DateTime testNow;
    late int snapshotTimestampSeconds;

    setUp(() {
      testNow = DateTime.utc(2026, 11, 1, 12, 0, 0);
      // Snapshot taken 1 hour ago
      snapshotTimestampSeconds =
          testNow.subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000;
    });

    test('parses full JSON structure with active timers and quantities', () {
      final jsonMap = {
        'tag': '#9LGQRQRV0',
        'timestamp': snapshotTimestampSeconds,
        'buildings': [
          {'data': 1000000, 'lvl': 16}, // Town Hall 16
          // Active timer: 2 hours from snapshot (1 hour in the future relative to testNow)
          {
            'data': 1000005,
            'lvl': 12,
            'timer': 7200,
          }, // Archer Tower lvl 12 -> 13
          // Expired timer: 30 minutes from snapshot (finished 30 minutes ago relative to testNow)
          {'data': 1000004, 'lvl': 11, 'timer': 1800}, // Cannon lvl 11
          // Walls with different levels: 40 level 13, 260 level 14
          {'data': 1000010, 'lvl': 13, 'cnt': 40},
          {'data': 1000010, 'lvl': 14, 'cnt': 260},
          // Unmapped item to test graceful preservation in preview
          {'data': 99999999, 'lvl': 5},
        ],
        'traps': [
          {'data': 1200000, 'lvl': 10}, // Bomb
        ],
        'units': [
          {'data': 4000000, 'lvl': 11}, // Barbarian
        ],
        'siege_machines': [
          {'data': 4000051, 'lvl': 4}, // Wall Wrecker
        ],
        'heroes': [
          {'data': 28000000, 'lvl': 90, 'timer': 10800}, // King upgrading to 91
        ],
        'spells': [
          {'data': 26000000, 'lvl': 9}, // Lightning Spell
        ],
        'pets': [
          {'data': 73000000, 'lvl': 9}, // L.A.S.S.I
        ],
        'equipment': [
          {'data': 88000008, 'lvl': 17}, // Giant Gauntlet
        ],
        'buildings2': [
          {'data': 1000050, 'lvl': 10}, // Builder Hall 10
        ],
        'traps2': [
          {'data': 1200051, 'lvl': 8}, // Push Trap
        ],
        'units2': [
          {'data': 4000030, 'lvl': 19}, // Raged Barbarian
        ],
        'heroes2': [
          {'data': 28000010, 'lvl': 34}, // Battle Machine
        ],
        'helpers': [
          // Helpers have helper timers which MUST be ignored for active upgrades
          {'data': 1, 'helper_timer': 3600, 'helper_cooldown': 7200},
        ],
        'decos': [
          {'data': 17000000},
        ],
        'obstacles': [
          {'data': 8000000},
        ],
        'boosts': {'training': 1800},
      };

      final parser = CocVillageJsonParser();
      final preview = parser.parse(jsonMap, referenceNow: testNow);

      expect(preview.tag, '#9LGQRQRV0');
      expect(preview.snapshotTimestamp, snapshotTimestampSeconds);
      expect(preview.detectedTownHallLevel, 16);
      expect(preview.detectedBuilderHallLevel, 10);

      // Verify Wall aggregation: Wall lvl 13 has quantity 40, Wall lvl 14 has quantity 260
      final wallLvl13 = preview.homeLevels.firstWhere(
        (it) => it.name == 'Wall' && it.level == 13,
      );
      expect(wallLvl13.quantity, 40);

      final wallLvl14 = preview.homeLevels.firstWhere(
        (it) => it.name == 'Wall' && it.level == 14,
      );
      expect(wallLvl14.quantity, 260);

      // Active upgrades (future completion):
      // 1. Archer Tower: snapshot + 7200 = snapshot + 2h. Since snapshot was 1h ago, 1h remains!
      expect(preview.activeUpgrades.length, 2); // Archer Tower and King
      final archerUpgrade = preview.activeUpgrades.firstWhere(
        (u) => u.name == 'Archer Tower',
      );
      expect(archerUpgrade.fromLevel, 12);
      expect(archerUpgrade.toLevel, 13);
      expect(
        archerUpgrade.remainingDurationSeconds,
        3600,
      ); // 7200 - 3600 elapsed

      final kingUpgrade = preview.activeUpgrades.firstWhere(
        (u) => u.name == 'Barbarian King',
      );
      expect(kingUpgrade.fromLevel, 90);
      expect(kingUpgrade.toLevel, 91);
      expect(
        kingUpgrade.remainingDurationSeconds,
        7200,
      ); // 10800 - 3600 elapsed

      // Expired timer (past completion):
      // Cannon: snapshot + 1800 = snapshot + 30m. Elapsed was 1h, so finished 30m ago!
      expect(preview.expiredTimers.length, 1);
      expect(preview.expiredTimers.first.name, 'Cannon');
      expect(
        preview.expiredTimers.first.expiredAtUtc.isBefore(testNow),
        isTrue,
      );

      // Verify unmapped items collected
      expect(preview.unmappedItems.length, 1);
      expect(preview.unmappedItems.first.dataId, 99999999);
      expect(preview.unmappedItems.first.level, 5);
    });

    test('parses nested modules in buildings correctly', () {
      final jsonMap = {
        'tag': '#NESTED',
        'timestamp': snapshotTimestampSeconds,
        'buildings': [
          {
            'data': 1000000,
            'lvl': 16,
            'types': [
              {
                'modules': [
                  {'data': 1000005, 'lvl': 10},
                ],
              },
            ],
          },
        ],
      };

      final parser = CocVillageJsonParser();
      final preview = parser.parse(jsonMap, referenceNow: testNow);
      expect(preview.homeLevels.any((it) => it.name == 'Archer Tower'), isTrue);
    });

    test('rejects invalid JSON or missing timestamps', () {
      final parser = CocVillageJsonParser();
      expect(
        () => parser.parse('invalid json {'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => parser.parse({'tag': '#123'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('CocVillageImportService Integration Tests', () {
    late AppDatabase db;
    late VillagesDao villagesDao;
    late VillageItemLevelsDao levelsDao;
    late UpgradesDao upgradesDao;
    late VillageImportsDao importsDao;
    late HistoryEventsDao historyEventsDao;
    late CocVillageImportService importService;

    final now = DateTime.utc(2026, 11, 1, 12, 0, 0);

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      villagesDao = VillagesDao(db);
      levelsDao = VillageItemLevelsDao(db);
      upgradesDao = UpgradesDao(db);
      importsDao = VillageImportsDao(db);
      historyEventsDao = HistoryEventsDao(db);

      importService = CocVillageImportService(
        db: db,
        villagesDao: villagesDao,
        levelsDao: levelsDao,
        upgradesDao: upgradesDao,
        importsDao: importsDao,
        historyEventsDao: historyEventsDao,
      );

      // Create test target village
      await villagesDao.upsert(
        Village(
          id: 'v-coc-1',
          name: 'Home Base',
          townHallLevel: 14,
          builderCapacity: 6,
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('performs Merge import: updates TH, preserves levels with quantities and adds active upgrades', () async {
      final targetVillage = (await villagesDao.findById('v-coc-1'))!;

      final preview = CocImportPreview(
        tag: '#9LGQRQRV0',
        snapshotTimestamp: 1793538499,
        snapshotDateTimeUtc: now.subtract(const Duration(hours: 1)),
        detectedTownHallLevel: 16,
        detectedBuilderHallLevel: 9,
        homeLevels: [
          const ParsedLevelItem(
            dataId: 1000010,
            name: 'Wall',
            category: UpgradeCategory.homeBuilder,
            itemType: LevelItemType.defences,
            level: 13,
            quantity: 40,
            realm: VillageRealm.homeVillage,
          ),
          const ParsedLevelItem(
            dataId: 1000010,
            name: 'Wall',
            category: UpgradeCategory.homeBuilder,
            itemType: LevelItemType.defences,
            level: 14,
            quantity: 260,
            realm: VillageRealm.homeVillage,
          ),
          const ParsedLevelItem(
            dataId: 28000001,
            name: 'Archer Queen',
            category: UpgradeCategory.homeBuilder,
            itemType: LevelItemType.heroes,
            level: 85,
            quantity: 1,
            realm: VillageRealm.homeVillage,
          ),
        ],
        builderLevels: const [],
        activeUpgrades: [
          ParsedActiveUpgrade(
            dataId: 28000001,
            name: 'Archer Queen',
            category: UpgradeCategory.homeBuilder,
            itemType: LevelItemType.heroes,
            fromLevel: 85,
            toLevel: 86,
            remainingDurationSeconds: 172800,
            expectedCompletionAtUtc: now.add(const Duration(days: 2)),
            startedAtUtc: now,
            realm: VillageRealm.homeVillage,
          ),
        ],
        expiredTimers: const [],
        unmappedItems: const [],
      );

      final result = await importService.executeImport(
        village: targetVillage,
        preview: preview,
        mode: 'merge',
        updateHallLevels: true,
      );

      expect(result.success, isTrue);
      expect(result.importedLevelsCount, 3);
      expect(result.importedUpgradesCount, 1);

      // Verify Town Hall level was updated
      final updatedVillage = await villagesDao.findById('v-coc-1');
      expect(updatedVillage!.townHallLevel, 16);

      // Verify levels persisted with quantities
      final levels = await levelsDao.getForVillage('v-coc-1');
      expect(levels.length, 3);

      final wall13 = levels.firstWhere(
        (l) => l.itemName == 'Wall' && l.currentLevel == 13,
      );
      expect(wall13.quantity, 40);

      final wall14 = levels.firstWhere(
        (l) => l.itemName == 'Wall' && l.currentLevel == 14,
      );
      expect(wall14.quantity, 260);

      // Verify active upgrade was scheduled
      final upgrades = await upgradesDao.getActiveForVillage('v-coc-1');
      expect(upgrades.length, 1);
      expect(upgrades.first.name, 'Archer Queen');
      expect(upgrades.first.toLevel, 86);

      // Verify import history recorded
      final latestImport = await importsDao.getLatestForVillage('v-coc-1');
      expect(latestImport, isNotNull);
      expect(latestImport!.villageTag, '#9LGQRQRV0');
      expect(latestImport.importMode, 'merge');
    });

    test('detects existing snapshot re-import', () async {
      final targetVillage = (await villagesDao.findById('v-coc-1'))!;

      final preview = CocImportPreview(
        tag: '#TAG1',
        snapshotTimestamp: 123456789,
        snapshotDateTimeUtc: now,
        detectedTownHallLevel: 15,
        detectedBuilderHallLevel: null,
        homeLevels: const [],
        builderLevels: const [],
        activeUpgrades: const [],
        expiredTimers: const [],
        unmappedItems: const [],
      );

      expect(
        await importService.hasExistingSnapshot(
          villageId: 'v-coc-1',
          snapshotTimestamp: 123456789,
        ),
        isFalse,
      );

      await importService.executeImport(
        village: targetVillage,
        preview: preview,
        mode: 'merge',
      );

      expect(
        await importService.hasExistingSnapshot(
          villageId: 'v-coc-1',
          snapshotTimestamp: 123456789,
        ),
        isTrue,
      );
    });

    test('Replace mode removes prior active upgrades and levels', () async {
      final targetVillage = (await villagesDao.findById('v-coc-1'))!;

      // Seed existing upgrade and level
      await levelsDao.upsert(
        VillageItemLevel(
          id: 'old-lvl',
          villageId: 'v-coc-1',
          category: UpgradeCategory.homeBuilder,
          itemName: 'Old Cannon',
          currentLevel: 5,
          updatedAtUtc: now,
        ),
      );

      await upgradesDao.upsert(
        Upgrade(
          id: 'old-up',
          villageId: 'v-coc-1',
          name: 'Old Cannon',
          category: UpgradeCategory.homeBuilder,
          startedAtUtc: now,
          expectedCompletionAtUtc: now.add(const Duration(hours: 5)),
          status: UpgradeStatus.active,
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );

      final preview = CocImportPreview(
        tag: '#REPLACE',
        snapshotTimestamp: 999999,
        snapshotDateTimeUtc: now,
        detectedTownHallLevel: 12,
        detectedBuilderHallLevel: null,
        homeLevels: [
          const ParsedLevelItem(
            dataId: 1000009,
            name: 'New Archer Tower',
            category: UpgradeCategory.homeBuilder,
            itemType: LevelItemType.defences,
            level: 8,
            quantity: 1,
            realm: VillageRealm.homeVillage,
          ),
        ],
        builderLevels: const [],
        activeUpgrades: const [],
        expiredTimers: const [],
        unmappedItems: const [],
      );

      await importService.executeImport(
        village: targetVillage,
        preview: preview,
        mode: 'replace',
      );

      final levels = await levelsDao.getForVillage('v-coc-1');
      expect(levels.length, 1);
      expect(levels.first.itemName, 'New Archer Tower');

      final activeUpgrades = await upgradesDao.getActiveForVillage('v-coc-1');
      expect(activeUpgrades.isEmpty, isTrue);
    });
  });

  group('BackupService Integration Tests', () {
    late AppDatabase db;
    late BackupService backupService;
    final now = DateTime.utc(2026, 11, 1, 12, 0, 0);

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'app_theme_mode': 'dark',
        'date_format_pref': 'ddMMyyyySlash',
      });

      db = AppDatabase.forTesting(NativeDatabase.memory());
      final villagesDao = VillagesDao(db);
      await villagesDao.upsert(
        Village(
          id: 'v-backup-1',
          name: 'Backup Ville',
          townHallLevel: 16,
          builderCapacity: 6,
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );

      backupService = BackupService(db: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('generates valid backup archive containing manifest, database, and preferences', () async {
      final zipBytes = await backupService.generateBackupArchiveBytes();
      expect(zipBytes.isNotEmpty, isTrue);

      final archive = ZipDecoder().decodeBytes(zipBytes);
      expect(archive.findFile('manifest.json'), isNotNull);
      expect(archive.findFile('database.json'), isNotNull);
      expect(archive.findFile('preferences.json'), isNotNull);

      final manifestJson = jsonDecode(
        utf8.decode(archive.findFile('manifest.json')!.content as List<int>),
      ) as Map<String, dynamic>;
      final manifest = BackupManifest.fromJson(manifestJson);

      expect(manifest.backupVersion, 1);
      expect(manifest.databaseSchemaVersion, db.schemaVersion);
      expect(manifest.villageCount, 1);
      expect(manifest.tables.containsKey('villages'), isTrue);
    });

    test('validates backup archive successfully for valid file', () async {
      final zipBytes = await backupService.generateBackupArchiveBytes();
      final tempFile = File(
        '${Directory.systemTemp.path}/test_backup.clashcommandbackup',
      );
      await tempFile.writeAsBytes(zipBytes);

      try {
        final validation = await backupService.validateBackupFile(tempFile);
        expect(validation.isValid, isTrue);
        expect(validation.manifest, isNotNull);
        expect(validation.manifest!.villageCount, 1);
      } finally {
        if (await tempFile.exists()) await tempFile.delete();
      }
    });

    test('rejects corrupt or invalid backup file', () async {
      final tempFile = File(
        '${Directory.systemTemp.path}/corrupt_backup.clashcommandbackup',
      );
      await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

      try {
        final validation = await backupService.validateBackupFile(tempFile);
        expect(validation.isValid, isFalse);
        expect(validation.error, isNotNull);
      } finally {
        if (await tempFile.exists()) await tempFile.delete();
      }
    });

    test(
      'creates safety backup before restore and restores full database state',
      () async {
        // 1. Generate backup
        final zipBytes = await backupService.generateBackupArchiveBytes();
        final tempFile = File(
          '${Directory.systemTemp.path}/valid_backup.clashcommandbackup',
        );
        await tempFile.writeAsBytes(zipBytes);

        try {
          // 2. Modify database to simulate changes or data loss
          final villagesDao = VillagesDao(db);
          await villagesDao.deleteVillage('v-backup-1');
          expect(await villagesDao.findById('v-backup-1'), isNull);

          // 3. Restore backup
          final restoreResult = await backupService.restoreFromFile(
            tempFile,
            createSafetyBackupFirst: true,
          );

          expect(restoreResult.success, isTrue);
          expect(restoreResult.safetyBackupFile, isNotNull);

          // Verify village was restored
          final restoredVillage = await villagesDao.findById('v-backup-1');
          expect(restoredVillage, isNotNull);
          expect(restoredVillage!.name, 'Backup Ville');

          // Verify safety backup was created and is valid
          if (restoreResult.safetyBackupFile != null &&
              await restoreResult.safetyBackupFile!.exists()) {
            final safetyValidation = await backupService.validateBackupFile(
              restoreResult.safetyBackupFile!,
            );
            expect(safetyValidation.isValid, isTrue);
            await restoreResult.safetyBackupFile!.delete();
          }
        } finally {
          if (await tempFile.exists()) await tempFile.delete();
        }
      },
    );
  });
}
