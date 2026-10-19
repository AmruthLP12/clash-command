import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/services/village_service.dart';
import 'package:clash_command/features/upgrades/application/upgrades_notifier.dart';
import 'package:clash_command/features/upgrades/presentation/add_upgrade_sheet.dart';
import 'package:clash_command/features/upgrades/presentation/upgrade_card.dart';
import 'package:clash_command/features/villages/application/villages_notifier.dart';
import 'package:clash_command/features/villages/presentation/add_village_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _selectedVillageId;

  @override
  Widget build(BuildContext context) {
    final villagesAsync = ref.watch(villagesStreamProvider);

    return villagesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (villages) {
        // Auto-select first village if none selected
        if (_selectedVillageId == null && villages.isNotEmpty) {
          _selectedVillageId = villages.first.id;
        }

        final selectedVillage = villages.isEmpty
            ? null
            : villages.firstWhere(
                (v) => v.id == _selectedVillageId,
                orElse: () => villages.first,
              );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Clash Command'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_home),
                tooltip: 'Add village',
                onPressed: () => _showAddVillage(context),
              ),
            ],
          ),
          body: villages.isEmpty
              ? _EmptyVillagesState(onAdd: () => _showAddVillage(context))
              : _DashboardBody(
                  villages: villages,
                  selectedVillage: selectedVillage!,
                  onVillageSelected: (id) =>
                      setState(() => _selectedVillageId = id),
                ),
          floatingActionButton: villages.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showAddUpgrade(context, selectedVillage!),
                  icon: const Icon(Icons.add),
                  label: const Text('Track upgrade'),
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                ),
        );
      },
    );
  }

  void _showAddVillage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AddVillageSheet(),
    );
  }

  void _showAddUpgrade(BuildContext context, Village village) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddUpgradeSheet(village: village),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({
    required this.villages,
    required this.selectedVillage,
    required this.onVillageSelected,
  });

  final List<Village> villages;
  final Village selectedVillage;
  final ValueChanged<String> onVillageSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upgradesAsync =
        ref.watch(activeUpgradesForVillageProvider(selectedVillage.id));

    return upgradesAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (upgrades) {
        final villageService = const VillageService();
        final activeCount = villageService.activeUpgradeCount(upgrades);
        final nextCompletion = villageService.nextCompletionAtUtc(upgrades);
        final available = villageService.availableSlots(
          upgrades,
          selectedVillage.builderCapacity,
        );

        return CustomScrollView(
          slivers: [
            // Village switcher
            SliverToBoxAdapter(
              child: _VillageSwitcher(
                villages: villages,
                selectedId: selectedVillage.id,
                onSelected: onVillageSelected,
              ),
            ),

            // Village summary card
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _VillageSummaryCard(
                  village: selectedVillage,
                  activeCount: activeCount,
                  availableSlots: available,
                  nextCompletion: nextCompletion,
                ),
              ),
            ),

            // Upgrade list header
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Active upgrades',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),

            // Upgrade cards or empty state
            upgrades.isEmpty
                ? SliverFillRemaining(
                    child: _EmptyUpgradesState(
                      availableSlots: available,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList.builder(
                      itemCount: upgrades.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: UpgradeCard(upgrade: upgrades[index]),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

class _VillageSwitcher extends StatelessWidget {
  const _VillageSwitcher({
    required this.villages,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Village> villages;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: villages.length,
        itemBuilder: (context, index) {
          final village = villages[index];
          final selected = village.id == selectedId;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: selected,
              label: Text(village.name),
              onSelected: (_) => onSelected(village.id),
              selectedColor: AppColors.accent,
              labelStyle: TextStyle(
                color: selected ? Colors.black : AppColors.textSecondary,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.normal,
              ),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}

class _VillageSummaryCard extends StatelessWidget {
  const _VillageSummaryCard({
    required this.village,
    required this.activeCount,
    required this.availableSlots,
    required this.nextCompletion,
  });

  final Village village;
  final int activeCount;
  final int availableSlots;
  final DateTime? nextCompletion;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        village.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (village.townHallLevel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Town Hall ${village.townHallLevel}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: availableSlots > 0
                        ? AppColors.active.withValues(alpha: 0.2)
                        : AppColors.pastDue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$availableSlots/${village.builderCapacity} free',
                    style: TextStyle(
                      color: availableSlots > 0
                          ? AppColors.active
                          : AppColors.pastDue,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  label: 'Active',
                  value: activeCount.toString(),
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                if (nextCompletion != null)
                  _StatChip(
                    label: 'Next',
                    value: _formatDate(nextCompletion!),
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime utc) {
    final local = utc.toLocal();
    return '${local.day}/${local.month} '
        '${local.hour}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVillagesState extends StatelessWidget {
  const _EmptyVillagesState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.castle_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No villages yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first village to start tracking upgrades.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add village'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyUpgradesState extends StatelessWidget {
  const _EmptyUpgradesState({required this.availableSlots});
  final int availableSlots;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'No active upgrades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$availableSlots builder ${availableSlots == 1 ? 'slot' : 'slots'} available.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
