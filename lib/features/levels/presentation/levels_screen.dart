import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/models/village_item_level.dart';
import 'package:clash_command/features/levels/presentation/add_level_sheet.dart';
import 'package:clash_command/features/villages/application/villages_notifier.dart';

class LevelsScreen extends ConsumerStatefulWidget {
  const LevelsScreen({super.key, this.initialVillageId});

  final String? initialVillageId;

  @override
  ConsumerState<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends ConsumerState<LevelsScreen> {
  String? _selectedVillageId;
  String _searchQuery = '';
  UpgradeCategory? _selectedCategory;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedVillageId = widget.initialVillageId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddLevel(BuildContext context, Village village) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddLevelSheet(
        village: village,
        initialCategory: _selectedCategory,
      ),
    );
  }

  void _showEditLevel(
      BuildContext context, Village village, VillageItemLevel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddLevelSheet(
        village: village,
        item: item,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final villagesAsync = ref.watch(villagesStreamProvider);

    return villagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (villages) {
        if (villages.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                'No villages found. Create a village first.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        if (_selectedVillageId == null ||
            !villages.any((v) => v.id == _selectedVillageId)) {
          _selectedVillageId = villages.first.id;
        }

        final selectedVillage = villages.firstWhere(
          (v) => v.id == _selectedVillageId,
          orElse: () => villages.first,
        );

        final levelsAsync =
            ref.watch(villageItemLevelsStreamProvider(selectedVillage.id));

        return Scaffold(
          appBar: AppBar(
            title: villages.length <= 1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Village Levels'),
                      Text(
                        selectedVillage.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedVillageId,
                      dropdownColor: AppColors.surfaceVariant,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      onChanged: (id) {
                        if (id != null) setState(() => _selectedVillageId = id);
                      },
                      items: villages.map((v) {
                        return DropdownMenuItem(
                          value: v.id,
                          child: Text('Levels · ${v.name}'),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          body: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
              ),

              // Category filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      selected: _selectedCategory == null,
                      label: const Text('All categories'),
                      onSelected: (_) => setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: 8),
                    ...UpgradeCategory.values.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _selectedCategory == cat,
                          label: Text(cat.displayName),
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Items list
              Expanded(
                child: levelsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (items) {
                    var filtered = items;
                    if (_selectedCategory != null) {
                      filtered = filtered
                          .where((it) => it.category == _selectedCategory)
                          .toList();
                    }
                    if (_searchQuery.isNotEmpty) {
                      filtered = filtered
                          .where((it) =>
                              it.itemName.toLowerCase().contains(_searchQuery))
                          .toList();
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.format_list_numbered_outlined,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No levels recorded yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Track your buildings, heroes, and troop research levels for this village.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showAddLevel(context, selectedVillage),
                                icon: const Icon(Icons.add),
                                label: const Text('Record first item level'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _LevelItemCard(
                          item: item,
                          onEdit: () =>
                              _showEditLevel(context, selectedVillage, item),
                          onDelete: () => ref
                              .read(villageItemLevelsDaoProvider)
                              .deleteItem(item.id),
                          onIncrement: () async {
                            final updated = item.copyWith(
                              currentLevel: item.currentLevel + 1,
                              updatedAtUtc: DateTime.now().toUtc(),
                            );
                            await ref
                                .read(villageItemLevelsDaoProvider)
                                .upsert(updated);
                          },
                          onDecrement: () async {
                            if (item.currentLevel > 1) {
                              final updated = item.copyWith(
                                currentLevel: item.currentLevel - 1,
                                updatedAtUtc: DateTime.now().toUtc(),
                              );
                              await ref
                                    .read(villageItemLevelsDaoProvider)
                                    .upsert(updated);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddLevel(context, selectedVillage),
            icon: const Icon(Icons.add),
            label: const Text('Track level'),
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
          ),
        );
      },
    );
  }
}

class _LevelItemCard extends StatelessWidget {
  const _LevelItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onIncrement,
    required this.onDecrement,
  });

  final VillageItemLevel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Level Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${item.currentLevel}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.category.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        Text(
                          DateTimeFormat.shortDate(item.updatedAtUtc),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Increment / decrement inline controls
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                visualDensity: VisualDensity.compact,
                tooltip: 'Decrease level',
                onPressed: item.currentLevel > 1 ? onDecrement : null,
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                visualDensity: VisualDensity.compact,
                tooltip: 'Increase level',
                onPressed: onIncrement,
              ),

              // Options
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                color: AppColors.surfaceVariant,
                onSelected: (val) {
                  if (val == 'edit') {
                    onEdit();
                  } else if (val == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.accent),
                        SizedBox(width: 8),
                        Text('Edit level'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Remove record', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

