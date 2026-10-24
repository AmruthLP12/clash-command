import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/domain/catalog/upgrade_catalog.dart';
import 'package:clash_command/domain/catalog/upgrade_catalog_item.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/services/upgrade_timer_service.dart';
import 'package:clash_command/features/upgrades/application/upgrades_notifier.dart';

/// Bottom sheet for adding or editing an upgrade in a village.
class AddUpgradeSheet extends ConsumerStatefulWidget {
  const AddUpgradeSheet({
    super.key,
    required this.village,
    this.upgrade,
  });

  final Village village;
  final Upgrade? upgrade;

  bool get isEditing => upgrade != null;

  @override
  ConsumerState<AddUpgradeSheet> createState() => _AddUpgradeSheetState();
}

class _AddUpgradeSheetState extends ConsumerState<AddUpgradeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _fromLevelController;
  late final TextEditingController _toLevelController;
  late final TextEditingController _daysController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late final TextEditingController _slotController;
  late final TextEditingController _notesController;
  late UpgradeCategory _category;
  Duration _initialRemaining = Duration.zero;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final up = widget.upgrade;
    _nameController = TextEditingController(text: up?.name ?? '');
    _category = up?.category.primaryCategory ?? UpgradeCategory.homeBuilder;
    _fromLevelController = TextEditingController(
      text: up?.fromLevel != null ? '${up!.fromLevel}' : '',
    );
    _toLevelController = TextEditingController(
      text: up?.toLevel != null ? '${up!.toLevel}' : '',
    );
    _slotController = TextEditingController(text: up?.slotKey ?? '');
    _notesController = TextEditingController(text: up?.notes ?? '');

    if (up != null) {
      final now = DateTime.now().toUtc();
      const timerService = UpgradeTimerService();
      _initialRemaining = timerService.remainingTime(now, up);
      final days = _initialRemaining.inDays;
      final hours = _initialRemaining.inHours % 24;
      final minutes = _initialRemaining.inMinutes % 60;
      _daysController = TextEditingController(text: '$days');
      _hoursController = TextEditingController(text: '$hours');
      _minutesController = TextEditingController(text: '$minutes');
    } else {
      _daysController = TextEditingController(text: '0');
      _hoursController = TextEditingController(text: '0');
      _minutesController = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fromLevelController.dispose();
    _toLevelController.dispose();
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _slotController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Duration get _duration {
    final days = int.tryParse(_daysController.text) ?? 0;
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    return Duration(days: days, hours: hours, minutes: minutes);
  }

  bool get _durationValid => _duration > Duration.zero;

  void _onCatalogItemSelected(UpgradeCatalogItem item) {
    _nameController.text = item.name;
    // Suggest levels if none entered
    if (_fromLevelController.text.trim().isEmpty &&
        _toLevelController.text.trim().isEmpty) {
      if (item.minLevel > 0) {
        _fromLevelController.text = '${item.minLevel}';
        final next = item.suggestToLevel(item.minLevel);
        if (next != null) {
          _toLevelController.text = '$next';
        }
      }
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_durationValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duration must be greater than zero.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final slotKey = _slotController.text.trim().isEmpty
          ? null
          : _slotController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      final fromLevel = int.tryParse(_fromLevelController.text.trim());
      final toLevel = int.tryParse(_toLevelController.text.trim());

      if (widget.isEditing) {
        final up = widget.upgrade!;
        final now = DateTime.now().toUtc();

        DateTime? newExpectedCompletion;
        final diff = (_duration - _initialRemaining).inMinutes.abs();
        if (diff > 1) {
          newExpectedCompletion = now.add(_duration);
        }

        await ref.read(upgradesNotifierProvider.notifier).editUpgradeDetails(
              up,
              name: name,
              category: _category,
              slotKey: slotKey,
              clearSlotKey: slotKey == null,
              notes: notes,
              clearNotes: notes == null,
              fromLevel: fromLevel,
              clearFromLevel: fromLevel == null,
              toLevel: toLevel,
              clearToLevel: toLevel == null,
              newExpectedCompletionAtUtc: newExpectedCompletion,
            );
      } else {
        await ref.read(upgradesNotifierProvider.notifier).startUpgrade(
              villageId: widget.village.id,
              name: name,
              category: _category,
              duration: _duration,
              slotKey: slotKey,
              notes: notes,
              fromLevel: fromLevel,
              toLevel: toLevel,
            );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch custom suggestions for this category
    final customSuggestionsAsync =
        ref.watch(customUpgradeSuggestionsStreamProvider(_category));
    final customNames = (customSuggestionsAsync.valueOrNull ?? [])
        .map((e) => e.name)
        .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing
                    ? 'Edit upgrade'
                    : 'Track upgrade — ${widget.village.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Category picker (4 primary facilities)
              DropdownButtonFormField<UpgradeCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Facility & Category',
                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                ),
                dropdownColor: AppColors.surfaceVariant,
                items: UpgradeCategory.primaryCategories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c.displayName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _category = v);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Autocomplete upgrade name
              RawAutocomplete<UpgradeCatalogItem>(
                textEditingController: _nameController,
                focusNode: FocusNode(),
                displayStringForOption: (item) => item.name,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return UpgradeCatalog.search(
                    query: textEditingValue.text,
                    category: _category,
                    townHallLevel: widget.village.townHallLevel,
                    customNames: customNames,
                  );
                },
                onSelected: _onCatalogItemSelected,
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Upgrade name *',
                      hintText: 'e.g. Archer Tower, P.E.K.K.A',
                      prefixIcon:
                          const Icon(Icons.arrow_upward_outlined, size: 20),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                controller.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                    textCapitalization: TextCapitalization.words,
                    onFieldSubmitted: (v) => onFieldSubmitted(),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.surfaceVariant,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 220,
                          maxWidth: 340,
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, color: AppColors.surface),
                          itemBuilder: (context, index) {
                            final item = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(item),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (item.subtitle.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: Text(
                                                item.subtitle,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (item.isCustom)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Custom',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Optional Level row (From Level -> To Level)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fromLevelController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'From Level (opt)',
                        hintText: 'e.g. 18',
                      ),
                      onChanged: (val) {
                        final fromN = int.tryParse(val.trim());
                        if (fromN != null &&
                            _toLevelController.text.trim().isEmpty) {
                          _toLevelController.text = '${fromN + 1}';
                        }
                      },
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = int.tryParse(v.trim());
                        if (n == null || n <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Icon(Icons.arrow_forward,
                        size: 18, color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _toLevelController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'To Level (opt)',
                        hintText: 'e.g. 19',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = int.tryParse(v.trim());
                        if (n == null || n <= 0) return 'Must be > 0';
                        final fromN =
                            int.tryParse(_fromLevelController.text.trim());
                        if (fromN != null && n <= fromN) {
                          return 'Must be > From ($fromN)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Duration row
              Text(
                widget.isEditing ? 'Remaining duration *' : 'Duration *',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _DurationField(
                      controller: _daysController,
                      label: 'Days',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DurationField(
                      controller: _hoursController,
                      label: 'Hours',
                      max: 23,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DurationField(
                      controller: _minutesController,
                      label: 'Min',
                      max: 59,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Builder / slot
              TextFormField(
                controller: _slotController,
                decoration: const InputDecoration(
                  labelText: 'Builder / slot (optional)',
                  hintText: 'e.g. Builder 1, Master Builder, Lab Slot',
                ),
              ),
              const SizedBox(height: 6),
              // Builder quick chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: List.generate(
                  widget.village.builderCapacity,
                  (i) {
                    final label = 'Builder ${i + 1}';
                    return ActionChip(
                      label: Text(label, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.surfaceVariant,
                      onPressed: () {
                        setState(() => _slotController.text = label);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g. Book of Building ready',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          widget.isEditing
                              ? 'Save changes'
                              : 'Start tracking',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.controller,
    required this.label,
    this.max,
  });

  final TextEditingController controller;
  final String label;
  final int? max;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        final n = int.tryParse(v ?? '');
        if (n == null || n < 0) return '≥ 0';
        if (max != null && n > max!) return '≤ $max';
        return null;
      },
    );
  }
}
