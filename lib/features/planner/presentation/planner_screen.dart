import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/formatting/duration_format.dart';
import 'package:clash_command/domain/models/planner_item.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/features/planner/presentation/add_planner_sheet.dart';
import 'package:clash_command/features/upgrades/presentation/add_upgrade_sheet.dart';
import 'package:clash_command/features/villages/application/villages_notifier.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key, this.initialVillageId});

  final String? initialVillageId;

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  String? _selectedVillageId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter states
  String _statusFilter = 'planned'; // 'all', 'planned', 'started', 'completed'
  UpgradeCategory? _selectedCategory;
  String? _priorityFilter; // null, 'High', 'Medium', 'Low'
  String? _durationFilter; // null, '<1d', '1-3d', '3-7d', '>7d', 'unset'
  String? _resourceTypeFilter; // null, 'Gold', 'Elixir', 'Dark Elixir', etc.
  int? _targetLevelFilter;

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

  int get _activeFiltersCount {
    var count = 0;
    if (_searchQuery.trim().isNotEmpty) count++;
    if (_statusFilter != 'planned') count++;
    if (_selectedCategory != null) count++;
    if (_priorityFilter != null) count++;
    if (_durationFilter != null) count++;
    if (_resourceTypeFilter != null) count++;
    if (_targetLevelFilter != null) count++;
    return count;
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _statusFilter = 'planned';
      _selectedCategory = null;
      _priorityFilter = null;
      _durationFilter = null;
      _resourceTypeFilter = null;
      _targetLevelFilter = null;
    });
  }

  void _showAddPlan(BuildContext context, Village village) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddPlannerSheet(
        village: village,
        initialCategory: _selectedCategory,
      ),
    );
  }

  void _showEditPlan(BuildContext context, Village village, PlannerItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddPlannerSheet(
        village: village,
        item: item,
      ),
    );
  }

  void _startUpgrade(BuildContext context, Village village, PlannerItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddUpgradeSheet(
        village: village,
        initialCategory: item.category,
        initialName: item.name,
        initialTargetLevel: item.targetLevel,
        plannerItemId: item.id,
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Planned Upgrades',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _clearAllFilters();
                            setModalState(() {});
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Priority
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _priorityFilter == null,
                          onSelected: (_) {
                            setState(() => _priorityFilter = null);
                            setModalState(() {});
                          },
                        ),
                        for (final p in ['High', 'Medium', 'Low'])
                          ChoiceChip(
                            label: Text(p),
                            selected: _priorityFilter == p,
                            onSelected: (selected) {
                              setState(() => _priorityFilter = selected ? p : null);
                              setModalState(() {});
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Duration range
                    const Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _durationFilter == null,
                          onSelected: (_) {
                            setState(() => _durationFilter = null);
                            setModalState(() {});
                          },
                        ),
                        ChoiceChip(
                          label: const Text('< 1 day'),
                          selected: _durationFilter == '<1d',
                          onSelected: (s) {
                            setState(() => _durationFilter = s ? '<1d' : null);
                            setModalState(() {});
                          },
                        ),
                        ChoiceChip(
                          label: const Text('1–3 days'),
                          selected: _durationFilter == '1-3d',
                          onSelected: (s) {
                            setState(() => _durationFilter = s ? '1-3d' : null);
                            setModalState(() {});
                          },
                        ),
                        ChoiceChip(
                          label: const Text('3–7 days'),
                          selected: _durationFilter == '3-7d',
                          onSelected: (s) {
                            setState(() => _durationFilter = s ? '3-7d' : null);
                            setModalState(() {});
                          },
                        ),
                        ChoiceChip(
                          label: const Text('> 7 days'),
                          selected: _durationFilter == '>7d',
                          onSelected: (s) {
                            setState(() => _durationFilter = s ? '>7d' : null);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Resource type
                    const Text(
                      'Required Resource',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _resourceTypeFilter == null,
                          onSelected: (_) {
                            setState(() => _resourceTypeFilter = null);
                            setModalState(() {});
                          },
                        ),
                        for (final res in [
                          'Gold',
                          'Elixir',
                          'Dark Elixir',
                          'Builder Gold',
                          'Builder Elixir',
                        ])
                          ChoiceChip(
                            label: Text(res),
                            selected: _resourceTypeFilter == res,
                            onSelected: (s) {
                              setState(
                                  () => _resourceTypeFilter = s ? res : null);
                              setModalState(() {});
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.pastDue;
      case 'Low':
        return AppColors.textSecondary;
      case 'Medium':
      default:
        return AppColors.accent;
    }
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

        final itemsAsync =
            ref.watch(plannerItemsForVillageProvider(selectedVillage.id));

        return Scaffold(
          appBar: AppBar(
            title: villages.length <= 1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Upgrade Planner'),
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
                      icon: const Icon(Icons.arrow_drop_down,
                          color: AppColors.accent),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      onChanged: (id) {
                        if (id != null) {
                          setState(() => _selectedVillageId = id);
                        }
                      },
                      items: villages.map((v) {
                        return DropdownMenuItem(
                          value: v.id,
                          child: Text('Planner · ${v.name}'),
                        );
                      }).toList(),
                    ),
                  ),
            actions: [
              IconButton(
                icon: Badge(
                  isLabelVisible: _activeFiltersCount > 0,
                  label: Text('$_activeFiltersCount'),
                  child: const Icon(Icons.tune),
                ),
                tooltip: 'Advanced Filters',
                onPressed: () => _showFilterSheet(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search planned upgrades...',
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onChanged: (q) => setState(() => _searchQuery = q),
                ),
              ),

              // Filter row: Status chips + Category chips + Clear All
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    // Status chips
                    FilterChip(
                      selected: _statusFilter == 'planned',
                      label: const Text('Planned'),
                      onSelected: (_) =>
                          setState(() => _statusFilter = 'planned'),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      selected: _statusFilter == 'started',
                      label: const Text('In Progress'),
                      onSelected: (_) =>
                          setState(() => _statusFilter = 'started'),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      selected: _statusFilter == 'completed',
                      label: const Text('Completed'),
                      onSelected: (_) =>
                          setState(() => _statusFilter = 'completed'),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      selected: _statusFilter == 'all',
                      label: const Text('All Status'),
                      onSelected: (_) => setState(() => _statusFilter = 'all'),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.surfaceVariant,
                    ),
                    const SizedBox(width: 10),

                    // Category filters
                    FilterChip(
                      selected: _selectedCategory == null,
                      label: const Text('All Categories'),
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: 6),
                    ...UpgradeCategory.values
                        .where((c) =>
                            c == c.primaryCategory &&
                            c != UpgradeCategory.other)
                        .map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          selected: _selectedCategory == cat,
                          label: Text(cat.displayName),
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                        ),
                      );
                    }),

                    if (_activeFiltersCount > 0) ...[
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Icon(Icons.close, size: 16),
                        label: Text('Clear ($_activeFiltersCount)'),
                        onPressed: _clearAllFilters,
                        backgroundColor: AppColors.surfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),

              // Planned items list
              Expanded(
                child: itemsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (items) {
                    final filtered = items.where((it) {
                      // Search query
                      if (_searchQuery.trim().isNotEmpty) {
                        if (!it.name
                            .toLowerCase()
                            .contains(_searchQuery.trim().toLowerCase())) {
                          return false;
                        }
                      }

                      // Status
                      if (_statusFilter == 'planned' && it.status != 'planned') {
                        return false;
                      }
                      if (_statusFilter == 'started' && it.status != 'started') {
                        return false;
                      }
                      if (_statusFilter == 'completed' &&
                          it.status != 'completed') {
                        return false;
                      }

                      // Category
                      if (_selectedCategory != null &&
                          it.category != _selectedCategory) {
                        return false;
                      }

                      // Priority
                      if (_priorityFilter != null &&
                          it.priority != _priorityFilter) {
                        return false;
                      }

                      // Duration
                      if (_durationFilter != null) {
                        if (_durationFilter == 'unset') {
                          if (it.durationSeconds != null) return false;
                        } else {
                          if (it.durationSeconds == null) return false;
                          final sec = it.durationSeconds!;
                          const oneDay = 86400;
                          if (_durationFilter == '<1d' && sec >= oneDay) {
                            return false;
                          }
                          if (_durationFilter == '1-3d' &&
                              (sec < oneDay || sec > 3 * oneDay)) {
                            return false;
                          }
                          if (_durationFilter == '3-7d' &&
                              (sec < 3 * oneDay || sec > 7 * oneDay)) {
                            return false;
                          }
                          if (_durationFilter == '>7d' && sec <= 7 * oneDay) {
                            return false;
                          }
                        }
                      }

                      // Resource type
                      if (_resourceTypeFilter != null) {
                        if (!it.resources
                            .any((r) => r.type == _resourceTypeFilter)) {
                          return false;
                        }
                      }

                      // Target level
                      if (_targetLevelFilter != null) {
                        if (it.targetLevel != _targetLevelFilter) return false;
                      }

                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.event_note_outlined,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _activeFiltersCount > 0
                                    ? 'No upgrades match current filters'
                                    : 'No planned upgrades found',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _activeFiltersCount > 0
                                    ? 'Try resetting your search or filter options.'
                                    : 'Plan future building and troop research ahead of time.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_activeFiltersCount > 0)
                                TextButton.icon(
                                  onPressed: _clearAllFilters,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Clear all filters'),
                                )
                              else
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showAddPlan(context, selectedVillage),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add planned upgrade'),
                                ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Reorderable list
                    return ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: filtered.length,
                      onReorderItem: (oldIndex, newIndex) async {
                        final mutable = List<PlannerItem>.from(filtered);
                        final item = mutable.removeAt(oldIndex);
                        mutable.insert(newIndex, item);
                        final orderedIds = mutable.map((e) => e.id).toList();
                        await ref
                            .read(plannerDaoProvider)
                            .reorder(selectedVillage.id, orderedIds);
                      },
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _PlannerItemCard(
                          key: ValueKey(item.id),
                          item: item,
                          village: selectedVillage,
                          priorityColor: _priorityColor(item.priority),
                          onStart: () =>
                              _startUpgrade(context, selectedVillage, item),
                          onEdit: () =>
                              _showEditPlan(context, selectedVillage, item),
                          onDelete: () =>
                              ref.read(plannerDaoProvider).deleteItem(item.id),
                          onMarkNext: () => ref
                              .read(plannerDaoProvider)
                              .markAsNext(selectedVillage.id, item.id),
                          onStatusChanged: (status) => ref
                              .read(plannerDaoProvider)
                              .updateStatus(item.id, status),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddPlan(context, selectedVillage),
            icon: const Icon(Icons.add),
            label: const Text('Plan upgrade'),
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
          ),
        );
      },
    );
  }
}

class _PlannerItemCard extends StatelessWidget {
  const _PlannerItemCard({
    super.key,
    required this.item,
    required this.village,
    required this.priorityColor,
    required this.onStart,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkNext,
    required this.onStatusChanged,
  });

  final PlannerItem item;
  final Village village;
  final Color priorityColor;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkNext;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Reorder drag indicator
            const Icon(
              Icons.drag_indicator,
              color: AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 10),

            // Item content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Next badge
                      if (item.isNext) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppColors.active,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NEXT',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],

                      // Name + Target level
                      Expanded(
                        child: Text(
                          item.displayNameWithLevel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: item.status == 'completed'
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            decoration: item.status == 'completed'
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Category + Priority badges
                  Row(
                    children: [
                      // Category badge
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
                      const SizedBox(width: 8),

                      // Priority pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.priority,
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      if (item.status == 'started') ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.accentLight.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Started',
                            style: TextStyle(
                              color: AppColors.accentLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Duration and Resource badges
                  if (item.durationSeconds != null ||
                      item.resources.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (item.durationSeconds != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 12, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  formatSeconds(item.durationSeconds!),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        for (final res in item.resources)
                          _ResourceBadge(resource: res),
                      ],
                    ),
                  ],

                  // Notes if present
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Start Upgrade Button (if not completed)
            if (item.status == 'planned') ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Start', style: TextStyle(fontSize: 12)),
              ),
            ],

            // Actions dropdown menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  size: 20, color: AppColors.textSecondary),
              color: AppColors.surfaceVariant,
              onSelected: (val) {
                switch (val) {
                  case 'start':
                    onStart();
                    break;
                  case 'next':
                    onMarkNext();
                    break;
                  case 'edit':
                    onEdit();
                    break;
                  case 'complete':
                    onStatusChanged('completed');
                    break;
                  case 'uncomplete':
                    onStatusChanged('planned');
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                if (item.status == 'planned') ...[
                  const PopupMenuItem(
                    value: 'start',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow,
                            size: 18, color: AppColors.accent),
                        SizedBox(width: 8),
                        Text('Start upgrade'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'next',
                    child: Row(
                      children: [
                        Icon(Icons.flag, size: 18, color: AppColors.active),
                        SizedBox(width: 8),
                        Text('Mark as Next'),
                      ],
                    ),
                  ),
                ],
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.accent),
                      SizedBox(width: 8),
                      Text('Edit plan'),
                    ],
                  ),
                ),
                if (item.status != 'completed')
                  const PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 18, color: AppColors.active),
                        SizedBox(width: 8),
                        Text('Mark completed'),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'uncomplete',
                    child: Row(
                      children: [
                        Icon(Icons.undo, size: 18, color: AppColors.accent),
                        SizedBox(width: 8),
                        Text('Mark as planned'),
                      ],
                    ),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete plan',
                          style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceBadge extends StatelessWidget {
  const _ResourceBadge({required this.resource});

  final PlannerResource resource;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (resource.type) {
      case 'Gold':
      case 'Builder Gold':
        color = const Color(0xFFFFD54F);
        icon = Icons.monetization_on;
        break;
      case 'Elixir':
      case 'Builder Elixir':
        color = const Color(0xFFFF4081);
        icon = Icons.water_drop;
        break;
      case 'Dark Elixir':
        color = const Color(0xFFCE93D8);
        icon = Icons.opacity;
        break;
      default:
        color = AppColors.accent;
        icon = Icons.toll;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            resource.formattedAmount,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
