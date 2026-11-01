import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';

/// Modal dialogs and workflows for executing application backup and restoration.
class BackupRestoreDialogs {
  const BackupRestoreDialogs._();

  /// Prompts user to create a portable `.clashcommandbackup` archive.
  static Future<void> showCreateBackupWorkflow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating portable backup...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final backupService = ref.read(backupServiceProvider);
      final outputPath = await backupService.exportBackupWithFilePicker();

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading

        if (outputPath != null) {
          ref.read(audioServiceProvider).playConfirm();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.active),
                  const SizedBox(width: 8),
                  const Text('Backup Created'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your portable backup archive has been generated successfully.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      outputPath,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Prompts user to select and validate a `.clashcommandbackup` file, then restores it.
  static Future<void> showRestoreWorkflow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['clashcommandbackup', 'zip'],
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const FormatException(
          'Selected backup file is empty or unreadable.',
        );
      }

      final backupService = ref.read(backupServiceProvider);
      final validation = backupService.validateBackup(bytes);

      if (!validation.isValid) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  const Text('Invalid Backup File'),
                ],
              ),
              content: Text(
                validation.errorMessage ?? 'The selected file is not a valid Clash Command backup archive.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final manifest = validation.manifest!;
      final displayPrefs = ref.read(displayPreferencesProvider);
      final dateStr = DateTimeFormat.shortDateTime(
        manifest.createdAtUtc,
        dateFormat: displayPrefs.dateFormat,
        timeFormat: displayPrefs.timeFormat,
      );

      if (!context.mounted) return;

      // Show Restore Confirmation Dialog
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Restore Application Backup'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to restore this backup created on $dateStr?',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backup Content Summary:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...manifest.recordCounts.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: const TextStyle(fontSize: 12)),
                              Text(
                                '${e.value}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.pastDue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.pastDue.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'Safety Notice: A safety backup of your current database will be saved automatically to app storage before restoration starts.',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pastDue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                await _performRestoration(context, ref, bytes as dynamic);
              },
              child: const Text('Confirm Restore'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selection failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  static Future<void> _performRestoration(
    BuildContext context,
    WidgetRef ref,
    List<int> bytes,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Restoring application database...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.restoreFromArchive(bytes as dynamic);

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ref.read(audioServiceProvider).playConfirm();

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.active),
                const SizedBox(width: 8),
                const Text('Restoration Complete'),
              ],
            ),
            content: const Text(
              'Your Clash Command database and preferences have been restored successfully. Upgrade timers and notifications are synchronized.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restoration failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
