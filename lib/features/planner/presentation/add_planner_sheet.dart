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

    _category = it?.category.primaryCategory ??
        widget.initialCategory?.primaryCategory ??
        UpgradeCategory.homeBuilder;

    _realm = (_category == UpgradeCategory.builderBaseBuilder ||
            _category == UpgradeCategory.builderBaseStarLab)
        ? VillageRealm.builderBase
        : VillageRealm.homeVillage;

    _priority = it?.priority ?? 'Medium';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _levelController.dispose();
    _levelFocusNode.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onRealmChanged(VillageRealm realm) {
    if (_realm == realm) return;
    setState(() {
      _realm = realm;
      _category = (realm == VillageRealm.homeVillage)
          ? UpgradeCategory.homeBuilder
          : UpgradeCategory.builderBaseBuilder;
      _nameController.clear();
      _levelController.clear();
    });
  }

  void _onCategoryChanged(UpgradeCategory cat) {
    if (_category == cat) return;
    setState(() {
      _category = cat;
      _nameController.clear();
      _levelController.clear();
    });
  }

  void _onCatalogItemSelected(UpgradeCatalogItem item) {
    _nameController.text = item.name;
    final suggested = item.suggestToLevel(null);
    if (suggested != null) {
      _levelController.text = '$suggested';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final levelText = _levelController.text.trim();
      final targetLevel = levelText.isNotEmpty ? int.tryParse(levelText) : null;
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      final now = DateTime.now().toUtc();

      if (widget.isEditing) {
        final updated = widget.item!.copyWith(
          category: _category,
          name: name,
          targetLevel: targetLevel,
          clearTargetLevel: targetLevel == null,
          priority: _priority,
          notes: notes,
          clearNotes: notes == null,
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

                  // Realm switcher (Home Village vs Builder Base)
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

                  // Category Selector
                  _buildCategorySelector(),
                  const SizedBox(height: 12),

                  // Name Autocomplete
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

                  // Target Level & Priority
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target Level
                      Expanded(
                        child: TextFormField(
                          controller: _levelController,
                          focusNode: _levelFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Upgrade to level',
                            hintText: 'e.g. 19',
                            prefixIcon: Icon(Icons.numbers_outlined, size: 18),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final n = int.tryParse(v.trim());
                            if (n == null || n < 1) return 'Positive integer';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Priority
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            prefixIcon: Icon(Icons.flag_outlined, size: 18),
                          ),
                          dropdownColor: AppColors.surfaceVariant,
                          items: const [
                            DropdownMenuItem(
                              value: 'High',
                              child: Text('High', style: TextStyle(color: AppColors.pastDue)),
                            ),
                            DropdownMenuItem(
                              value: 'Medium',
                              child: Text('Medium', style: TextStyle(color: AppColors.accent)),
                            ),
                            DropdownMenuItem(
                              value: 'Low',
                              child: Text('Low', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _priority = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'e.g. Save 10M gold for this upgrade',
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
                          : Text(widget.isEditing ? 'Save plan' : 'Add to planner'),
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
              onTap: () => _onCategoryChanged(UpgradeCategory.builderBaseBuilder),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CategoryPill(
              icon: Icons.biotech_outlined,
              label: 'Star Laboratory',
              isSelected: _category == UpgradeCategory.builderBaseStarLab,
              onTap: () => _onCategoryChanged(UpgradeCategory.builderBaseStarLab),
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
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
