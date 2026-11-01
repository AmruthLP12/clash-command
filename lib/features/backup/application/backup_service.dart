import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clash_command/database/app_database.dart';
import 'package:clash_command/services/notifications/notification_reconciler.dart';
import 'package:clash_command/services/widgets/home_widget_sync_service.dart';

import '../domain/backup_manifest.dart';

/// Validation report produced prior to restoring a backup file.
class BackupValidationResult {
  const BackupValidationResult({
    required this.isValid,
    this.manifest,
    this.databaseData,
    this.preferencesData,
    this.errorMessage,
  });

  final bool isValid;
  final BackupManifest? manifest;
  final Map<String, dynamic>? databaseData;
  final Map<String, dynamic>? preferencesData;
  final String? errorMessage;

  String? get error => errorMessage;
}

/// Result of a backup file restore operation.
class RestoreResult {
  const RestoreResult({
    required this.success,
    this.safetyBackupFile,
    this.errorMessage,
  });

  final bool success;
  final File? safetyBackupFile;
  final String? errorMessage;
}

/// Service managing full portable application backups (.clashcommandbackup) and safe restorations.
class BackupService {
  const BackupService({
    required this.db,
    this.notificationReconciler,
    this.homeWidgetSyncService,
  });

  final AppDatabase db;
  final NotificationReconciler? notificationReconciler;
  final HomeWidgetSyncService? homeWidgetSyncService;

  static const String fileExtension = 'clashcommandbackup';
  static const String keyLastBackupDate = 'pref_last_backup_date';

  /// Generates the raw portable `.clashcommandbackup` ZIP bytes in memory.
  Future<Uint8List> createBackupArchiveBytes() async {
    final now = DateTime.now().toUtc();

    // 1. Fetch all records from all tables
    final villages = await (db.select(db.villages)).get();
    final upgrades = await (db.select(db.upgrades)).get();
    final levels = await (db.select(db.villageItemLevels)).get();
    final planner = await (db.select(db.plannerItems)).get();
    final history = await (db.select(db.historyEvents)).get();
    final suggestions = await (db.select(db.customUpgradeSuggestions)).get();
    final imports = await (db.select(db.villageImports)).get();
    final notifPrefs = await (db.select(db.notificationPreferences)).get();

    final recordCounts = {
      'villages': villages.length,
      'upgrades': upgrades.length,
      'villageItemLevels': levels.length,
      'plannerItems': planner.length,
      'historyEvents': history.length,
      'customUpgradeSuggestions': suggestions.length,
      'villageImports': imports.length,
      'notificationPreferences': notifPrefs.length,
    };

    // 2. Build manifest
    final manifest = BackupManifest(
      appName: BackupManifest.currentAppName,
      appVersion: BackupManifest.currentAppVersion,
      backupFormatVersion: BackupManifest.currentBackupFormatVersion,
      createdAtUtc: now,
      databaseSchemaVersion: BackupManifest.currentDatabaseSchemaVersion,
      recordCounts: recordCounts,
    );

    // 3. Serialize database rows
    final fullDatabaseMap = {
      'villages': villages.map((r) => r.toJson()).toList(),
      'upgrades': upgrades.map((r) => r.toJson()).toList(),
      'villageItemLevels': levels.map((r) => r.toJson()).toList(),
      'plannerItems': planner.map((r) => r.toJson()).toList(),
      'historyEvents': history.map((r) => r.toJson()).toList(),
      'customUpgradeSuggestions': suggestions.map((r) => r.toJson()).toList(),
      'villageImports': imports.map((r) => r.toJson()).toList(),
      'notificationPreferences': notifPrefs.map((r) => r.toJson()).toList(),
    };

    // 4. Collect user preferences from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final prefsMap = <String, dynamic>{};
    for (final key in prefs.getKeys()) {
      final val = prefs.get(key);
      if (val is String || val is int || val is double || val is bool) {
        prefsMap[key] = val;
      }
    }

    // 5. Build ZIP archive
    final archive = Archive();

    final manifestBytes = utf8.encode(jsonEncode(manifest.toJson()));
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );

    final dbBytes = utf8.encode(jsonEncode(fullDatabaseMap));
    archive.addFile(ArchiveFile('database.json', dbBytes.length, dbBytes));

    final prefBytes = utf8.encode(jsonEncode(prefsMap));
    archive.addFile(
      ArchiveFile('preferences.json', prefBytes.length, prefBytes),
    );

