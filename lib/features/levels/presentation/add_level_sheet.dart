import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/ids/id_generator.dart';
import 'package:clash_command/domain/catalog/upgrade_catalog.dart';
import 'package:clash_command/domain/catalog/upgrade_catalog_item.dart';
import 'package:clash_command/domain/models/level_item_type.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/models/village_item_level.dart';
import 'package:clash_command/features/upgrades/presentation/add_upgrade_sheet.dart';
import 'package:clash_command/features/villages/application/villages_notifier.dart';

/// Bottom sheet for adding or editing a tracked item level with subcategory item type selection.
class AddLevelSheet extends ConsumerStatefulWidget {
  const AddLevelSheet({
    super.key,
    required this.village,
    this.item,
    this.initialCategory,
    this.initialItemType,
  });

  final Village village;
  final VillageItemLevel? item;
  final UpgradeCategory? initialCategory;
  final String? initialItemType;

  bool get isEditing => item != null;

  @override
  ConsumerState<AddLevelSheet> createState() => _AddLevelSheetState();
}

class _AddLevelSheetState extends ConsumerState<AddLevelSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  late final TextEditingController _levelController;
  late final FocusNode _levelFocusNode;

  late String _selectedVillageId;
  late VillageRealm _realm;
  late UpgradeCategory _category;
  late String _itemType;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    _selectedVillageId = it?.villageId ?? widget.village.id;
    _nameController = TextEditingController(text: it?.itemName ?? '');
    _nameFocusNode = FocusNode();
    _levelController = TextEditingController(
      text: it != null ? '${it.currentLevel}' : '1',
    );
    _levelFocusNode = FocusNode();

    _category = it?.category.primaryCategory ??
        widget.initialCategory?.primaryCategory ??
        UpgradeCategory.homeBuilder;

    _realm = (_category == UpgradeCategory.builderBaseBuilder ||
            _category == UpgradeCategory.builderBaseStarLab)
        ? VillageRealm.builderBase
        : VillageRealm.homeVillage;

    final validTypes = LevelItemType.typesForCategory(_category);
    final rawType = it?.effectiveItemType ?? widget.initialItemType;
    if (rawType != null && validTypes.contains(rawType)) {
      _itemType = rawType;
    } else {
      _itemType = validTypes.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _levelController.dispose();
    _levelFocusNode.dispose();
    super.dispose();
  }

  void _onRealmChanged(VillageRealm realm) {
    if (_realm == realm) return;
    setState(() {
      _realm = realm;
      _category = (realm == VillageRealm.homeVillage)
          ? UpgradeCategory.homeBuilder
          : UpgradeCategory.builderBaseBuilder;
      final validTypes = LevelItemType.typesForCategory(_category);
      if (!validTypes.contains(_itemType)) {
        _itemType = validTypes.first;
      }
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
      final validTypes = LevelItemType.typesForCategory(_category);
      if (!validTypes.contains(_itemType)) {
        _itemType = validTypes.first;
      }
    });
  }

  void _onItemTypeChanged(String type) {
    if (_itemType == type) return;
    setState(() {
      _itemType = type;
    });
  }

  void _onCatalogItemSelected(UpgradeCatalogItem item) {
    _nameController.text = item.name;
    final targetCategory = item.category.primaryCategory;
    final targetRealm = (targetCategory == UpgradeCategory.builderBaseBuilder ||
            targetCategory == UpgradeCategory.builderBaseStarLab)
        ? VillageRealm.builderBase
        : VillageRealm.homeVillage;
    final inferredType =
        LevelItemType.fromCatalogType(item.type, targetCategory);

    setState(() {
      _category = targetCategory;
      _realm = targetRealm;
      final validTypes = LevelItemType.typesForCategory(_category);
      if (validTypes.contains(inferredType)) {
        _itemType = inferredType;
      }
      if (!widget.isEditing || _levelController.text.trim().isEmpty) {
        _levelController.text = '${item.minLevel}';
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final level = int.parse(_levelController.text.trim());
      final now = DateTime.now().toUtc();

      // Check if an existing record with this name and category in the target village exists
      final existing = await ref.read(villageItemLevelsDaoProvider).findByItem(
            _selectedVillageId,
            _category,
            name,
          );

      if (widget.isEditing) {
        if (existing != null && existing.id != widget.item!.id) {
          // Merge safely: update the matching entry with the new level and delete old record
          final merged = existing.copyWith(
            currentLevel: level,
            itemType: _itemType,
            updatedAtUtc: now,
          );
          await ref.read(villageItemLevelsDaoProvider).upsert(merged);
          await ref
              .read(villageItemLevelsDaoProvider)
              .deleteItem(widget.item!.id);
        } else {
          final updated = widget.item!.copyWith(
            villageId: _selectedVillageId,
            category: _category,
            itemType: _itemType,
            itemName: name,
            currentLevel: level,
            updatedAtUtc: now,
          );
          await ref.read(villageItemLevelsDaoProvider).upsert(updated);
        }
      } else {
        final record = VillageItemLevel(
          id: existing?.id ?? const IdGenerator().newId(),
          villageId: _selectedVillageId,
          category: _category,
          itemType: _itemType,
          itemName: name,
          currentLevel: level,
          updatedAtUtc: now,
        );
        await ref.read(villageItemLevelsDaoProvider).upsert(record);
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final villagesAsync = ref.watch(villagesStreamProvider);
    final customSuggestionsAsync =
        ref.watch(customUpgradeSuggestionsStreamProvider(_category));
    final customNames = (customSuggestionsAsync.valueOrNull ?? [])
        .map((e) => e.name)
        .toList();

    final validTypes = LevelItemType.typesForCategory(_category);

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
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.isEditing
                              ? 'Edit tracked item'
                              : 'Track item level',
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

                  // 1. Village selector (if user has multiple villages)
                  villagesAsync.when(
                    data: (villages) {
                      if (villages.length <= 1) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<String>(
                          initialValue: villages.any((v) => v.id == _selectedVillageId)
                              ? _selectedVillageId
                              : villages.first.id,
                          decoration: const InputDecoration(
                            labelText: 'Village',
                            prefixIcon: Icon(Icons.home_outlined, size: 20),
                          ),
                          items: villages.map((v) {
                            return DropdownMenuItem(
                              value: v.id,
                              child: Text(v.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedVillageId = val);
                            }
                          },
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  ),

                  // 2. Realm switcher (Home Village vs Builder Base)
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

                  // Category Selector (Builder / Laboratory / Star Laboratory)
                  _buildCategorySelector(),
                  const SizedBox(height: 14),

                  // 3. Item Type Selector
                  const Text(
                    'Item Type',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: validTypes.map((type) {
                      final isSelected = _itemType == type;
                      final icon = LevelItemType.iconForType(type);
                      return ChoiceChip(
                        avatar: Icon(
                          icon,
                          size: 16,
                          color: isSelected ? Colors.black : AppColors.textSecondary,
                        ),
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) _onItemTypeChanged(type);
                        },
                        selectedColor: AppColors.accent,
                        backgroundColor: AppColors.surfaceVariant,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // 4. Item Name with Autocomplete (filtered by realm, category & item type)
                  RawAutocomplete<UpgradeCatalogItem>(
                    key: ValueKey('auto_${_category.name}_$_itemType'),
                    textEditingController: _nameController,
                    focusNode: _nameFocusNode,
                    displayStringForOption: (item) => item.name,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return UpgradeCatalog.search(
                        query: textEditingValue.text,
                        category: _category,
                        itemType: _itemType,
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
                          labelText: 'Item name *',
                          hintText: 'e.g. Archer Tower, Barbarian King',
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
                              maxHeight: 200,
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
                                        ? 'Custom · $_itemType'
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

                  // 5. Current Level Field with +/- buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _levelController,
                          focusNode: _levelFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Current level *',
                            hintText: 'e.g. 15',
                            prefixIcon: Icon(Icons.numbers_outlined, size: 20),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            final n = int.tryParse(v.trim());
                            if (n == null || n < 1) return 'Positive integer';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          final cur =
                              int.tryParse(_levelController.text) ?? 1;
                          if (cur > 1) {
                            setState(() => _levelController.text = '${cur - 1}');
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final cur =
                              int.tryParse(_levelController.text) ?? 1;
                          setState(() => _levelController.text = '${cur + 1}');
                        },
                      ),
                    ],
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
                              ? 'Save changes'
                              : 'Record level'),
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
