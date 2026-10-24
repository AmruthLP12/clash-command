import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/ids/id_generator.dart';
import 'package:clash_command/domain/catalog/upgrade_catalog.dart';
import 'package:clash_command/domain/catalog/upgrade_catalog_item.dart';
import 'package:clash_command/domain/models/planner_item.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/features/upgrades/presentation/add_upgrade_sheet.dart';

/// Bottom sheet for adding or editing a planned upgrade.
class AddPlannerSheet extends ConsumerStatefulWidget {
  const AddPlannerSheet({
    super.key,
    required this.village,
    this.item,
    this.initialCategory,
  });

  final Village village;
  final PlannerItem? item;
  final UpgradeCategory? initialCategory;

  bool get isEditing => item != null;

  @override
  ConsumerState<AddPlannerSheet> createState() => _AddPlannerSheetState();
}

class _AddPlannerSheetState extends ConsumerState<AddPlannerSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  late final TextEditingController _levelController;
  late final FocusNode _levelFocusNode;
  late final TextEditingController _notesController;

  // Duration controllers
  late final TextEditingController _daysController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;

  // Resource controllers
  late final TextEditingController _resourceAmountController;
  late String _selectedResourceType;
  late List<PlannerResource> _resources;

  late VillageRealm _realm;
  late UpgradeCategory _category;
  String _priority = 'Medium';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    _nameController = TextEditingController(text: it?.name ?? '');
    _nameFocusNode = FocusNode();
    _levelController = TextEditingController(
      text: it?.targetLevel != null ? '${it!.targetLevel}' : '',
    );
    _levelFocusNode = FocusNode();
    _notesController = TextEditingController(text: it?.notes ?? '');

    // Initialize duration
    final durSec = it?.durationSeconds;
    if (durSec != null && durSec > 0) {
      final dur = Duration(seconds: durSec);
      _daysController = TextEditingController(
          text: dur.inDays > 0 ? '${dur.inDays}' : '');
      _hoursController = TextEditingController(
          text: dur.inHours.remainder(24) > 0
              ? '${dur.inHours.remainder(24)}'
              : '');
      _minutesController = TextEditingController(
          text: dur.inMinutes.remainder(60) > 0
              ? '${dur.inMinutes.remainder(60)}'
              : '');
    } else {
      _daysController = TextEditingController();
      _hoursController = TextEditingController();
      _minutesController = TextEditingController();
    }

    _category = it?.category.primaryCategory ??
        widget.initialCategory?.primaryCategory ??
        UpgradeCategory.homeBuilder;

    _realm = (_category == UpgradeCategory.builderBaseBuilder ||
            _category == UpgradeCategory.builderBaseStarLab)
        ? VillageRealm.builderBase
        : VillageRealm.homeVillage;

    _priority = it?.priority ?? 'Medium';

    // Resources
    _resources = List.from(it?.resources ?? []);
    _resourceAmountController = TextEditingController();
    _selectedResourceType = _defaultResourceTypeForRealm(_realm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _levelController.dispose();
    _levelFocusNode.dispose();
    _notesController.dispose();
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _resourceAmountController.dispose();
    super.dispose();
  }

  String _defaultResourceTypeForRealm(VillageRealm realm) {
    return realm == VillageRealm.homeVillage ? 'Gold' : 'Builder Gold';
  }

  List<String> _resourceOptionsForRealm(VillageRealm realm) {
    if (realm == VillageRealm.homeVillage) {
      return const ['Gold', 'Elixir', 'Dark Elixir'];
    }
    return const ['Builder Gold', 'Builder Elixir'];
  }

  void _onRealmChanged(VillageRealm realm) {
    if (_realm == realm) return;
    setState(() {
      _realm = realm;
      _category = (realm == VillageRealm.homeVillage)
          ? UpgradeCategory.homeBuilder
          : UpgradeCategory.builderBaseBuilder;
      _selectedResourceType = _defaultResourceTypeForRealm(realm);
    });
  }

  void _onCategoryChanged(UpgradeCategory cat) {
    if (_category == cat) return;
    setState(() {
      _category = cat;
      _realm = (cat == UpgradeCategory.builderBaseBuilder ||
              cat == UpgradeCategory.builderBaseStarLab)
          ? VillageRealm.builderBase
          : VillageRealm.homeVillage;
      _selectedResourceType = _defaultResourceTypeForRealm(_realm);
    });
  }

  void _onCatalogItemSelected(UpgradeCatalogItem item) {
    _nameController.text = item.name;
    final suggested = item.suggestToLevel(null);
    if (suggested != null) {
      _levelController.text = '$suggested';
    }
    // Auto-detect realm & category
    final targetCat = item.category.primaryCategory;
    final targetRealm =
        (targetCat == UpgradeCategory.builderBaseBuilder ||
                targetCat == UpgradeCategory.builderBaseStarLab)
            ? VillageRealm.builderBase
            : VillageRealm.homeVillage;
    setState(() {
      _category = targetCat;
      _realm = targetRealm;
      _selectedResourceType = _defaultResourceTypeForRealm(_realm);
    });
  }

  void _addResource() {
    final amtText = _resourceAmountController.text.trim();
    if (amtText.isEmpty) return;
    final amount = int.tryParse(amtText);
    if (amount == null || amount <= 0) return;

    setState(() {
      // Remove any previous requirement with the same resource type to replace it
      _resources.removeWhere((r) => r.type == _selectedResourceType);
      _resources.add(PlannerResource(
        type: _selectedResourceType,
        amount: amount,
      ));
      _resourceAmountController.clear();
    });
  }

  void _removeResource(int index) {
    setState(() {
      _resources.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final levelText = _levelController.text.trim();
      final targetLevel =
          levelText.isNotEmpty ? int.tryParse(levelText) : null;
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      final now = DateTime.now().toUtc();

      // Duration in seconds
      final d = int.tryParse(_daysController.text.trim()) ?? 0;
      final h = int.tryParse(_hoursController.text.trim()) ?? 0;
      final m = int.tryParse(_minutesController.text.trim()) ?? 0;
      final totalSec = d * 86400 + h * 3600 + m * 60;
      final durationSeconds = totalSec > 0 ? totalSec : null;

      if (widget.isEditing) {
        final updated = widget.item!.copyWith(
          category: _category,
          name: name,
          targetLevel: targetLevel,
          clearTargetLevel: targetLevel == null,
          priority: _priority,
          notes: notes,
          clearNotes: notes == null,
          durationSeconds: durationSeconds,
          clearDurationSeconds: durationSeconds == null,
          resources: _resources,
          updatedAtUtc: now,
        );
        await ref.read(plannerDaoProvider).upsert(updated);
      } else {
        final newItem = PlannerItem(
          id: const IdGenerator().newId(),
          villageId: widget.village.id,
          category: _category,
          name: name,
          targetLevel: targetLevel,
          priority: _priority,
          notes: notes,
          sortOrder: 9999, // Placed at the end by default
          status: 'planned',
          isNext: false,
          durationSeconds: durationSeconds,
          resources: _resources,
          createdAtUtc: now,
          updatedAtUtc: now,
        );
        await ref.read(plannerDaoProvider).upsert(newItem);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customSuggestionsAsync =
        ref.watch(customUpgradeSuggestionsStreamProvider(_category));
    final customNames = (customSuggestionsAsync.valueOrNull ?? [])
        .map((e) => e.name)
        .toList();

    final resourceTypes = _resourceOptionsForRealm(_realm);
    if (!resourceTypes.contains(_selectedResourceType)) {
      _selectedResourceType = resourceTypes.first;
    }

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.isEditing
                              ? 'Edit planned upgrade'
                              : 'Plan upgrade — ${widget.village.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Realm switcher
                  SegmentedButton<VillageRealm>(
                    segments: [
                      ButtonSegment(
                        value: VillageRealm.homeVillage,
                        label: const Text('Home Village'),
                        icon: Icon(VillageRealm.homeVillage.icon, size: 16),
                      ),
                      ButtonSegment(
                        value: VillageRealm.builderBase,
                        label: const Text('Builder Base'),
                        icon: Icon(VillageRealm.builderBase.icon, size: 16),
                      ),
                    ],
                    selected: {_realm},
                    onSelectionChanged: (set) => _onRealmChanged(set.first),
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category selector
                  _buildCategorySelector(),
                  const SizedBox(height: 12),

                  // Item Name with Autocomplete
                  RawAutocomplete<UpgradeCatalogItem>(
                    textEditingController: _nameController,
                    focusNode: _nameFocusNode,
                    displayStringForOption: (item) => item.name,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return UpgradeCatalog.search(
                        query: textEditingValue.text,
                        category: _category,
                        townHallLevel: widget.village.townHallLevel,
                        builderHallLevel: widget.village.builderHallLevel,
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
                          hintText: 'e.g. Archer Tower, Town Hall, Barbarian',
                          prefixIcon:
                              const Icon(Icons.shield_outlined, size: 20),
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
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 8,
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 180,
                              maxWidth: MediaQuery.of(context).size.width - 32,
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, i) {
                                final opt = options.elementAt(i);
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    opt.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    opt.isCustom
                                        ? 'Custom · ${_category.displayName}'
                                        : '${opt.type}${opt.maxLevel != null ? ' · Max Lv. ${opt.maxLevel}' : ''}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  onTap: () => onSelected(opt),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Target Level & Priority Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target Level
                      Expanded(
                        child: TextFormField(
                          controller: _levelController,
                          focusNode: _levelFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Target level (opt.)',
                            hintText: 'e.g. 16',
                            prefixIcon: Icon(Icons.star_outline, size: 20),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final n = int.tryParse(v.trim());
                              if (n == null || n < 1) {
                                return 'Invalid level';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Priority Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('priority_$_priority'),
                          initialValue: _priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            prefixIcon:
                                Icon(Icons.flag_outlined, size: 20),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'High',
                              child: Text('High'),
                            ),
                            DropdownMenuItem(
                              value: 'Medium',
                              child: Text('Medium'),
                            ),
                            DropdownMenuItem(
                              value: 'Low',
                              child: Text('Low'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _priority = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Estimated Duration (Days, Hours, Minutes)
                  const Text(
                    'Estimated Duration (optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _daysController,
                          decoration: const InputDecoration(
                            labelText: 'Days',
                            hintText: '0',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _hoursController,
                          decoration: const InputDecoration(
                            labelText: 'Hours',
                            hintText: '0',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _minutesController,
                          decoration: const InputDecoration(
                            labelText: 'Minutes',
                            hintText: '0',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Required Resources (optional)
                  const Text(
                    'Required Resources (optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('res_$_selectedResourceType'),
                          initialValue: _selectedResourceType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Resource',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                          items: resourceTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(
                                type,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedResourceType = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: _resourceAmountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            hintText: 'e.g. 5000000',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add, size: 20),
                        tooltip: 'Add resource',
                        onPressed: _addResource,
                      ),
                    ],
                  ),
                  if (_resources.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: List.generate(_resources.length, (index) {
                        final res = _resources[index];
                        return Chip(
                          label: Text(res.formattedAmount),
                          deleteIcon:
                              const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeResource(index),
                          backgroundColor:
                              AppColors.surfaceVariant,
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'e.g. Wait until Clan Games finish',
                      prefixIcon: Icon(Icons.notes_outlined, size: 20),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  // Submit button
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
                          : Text(widget.isEditing
                              ? 'Save plan'
                              : 'Add to planner'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    if (_realm == VillageRealm.homeVillage) {
      return Row(
        children: [
          Expanded(
            child: _CategoryPill(
              icon: Icons.handyman_outlined,
              label: 'Builder',
              isSelected: _category == UpgradeCategory.homeBuilder,
              onTap: () => _onCategoryChanged(UpgradeCategory.homeBuilder),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CategoryPill(
              icon: Icons.science_outlined,
              label: 'Laboratory',
              isSelected: _category == UpgradeCategory.homeLab,
              onTap: () => _onCategoryChanged(UpgradeCategory.homeLab),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _CategoryPill(
              icon: Icons.build_outlined,
              label: 'Builder',
              isSelected: _category == UpgradeCategory.builderBaseBuilder,
              onTap: () =>
                  _onCategoryChanged(UpgradeCategory.builderBaseBuilder),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CategoryPill(
              icon: Icons.biotech_outlined,
              label: 'Star Laboratory',
              isSelected: _category == UpgradeCategory.builderBaseStarLab,
              onTap: () =>
                  _onCategoryChanged(UpgradeCategory.builderBaseStarLab),
            ),
          ),
        ],
      );
    }
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.accent : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.black : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.black : AppColors.textPrimary,
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