    final zipEncoder = ZipEncoder();
    final encoded = zipEncoder.encode(archive);
    return Uint8List.fromList(encoded);
  }

  /// Alias for [createBackupArchiveBytes].
  Future<Uint8List> generateBackupArchiveBytes() => createBackupArchiveBytes();

  /// Exports backup archive and prompts the user to save to device storage.
  Future<String?> exportBackupWithFilePicker() async {
    final bytes = await createBackupArchiveBytes();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final fileName = 'clash_command_backup_$dateStr.$fileExtension';

    // Allow user to select destination file path via document picker
    String? outputPath;
    try {
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Save Clash Command Backup',
        fileName: fileName,
        bytes: bytes,
      );
      if (uri != null) {
        outputPath = uri.isScheme('file') ? uri.toFilePath() : uri.path;
      }
    } catch (_) {}

    // Fallback if saveFile returns null or is unsupported: save to app documents / backups
    if (outputPath == null) {
      final docDir = await _getBaseDirectory();
      final backupDir = Directory(p.join(docDir.path, 'backups'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      final file = File(p.join(backupDir.path, fileName));
      await file.writeAsBytes(bytes);
      outputPath = file.path;
    }

    // Update last backup date preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        keyLastBackupDate,
        DateTime.now().toUtc().toIso8601String(),
      );
    } catch (_) {}

    return outputPath;
  }

  /// Validates a raw backup archive before restoration.
  BackupValidationResult validateBackup(List<int> archiveBytes) {
    try {
      if (archiveBytes.isEmpty) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'The selected backup file is empty.',
        );
      }

      final archive = ZipDecoder().decodeBytes(archiveBytes);

      // Check manifest.json
      final manifestFile = archive.findFile('manifest.json');
      if (manifestFile == null) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'Invalid backup: missing manifest.json.',
        );
      }

      final manifestString = utf8.decode(manifestFile.content as List<int>);
      final manifestJson = jsonDecode(manifestString) as Map<String, dynamic>;
      final manifest = BackupManifest.fromJson(manifestJson);

      if (manifest.appName != BackupManifest.currentAppName) {
        return BackupValidationResult(
          isValid: false,
          errorMessage:
              'Incompatible backup application: "${manifest.appName}". Expected "${BackupManifest.currentAppName}".',
        );
      }

      if (manifest.backupFormatVersion >
          BackupManifest.currentBackupFormatVersion) {
        return BackupValidationResult(
          isValid: false,
          errorMessage:
              'Backup format version ${manifest.backupFormatVersion} is newer than supported format (${BackupManifest.currentBackupFormatVersion}). Please update the app.',
        );
      }

      // Check database.json
      final dbFile = archive.findFile('database.json');
      if (dbFile == null) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'Invalid backup: missing database.json.',
        );
      }

      final dbString = utf8.decode(dbFile.content as List<int>);
      final dbJson = jsonDecode(dbString) as Map<String, dynamic>;

      // Check preferences.json if present
      Map<String, dynamic>? prefJson;
      final prefFile = archive.findFile('preferences.json');
      if (prefFile != null) {
        try {
          final prefString = utf8.decode(prefFile.content as List<int>);
          prefJson = jsonDecode(prefString) as Map<String, dynamic>;
        } catch (_) {}
      }

      return BackupValidationResult(
        isValid: true,
        manifest: manifest,
        databaseData: dbJson,
        preferencesData: prefJson,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: 'Corrupted or unsupported backup file: $e',
      );
    }
  }

  /// Validates a backup file from disk.
  Future<BackupValidationResult> validateBackupFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return validateBackup(bytes);
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: 'Failed to read file: $e',
      );
    }
  }

  Future<Directory> _getBaseDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return Directory.systemTemp;
    }
  }

  /// Creates a safety backup inside the local app documents directory before destructive restore.
  Future<File> createSafetyBackup() async {
    final bytes = await createBackupArchiveBytes();
    final docDir = await _getBaseDirectory();
    final safetyDir = Directory(p.join(docDir.path, 'safety_backups'));
    if (!await safetyDir.exists()) {
      await safetyDir.create(recursive: true);
    }
    final file = File(
      p.join(safetyDir.path, 'safety_pre_restore.$fileExtension'),
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Restores complete application database state and preferences from an archive.
  Future<void> restoreFromArchive(
    List<int> archiveBytes, {
    String mode = 'full',
    bool createSafetyBackupFirst = true,
  }) async {
    final validation = validateBackup(archiveBytes);
    if (!validation.isValid) {
      throw FormatException(validation.errorMessage ?? 'Invalid backup file.');
    }

    final dbData = validation.databaseData!;
    final prefData = validation.preferencesData;

    // 1. Automatically create safety backup first if requested
    if (createSafetyBackupFirst) {
      await createSafetyBackup();
    }

    // 2. Perform restoration in a single atomic database transaction
    await db.transaction(() async {
      // Clear existing records in correct foreign-key deletion order
      await (db.delete(db.upgrades)).go();
      await (db.delete(db.villageItemLevels)).go();
      await (db.delete(db.plannerItems)).go();
      await (db.delete(db.historyEvents)).go();
      await (db.delete(db.villageImports)).go();
      await (db.delete(db.customUpgradeSuggestions)).go();
      await (db.delete(db.villages)).go();
      await (db.delete(db.notificationPreferences)).go();

      // Restore Villages
      final rawVillages = dbData['villages'] as List<dynamic>? ?? [];
      for (final raw in rawVillages) {
        if (raw is Map<String, dynamic>) {
          await db.into(db.villages).insert(VillageRow.fromJson(raw));
        }
      }

      // Restore Upgrades
      final rawUpgrades = dbData['upgrades'] as List<dynamic>? ?? [];
      for (final raw in rawUpgrades) {
        if (raw is Map<String, dynamic>) {
          await db.into(db.upgrades).insert(UpgradeRow.fromJson(raw));
        }
      }

      // Restore VillageItemLevels
      final rawLevels = dbData['villageItemLevels'] as List<dynamic>? ?? [];
      for (final raw in rawLevels) {
        if (raw is Map<String, dynamic>) {
          await db
              .into(db.villageItemLevels)
              .insert(VillageItemLevelRow.fromJson(raw));
        }
      }

      // Restore PlannerItems
      final rawPlanner = dbData['plannerItems'] as List<dynamic>? ?? [];
      for (final raw in rawPlanner) {
        if (raw is Map<String, dynamic>) {
          await db.into(db.plannerItems).insert(PlannerItemRow.fromJson(raw));
        }
      }

      // Restore HistoryEvents
      final rawHistory = dbData['historyEvents'] as List<dynamic>? ?? [];
      for (final raw in rawHistory) {
        if (raw is Map<String, dynamic>) {
          await db.into(db.historyEvents).insert(HistoryEventRow.fromJson(raw));
        }
      }

      // Restore CustomUpgradeSuggestions
      final rawSuggestions =
          dbData['customUpgradeSuggestions'] as List<dynamic>? ?? [];
      for (final raw in rawSuggestions) {
        if (raw is Map<String, dynamic>) {
          await db
              .into(db.customUpgradeSuggestions)
              .insert(CustomUpgradeSuggestionRow.fromJson(raw));
        }
      }

      // Restore VillageImports
      final rawImports = dbData['villageImports'] as List<dynamic>? ?? [];
      for (final raw in rawImports) {
        if (raw is Map<String, dynamic>) {
          await db
              .into(db.villageImports)
              .insert(VillageImportRow.fromJson(raw));
        }
      }

      // Restore NotificationPreferences
      final rawNotif =
          dbData['notificationPreferences'] as List<dynamic>? ?? [];
      for (final raw in rawNotif) {
        if (raw is Map<String, dynamic>) {
          await db
              .into(db.notificationPreferences)
              .insert(NotificationPreference.fromJson(raw));
        }
      }
    });

    // 3. Restore preferences if available
    if (prefData != null && prefData.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in prefData.entries) {
        final val = entry.value;
        if (val is String) {
          await prefs.setString(entry.key, val);
        } else if (val is int) {
          await prefs.setInt(entry.key, val);
        } else if (val is double) {
          await prefs.setDouble(entry.key, val);
        } else if (val is bool) {
          await prefs.setBool(entry.key, val);
        }
      }
    }

    // 4. Reconcile notifications and sync home-screen widgets with restored state
    if (notificationReconciler != null) {
      await notificationReconciler!.reconcile();
    }
    if (homeWidgetSyncService != null) {
      await homeWidgetSyncService!.syncWidgets();
    }
  }

  /// Restores complete state from a file.
  Future<RestoreResult> restoreFromFile(
    File file, {
    bool createSafetyBackupFirst = true,
  }) async {
    try {
      File? safetyBackup;
      if (createSafetyBackupFirst) {
        safetyBackup = await createSafetyBackup();
      }
      final bytes = await file.readAsBytes();
      await restoreFromArchive(bytes, createSafetyBackupFirst: false);
      return RestoreResult(success: true, safetyBackupFile: safetyBackup);
    } catch (e) {
      return RestoreResult(success: false, errorMessage: e.toString());
    }
  }

  /// Gets the formatted timestamp of the last successful backup.
  static Future<String?> getLastBackupDateString() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(keyLastBackupDate);
    } catch (_) {
      return null;
    }
  }
}
