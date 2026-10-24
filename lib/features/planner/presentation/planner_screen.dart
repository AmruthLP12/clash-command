import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
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
  String _statusFilter = 'planned'; // 'planned', 'all', 'completed'
  UpgradeCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedVillageId = widget.initialVillageId;
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
                          child: Text('Planner · ${v.name}'),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          body: Column(
            children: [
              // Filters row (Status & Category)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      selected: _statusFilter == 'planned',
                      label: const Text('Planned'),
                      onSelected: (_) => setState(() => _statusFilter = 'planned'),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: _statusFilter == 'all',
                      label: const Text('All status'),
                      onSelected: (_) => setState(() => _statusFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: _statusFilter == 'completed',
                      label: const Text('Completed'),
                      onSelected: (_) => setState(() => _statusFilter = 'completed'),
                    ),
                    const SizedBox(width: 16),
                    const VerticalDivider(width: 1),
                    const SizedBox(width: 16),
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

              // Planned items list
              Expanded(
                child: itemsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (items) {
                    var filtered = items;
                    if (_statusFilter == 'planned') {
                      filtered = filtered
                          .where((it) => it.status == 'planned')
                          .toList();
                    } else if (_statusFilter == 'completed') {
                      filtered = filtered
                          .where((it) =>
                              it.status == 'completed' || it.status == 'started')
                          .toList();
                    }

                    if (_selectedCategory != null) {
                      filtered = filtered
                          .where((it) => it.category == _selectedCategory)
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
                                Icons.event_note_outlined,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No planned upgrades found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Plan future building and troop research ahead of time.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
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
                            color: AppColors.accentLight.withValues(alpha: 0.15),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Start', style: TextStyle(fontSize: 12)),
              ),
            ],

            // Actions dropdown menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
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
                        Icon(Icons.play_arrow, size: 18, color: AppColors.accent),
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
                      Icon(Icons.edit_outlined, size: 18, color: AppColors.accent),
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
                        Icon(Icons.check_circle_outline, size: 18, color: AppColors.active),
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
                      Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete plan', style: TextStyle(color: AppColors.error)),
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
