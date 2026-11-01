// ignore_for_file: deprecated_member_use
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/features/import/domain/coc_import_preview_model.dart';
import 'package:clash_command/features/import/domain/coc_village_json_parser.dart';
import 'package:clash_command/features/villages/application/villages_notifier.dart';

import 'import_history_sheet.dart';

/// Screen allowing users to import a Clash of Clans village JSON export via file picker or paste.
class ImportVillageScreen extends ConsumerStatefulWidget {
  const ImportVillageScreen({super.key, this.initialVillageId});

  final String? initialVillageId;

  @override
  ConsumerState<ImportVillageScreen> createState() =>
      _ImportVillageScreenState();
}

class _ImportVillageScreenState extends ConsumerState<ImportVillageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _pasteController = TextEditingController();

  bool _isParsing = false;
  bool _isImporting = false;
  String? _parseError;

  CocImportPreview? _preview;
  String? _selectedVillageId;
  bool _createNewVillage = false;
  String _importMode = 'merge'; // 'merge' or 'replace'
  final bool _updateHallLevels = true;
  bool _hasExistingSnapshot = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedVillageId = widget.initialVillageId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _isParsing = true;
      _parseError = null;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (file == null) {
        setState(() => _isParsing = false);
        return;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const FormatException('Selected file is empty or unreadable.');
      }

      final content = utf8.decode(bytes);
      await _processJson(content);
    } catch (e) {
      setState(() {
        _isParsing = false;
        _parseError = e.toString().replaceFirst('FormatException: ', '');
      });
    }
  }

  Future<void> _parsePastedJson() async {
    final text = _pasteController.text.trim();
    if (text.isEmpty) {
      setState(() => _parseError = 'Please paste your village JSON content.');
      return;
    }

    setState(() {
      _isParsing = true;
      _parseError = null;
    });

    try {
      await _processJson(text);
    } catch (e) {
      setState(() {
        _isParsing = false;
        _parseError = e.toString().replaceFirst('FormatException: ', '');
      });
    }
  }

  Future<void> _processJson(String jsonString) async {
    const parser = CocVillageJsonParser();
    final preview = parser.parse(jsonString);

    // Check if this snapshot was already imported for selected village
    bool duplicateFound = false;
    if (_selectedVillageId != null) {
      final existingImport = await ref
          .read(villageImportsDaoProvider)
          .findBySnapshot(_selectedVillageId!, preview.snapshotTimestamp);
      duplicateFound = existingImport != null;
    }

    if (mounted) {
      setState(() {
        _preview = preview;
        _isParsing = false;
        _parseError = null;
        _hasExistingSnapshot = duplicateFound;
      });
    }
  }

  Future<void> _executeImport(List<Village> villages) async {
    if (_preview == null) return;
    setState(() => _isImporting = true);

    try {
      Village targetVillage;

      if (_createNewVillage || villages.isEmpty || _selectedVillageId == null) {
        // Create new village from tag
        final villageName = _preview!.tag.isNotEmpty
            ? 'Village ${_preview!.tag}'
            : 'Imported Village';
        targetVillage = await ref
            .read(villagesNotifierProvider.notifier)
            .createVillage(
              name: villageName,
              townHallLevel: _preview!.detectedTownHallLevel,
              builderHallLevel: _preview!.detectedBuilderHallLevel,
              builderCapacity: 5,
              notes: 'Imported snapshot from tag ${_preview!.tag}',
            );
      } else {
        targetVillage = villages.firstWhere(
          (v) => v.id == _selectedVillageId,
          orElse: () => villages.first,
        );
      }

      final importService = ref.read(cocVillageImportServiceProvider);
      final result = await importService.executeImport(
        village: targetVillage,
        preview: _preview!,
        mode: _importMode,
        updateHallLevels: _updateHallLevels,
      );

      if (!result.success) {
        throw Exception(result.errorMessage ?? 'Import transaction failed.');
      }

      ref.read(audioServiceProvider).playConfirm();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.active),
                const SizedBox(width: 8),
                const Text('Import Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Village data for ${targetVillage.name} has been imported successfully.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text('• ${result.importedLevelsCount} item levels imported'),
                Text(
                  '• ${result.importedUpgradesCount} active upgrades scheduled',
                ),
                if (result.skippedUpgradesCount > 0)
                  Text(
                    '• ${result.skippedUpgradesCount} duplicate upgrades skipped',
                  ),
                if (result.expiredTimersCount > 0)
                  Text(
                    '• ${result.expiredTimersCount} expired timers preserved in levels',
                  ),
                if (result.unmappedItemsCount > 0)
                  Text(
                    '• ${result.unmappedItemsCount} unmapped items recorded',
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // close dialog
                  Navigator.pop(context); // close import screen
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final villagesAsync = ref.watch(villagesStreamProvider);
    final displayPrefs = ref.watch(displayPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Village Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Import History',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.surface,
                builder: (_) =>
                    ImportHistorySheet(villageId: _selectedVillageId),
              );
            },
          ),
        ],
      ),
      body: villagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (villages) {
          if (_selectedVillageId == null && villages.isNotEmpty) {
            _selectedVillageId = villages.first.id;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                if (_preview == null) ...[
                  _buildInputSelector(),
                ] else ...[
                  _buildPreviewCard(villages, displayPrefs),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clash of Clans JSON Export',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '100% offline. Imports Home Village & Builder Base buildings, troops, heroes, levels, and active countdown timers.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.file_present), text: 'Pick File'),
            Tab(icon: Icon(Icons.paste), text: 'Paste JSON'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Pick JSON File
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_drive_file_outlined,
                        size: 54,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Select a .json village export file',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Uses Android Document Picker. No data leaves your device.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isParsing ? null : _pickFile,
                        icon: _isParsing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.folder_open),
                        label: Text(
                          _isParsing ? 'Reading file...' : 'Choose JSON File',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab 2: Paste JSON Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pasteController,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText:
                            'Paste Clash of Clans village JSON export here...',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isParsing ? null : _parsePastedJson,
                      icon: _isParsing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.analytics_outlined),
                      label: Text(_isParsing ? 'Parsing...' : 'Analyze JSON'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_parseError != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _parseError!,
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewCard(
    List<Village> villages,
    DisplayPreferences displayPrefs,
  ) {
    final preview = _preview!;
    final snapshotStr = DateTimeFormat.shortDateTime(
      preview.snapshotDateTimeUtc,
      dateFormat: displayPrefs.dateFormat,
      timeFormat: displayPrefs.timeFormat,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action to re-select
        Row(
          children: [
            Text(
              'IMPORT PREVIEW',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.textMuted,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => setState(() => _preview = null),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Select another file'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Snapshot details card
        Card(
          color: AppColors.card,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        preview.tag,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (preview.detectedTownHallLevel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'TH ${preview.detectedTownHallLevel}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    if (preview.detectedBuilderHallLevel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'BH ${preview.detectedBuilderHallLevel}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Snapshot taken: $snapshotStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Stat summary chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(
                      label: '${preview.homeLevels.length} Home Items',
                      icon: Icons.fort_outlined,
                      color: AppColors.accent,
                    ),
                    _Chip(
                      label: '${preview.builderLevels.length} Builder Items',
                      icon: Icons.construction,
                      color: Colors.blueAccent,
                    ),
                    _Chip(
                      label: '${preview.activeUpgrades.length} Active Timers',
                      icon: Icons.timer,
                      color: AppColors.active,
                    ),
                    if (preview.expiredTimers.isNotEmpty)
                      _Chip(
                        label: '${preview.expiredTimers.length} Expired Timers',
                        icon: Icons.timer_off_outlined,
                        color: AppColors.pastDue,
                      ),
                    if (preview.unmappedItems.isNotEmpty)
                      _Chip(
                        label: '${preview.unmappedItems.length} Unmapped IDs',
                        icon: Icons.help_outline,
                        color: AppColors.textMuted,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Re-import warning if duplicate snapshot
        if (_hasExistingSnapshot) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pastDue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.pastDue.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.pastDue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Notice: A snapshot with this exact timestamp was previously imported for this village. Importing again will update existing values.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Target Village Selection
        Text(
          'TARGET VILLAGE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppColors.card,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (villages.isNotEmpty) ...[
                  RadioListTile<bool>(
                    title: const Text('Import into existing village profile'),
                    value: false,
                    groupValue: _createNewVillage,
                    onChanged: (val) =>
                        setState(() => _createNewVillage = false),
                  ),
                  if (!_createNewVillage)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32,
                        right: 16,
                        bottom: 8,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedVillageId,
                        decoration: const InputDecoration(
                          labelText: 'Select Village',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        dropdownColor: AppColors.surfaceVariant,
                        items: villages.map((v) {
                          return DropdownMenuItem(
                            value: v.id,
                            child: Text(v.name),
                          );
                        }).toList(),
                        onChanged: (id) {
                          setState(() => _selectedVillageId = id);
                        },
                      ),
                    ),
                ],
                RadioListTile<bool>(
                  title: Text('Create new village from tag (${preview.tag})'),
                  value: true,
                  groupValue: _createNewVillage,
                  onChanged: (val) => setState(() => _createNewVillage = true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Import Mode (Merge vs Replace)
        Text(
          'IMPORT MODE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppColors.card,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Merge (Recommended)'),
                  subtitle: const Text(
                    'Add or update imported levels and active upgrades. Preserves custom items and other categories.',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: 'merge',
                  groupValue: _importMode,
                  onChanged: (val) =>
                      setState(() => _importMode = val ?? 'merge'),
                ),
                const Divider(),
                RadioListTile<String>(
                  title: const Text('Replace Imported Data'),
                  subtitle: const Text(
                    'Replaces existing tracked levels and active upgrades for this village. Preserves notes, planner, and history.',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: 'replace',
                  groupValue: _importMode,
                  onChanged: (val) =>
                      setState(() => _importMode = val ?? 'replace'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Detailed Expansion Panels
        _buildExpansionDetails(preview, displayPrefs),
        const SizedBox(height: 24),

        // Confirm Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isImporting ? null : () => _executeImport(villages),
            icon: _isImporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(
              _isImporting ? 'Importing data...' : 'Confirm & Import Data',
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildExpansionDetails(
    CocImportPreview preview,
    DisplayPreferences displayPrefs,
  ) {
    return Card(
      color: AppColors.card,
      child: Column(
        children: [
          if (preview.activeUpgrades.isNotEmpty)
            ExpansionTile(
              title: Text(
                'Active Upgrades to Schedule (${preview.activeUpgrades.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              children: preview.activeUpgrades.map((up) {
                final endsAt = DateTimeFormat.shortDateTime(
                  up.expectedCompletionAtUtc,
                  dateFormat: displayPrefs.dateFormat,
                  timeFormat: displayPrefs.timeFormat,
                );
                return ListTile(
                  dense: true,
                  title: Text(up.name),
                  subtitle: Text(
                    '${up.levelProgression} · Finishes $endsAt',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.active.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.active,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          if (preview.expiredTimers.isNotEmpty)
            ExpansionTile(
              title: Text(
                'Expired Timers (${preview.expiredTimers.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              subtitle: const Text(
                'Finished prior to snapshot. Recorded in Levels without countdown.',
                style: TextStyle(fontSize: 11),
              ),
              children: preview.expiredTimers.map((exp) {
                return ListTile(
                  dense: true,
                  title: Text(exp.name),
                  subtitle: Text(
                    'Level ${exp.level}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  trailing: Text(
                    'COMPLETED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              }).toList(),
            ),
          ExpansionTile(
            title: Text(
              'Recognized Levels (${preview.totalLevelsCount})',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            children: [
              ...preview.homeLevels.take(30).map((lvl) {
                return ListTile(
                  dense: true,
                  title: Text(lvl.displayNameWithQuantity),
                  subtitle: Text(
                    '${lvl.itemType} (Home Village)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                );
              }),
              ...preview.builderLevels.take(30).map((lvl) {
                return ListTile(
                  dense: true,
                  title: Text(lvl.displayNameWithQuantity),
                  subtitle: Text(
                    '${lvl.itemType} (Builder Base)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                );
              }),
              if (preview.totalLevelsCount > 60)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '+ ${preview.totalLevelsCount - 60} more items...',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
            ],
          ),
          if (preview.unmappedItems.isNotEmpty)
            ExpansionTile(
              title: Text(
                'Unmapped / Unsupported IDs (${preview.unmappedItems.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              subtitle: const Text(
                'Items with unrecognized IDs preserved for inspection.',
                style: TextStyle(fontSize: 11),
              ),
              children: preview.unmappedItems.take(20).map((un) {
                return ListTile(
                  dense: true,
                  title: Text('Data ID: ${un.dataId}'),
                  subtitle: Text(
                    'Section: ${un.section} · Qty: ${un.quantity}${un.level != null ? ' · Lv. ${un.level}' : ''}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
