import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';
import 'package:clash_command/domain/models/village_import.dart';

/// Bottom sheet displaying past Clash of Clans village imports.
class ImportHistorySheet extends ConsumerWidget {
  const ImportHistorySheet({super.key, this.villageId});

  final String? villageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importsAsync = villageId != null
        ? ref.watch(villageImportsStreamProvider(villageId!))
        : ref.watch(allVillageImportsStreamProvider);
    final displayPrefs = ref.watch(displayPreferencesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Icon(Icons.history_edu, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Import History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: importsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Error loading import history: $e')),
                  data: (imports) {
                    if (imports.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.file_upload_outlined,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No Imports Yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Import a Clash of Clans JSON export to track your village levels and active timers.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: imports.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = imports[index];
                        return _ImportHistoryTile(
                          importRecord: item,
                          dateFormat: displayPrefs.dateFormat,
                          timeFormat: displayPrefs.timeFormat,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImportHistoryTile extends StatelessWidget {
  const _ImportHistoryTile({
    required this.importRecord,
    required this.dateFormat,
    required this.timeFormat,
  });

  final VillageImport importRecord;
  final DateFormatPreference dateFormat;
  final TimeFormatPreference timeFormat;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateTimeFormat.shortDateTime(
      importRecord.importedAtUtc,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
    );
    final snapshotStr = DateTimeFormat.shortDateTime(
      importRecord.snapshotDateTimeUtc,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
    );

    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColors.surfaceVariant.withValues(alpha: 0.8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    importRecord.villageTag,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    importRecord.importMode.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatBadge(
                  label: '${importRecord.importedRecordCount} levels',
                  icon: Icons.layers_outlined,
                ),
                const SizedBox(width: 10),
                _StatBadge(
                  label: '${importRecord.activeUpgradesCount} timers',
                  icon: Icons.timelapse,
                  color: importRecord.activeUpgradesCount > 0
                      ? AppColors.active
                      : AppColors.textSecondary,
                ),
                if (importRecord.skippedRecordCount > 0) ...[
                  const SizedBox(width: 10),
                  _StatBadge(
                    label: '${importRecord.skippedRecordCount} skipped',
                    icon: Icons.info_outline,
                    color: AppColors.textMuted,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Snapshot: $snapshotStr',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.icon, this.color});

  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
