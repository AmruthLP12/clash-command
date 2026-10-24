import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/services/village_service.dart';
import 'package:clash_command/features/history/presentation/history_screen.dart';
import 'package:clash_command/features/levels/presentation/levels_screen.dart';
import 'package:clash_command/features/planner/presentation/planner_screen.dart';
import 'package:clash_command/features/settings/presentation/settings_screen.dart';
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
  int _navIndex = 0;
  String? _selectedVillageId;
  VillageRealm _selectedRealm = VillageRealm.homeVillage;
  UpgradeCategory _selectedCategory = UpgradeCategory.homeBuilder;
  bool _userSelectedCategory = false;

  @override
  Widget build(BuildContext context) {
    if (_navIndex == 1) {
      return Scaffold(
        body: PlannerScreen(initialVillageId: _selectedVillageId),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    if (_navIndex == 2) {
      return Scaffold(
        body: LevelsScreen(initialVillageId: _selectedVillageId),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    if (_navIndex == 3) {
      return Scaffold(
        body: HistoryScreen(initialVillageId: _selectedVillageId),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    if (_navIndex == 4) {
      return Scaffold(
        body: const SettingsScreen(),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    final villagesAsync = ref.watch(villagesStreamProvider);

    return villagesAsync.when(
      loading: () => Scaffold(
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _buildBottomNav(),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
        bottomNavigationBar: _buildBottomNav(),
      ),
      data: (villages) {
        if (villages.isNotEmpty) {
          if (_selectedVillageId == null ||
              !villages.any((v) => v.id == _selectedVillageId)) {
            _selectedVillageId = villages.first.id;
          }
        } else {
          _selectedVillageId = null;
        }

        final selectedVillage = villages.isEmpty
            ? null
            : villages.firstWhere(
                (v) => v.id == _selectedVillageId,
                orElse: () => villages.first,
              );

        if (selectedVillage != null && !_userSelectedCategory) {
          final activeUpgrades = ref
                  .watch(activeUpgradesForVillageProvider(selectedVillage.id))
                  .valueOrNull ??
              [];
          if (activeUpgrades.isNotEmpty) {
            final hasHomeBuilder = activeUpgrades.any(
                (u) => u.category.primaryCategory == UpgradeCategory.homeBuilder);
            if (!hasHomeBuilder) {
              if (activeUpgrades.any(
                  (u) => u.category.primaryCategory == UpgradeCategory.homeLab)) {
                _selectedRealm = VillageRealm.homeVillage;
                _selectedCategory = UpgradeCategory.homeLab;
              } else if (activeUpgrades.any((u) =>
                  u.category.primaryCategory == UpgradeCategory.builderBaseBuilder)) {
                _selectedRealm = VillageRealm.builderBase;
                _selectedCategory = UpgradeCategory.builderBaseBuilder;
              } else if (activeUpgrades.any((u) =>
                  u.category.primaryCategory == UpgradeCategory.builderBaseStarLab)) {
                _selectedRealm = VillageRealm.builderBase;
                _selectedCategory = UpgradeCategory.builderBaseStarLab;
              }
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: villages.length <= 1
                ? (selectedVillage != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedVillage.name),
                          if (_selectedRealm == VillageRealm.homeVillage && selectedVillage.townHallLevel != null)
                            Text(
                              'Town Hall ${selectedVillage.townHallLevel}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            )
                          else if (_selectedRealm == VillageRealm.builderBase && selectedVillage.builderHallLevel != null)
                            Text(
                              'Builder Hall ${selectedVillage.builderHallLevel}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            )
                          else if (selectedVillage.townHallLevel != null)
                            Text(
                              'Town Hall ${selectedVillage.townHallLevel}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      )
                    : const Text('Clash Command'))
                : _VillageDropdownTitle(
                    villages: villages,
                    selectedId: _selectedVillageId!,
                    onSelected: (id) {
                      setState(() => _selectedVillageId = id);
                      ref
                          .read(homeWidgetSyncServiceProvider)
                          .syncWidgets(specificVillageId: id);
                    },
                  ),
            actions: [
              if (selectedVillage != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                  color: AppColors.surfaceVariant,
                  tooltip: 'Village options',
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showEditVillage(context, selectedVillage);
                    } else if (val == 'delete') {
                      _confirmDeleteVillage(context, selectedVillage);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.accent),
                          SizedBox(width: 8),
                          Text('Edit village'),
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
                          Text('Delete village', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              IconButton(
                icon: const Icon(Icons.add_home_outlined),
                tooltip: 'Add village',
                onPressed: () => _showAddVillage(context),
              ),
            ],
          ),
          body: villages.isEmpty
              ? _EmptyVillagesState(onAdd: () => _showAddVillage(context))
              : _DashboardBody(
                  village: selectedVillage!,
                  selectedRealm: _selectedRealm,
                  selectedCategory: _selectedCategory,
                  onRealmChanged: (realm) {
                    setState(() {
                      _userSelectedCategory = true;
                      _selectedRealm = realm;
                      _selectedCategory = (realm == VillageRealm.homeVillage)
                          ? UpgradeCategory.homeBuilder
                          : UpgradeCategory.builderBaseBuilder;
                    });
                  },
                  onCategoryChanged: (cat) {
                    setState(() {
                      _userSelectedCategory = true;
                      _selectedCategory = cat;
                    });
                  },
                  onTrackUpgrade: () =>
                      _showAddUpgrade(context, selectedVillage, _selectedCategory),
                ),
          floatingActionButton: villages.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () =>
                      _showAddUpgrade(context, selectedVillage!, _selectedCategory),
                  icon: const Icon(Icons.add),
                  label: const Text('Track upgrade'),
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _navIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent,
      onDestinationSelected: (index) => setState(() => _navIndex = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: Colors.black),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note, color: Colors.black),
          label: 'Planner',
        ),
        NavigationDestination(
          icon: Icon(Icons.format_list_numbered_outlined),
          selectedIcon: Icon(Icons.format_list_numbered, color: Colors.black),
          label: 'Levels',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history, color: Colors.black),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings, color: Colors.black),
          label: 'Settings',
        ),
      ],
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

  void _showEditVillage(BuildContext context, Village village) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddVillageSheet(village: village),
    );
  }

  Future<void> _confirmDeleteVillage(
    BuildContext context,
    Village village,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete village?'),
        content: Text(
          'Permanently delete "${village.name}"?\n\n'
          '⚠️ All active upgrades and activity logs for this village will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(villagesNotifierProvider.notifier)
          .deleteVillage(village.id);
      setState(() => _selectedVillageId = null);
    }
  }

  void _showAddUpgrade(
    BuildContext context,
    Village village,
    UpgradeCategory initialCategory,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddUpgradeSheet(
        village: village,
        initialCategory: initialCategory,
      ),
    );
  }
}

class _VillageDropdownTitle extends StatelessWidget {
  const _VillageDropdownTitle({
    required this.villages,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Village> villages;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedVillage = villages.firstWhere(
      (v) => v.id == selectedId,
      orElse: () => villages.first,
    );

    return PopupMenuButton<String>(
      onSelected: onSelected,
      color: AppColors.surfaceVariant,
      tooltip: 'Switch village',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedVillage.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Builder(
                  builder: (context) {
                    final levels = [
                      if (selectedVillage.townHallLevel != null) 'TH ${selectedVillage.townHallLevel}',
                      if (selectedVillage.builderHallLevel != null) 'BH ${selectedVillage.builderHallLevel}',
                    ];
                    if (levels.isEmpty) return const SizedBox.shrink();
                    return Text(
                      levels.join(' · '),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
        ],
      ),
      itemBuilder: (context) {
        return villages.map((v) {
          final isCurrent = v.id == selectedId;
          final badge = [
            if (v.townHallLevel != null) 'TH${v.townHallLevel}',
            if (v.builderHallLevel != null) 'BH${v.builderHallLevel}',
          ].join(' ');

          return PopupMenuItem<String>(
            value: v.id,
            child: Row(
              children: [
                Icon(
                  isCurrent ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: isCurrent ? AppColors.accent : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    v.name,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                      color: isCurrent ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (badge.isNotEmpty)
                  Text(
                    badge,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

class _DashboardBody extends ConsumerStatefulWidget {
  const _DashboardBody({
    required this.village,
    required this.selectedRealm,
    required this.selectedCategory,
    required this.onRealmChanged,
    required this.onCategoryChanged,
    required this.onTrackUpgrade,
  });

  final Village village;
  final VillageRealm selectedRealm;
  final UpgradeCategory selectedCategory;
  final ValueChanged<VillageRealm> onRealmChanged;
  final ValueChanged<UpgradeCategory> onCategoryChanged;
  final VoidCallback onTrackUpgrade;

  @override
  ConsumerState<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends ConsumerState<_DashboardBody> {
  bool _notesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final upgradesAsync =
        ref.watch(activeUpgradesForVillageProvider(widget.village.id));

    return upgradesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (upgrades) {
        final activeCategory = widget.selectedCategory;
        final activeRealm = widget.selectedRealm;

        final homeBuilderCount = upgrades
            .where((u) => u.category.primaryCategory == UpgradeCategory.homeBuilder)
            .length;
        final homeLabCount = upgrades
            .where((u) => u.category.primaryCategory == UpgradeCategory.homeLab)
            .length;
        final bbBuilderCount = upgrades
            .where((u) =>
                u.category.primaryCategory == UpgradeCategory.builderBaseBuilder)
            .length;
        final bbStarLabCount = upgrades
            .where((u) =>
                u.category.primaryCategory == UpgradeCategory.builderBaseStarLab)
            .length;

        final visibleUpgrades = upgrades
            .where((u) => u.category.primaryCategory == activeCategory)
            .toList();

        final villageService = const VillageService();
        final nextCompletion =
            villageService.nextCompletionAtUtc(visibleUpgrades);

        final totalBuilders = widget.village.builderCapacity;
        final availableHomeBuilders = (totalBuilders - homeBuilderCount).clamp(0, totalBuilders);

        return CustomScrollView(
          slivers: [
            // Top Section: Village Selector (Home Village vs Builder Base)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SegmentedButton<VillageRealm>(
                  segments: const [
                    ButtonSegment(
                      value: VillageRealm.homeVillage,
                      icon: Icon(Icons.fort_outlined, size: 18),
                      label: Text('Home Village'),
                    ),
                    ButtonSegment(
                      value: VillageRealm.builderBase,
                      icon: Icon(Icons.nightlight_round_outlined, size: 18),
                      label: Text('Builder Base'),
                    ),
                  ],
                  selected: {activeRealm},
                  onSelectionChanged: (set) =>
                      widget.onRealmChanged(set.first),
                ),
              ),
            ),

            // Category Selector beneath Village Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: _buildCategorySelector(
                  realm: activeRealm,
                  selectedCategory: activeCategory,
                  homeBuilderCount: homeBuilderCount,
                  homeLabCount: homeLabCount,
                  bbBuilderCount: bbBuilderCount,
                  bbStarLabCount: bbStarLabCount,
                  availableHomeBuilders: availableHomeBuilders,
                  totalHomeBuilders: totalBuilders,
                  onCategorySelected: widget.onCategoryChanged,
                ),
              ),
            ),

            // Lightweight Status Strip (Available builders / research state + Next timer)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    _buildCapacityBadge(
                      realm: activeRealm,
                      category: activeCategory,
                      availableBuilders: availableHomeBuilders,
                      totalBuilders: totalBuilders,
                      activeCount: visibleUpgrades.length,
                    ),
                    const SizedBox(width: 8),
                    if (nextCompletion != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Next: ${_formatDate(nextCompletion)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    if (widget.village.notes != null &&
                        widget.village.notes!.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          _notesExpanded
                              ? Icons.info
                              : Icons.info_outline,
                          size: 18,
                          color: _notesExpanded
                              ? AppColors.accent
                              : AppColors.textMuted,
                        ),
                        tooltip: 'Village notes',
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            setState(() => _notesExpanded = !_notesExpanded),
                      ),
                  ],
                ),
              ),
            ),

            // Expandable Village Notes
            if (_notesExpanded &&
                widget.village.notes != null &&
                widget.village.notes!.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.village.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),

            // Upgrade content for selected category
            visibleUpgrades.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyUpgradesState(
                      categoryName: activeCategory.displayName,
                      onAdd: widget.onTrackUpgrade,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    sliver: SliverList.builder(
                      itemCount: visibleUpgrades.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: UpgradeCard(
                          upgrade: visibleUpgrades[index],
                          village: widget.village,
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelector({
    required VillageRealm realm,
    required UpgradeCategory selectedCategory,
    required int homeBuilderCount,
    required int homeLabCount,
    required int bbBuilderCount,
    required int bbStarLabCount,
    required int availableHomeBuilders,
    required int totalHomeBuilders,
    required ValueChanged<UpgradeCategory> onCategorySelected,
  }) {
    if (realm == VillageRealm.homeVillage) {
      return Row(
        children: [
          Expanded(
            child: _DashboardCategoryCard(
              label: 'Builder',
              icon: Icons.construction_outlined,
              badgeText: '$homeBuilderCount/$totalHomeBuilders',
              selected: selectedCategory == UpgradeCategory.homeBuilder,
              onTap: () => onCategorySelected(UpgradeCategory.homeBuilder),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DashboardCategoryCard(
              label: 'Laboratory',
              icon: Icons.science_outlined,
              badgeText: '$homeLabCount active',
              selected: selectedCategory == UpgradeCategory.homeLab,
              onTap: () => onCategorySelected(UpgradeCategory.homeLab),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _DashboardCategoryCard(
              label: 'Builder',
              icon: Icons.construction_outlined,
              badgeText: '$bbBuilderCount active',
              selected: selectedCategory == UpgradeCategory.builderBaseBuilder,
              onTap: () => onCategorySelected(UpgradeCategory.builderBaseBuilder),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DashboardCategoryCard(
              label: 'Star Laboratory',
              icon: Icons.auto_awesome_outlined,
              badgeText: '$bbStarLabCount active',
              selected: selectedCategory == UpgradeCategory.builderBaseStarLab,
              onTap: () => onCategorySelected(UpgradeCategory.builderBaseStarLab),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCapacityBadge({
    required VillageRealm realm,
    required UpgradeCategory category,
    required int availableBuilders,
    required int totalBuilders,
    required int activeCount,
  }) {
    if (category == UpgradeCategory.homeBuilder) {
      final free = availableBuilders > 0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: free
              ? AppColors.active.withValues(alpha: 0.15)
              : AppColors.pastDue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$availableBuilders/$totalBuilders builders free',
          style: TextStyle(
            color: free ? AppColors.active : AppColors.pastDue,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$activeCount ${activeCount == 1 ? 'upgrade' : 'upgrades'} active',
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
          fontSize: 12,
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

class _DashboardCategoryCard extends StatelessWidget {
  const _DashboardCategoryCard({
    required this.label,
    required this.icon,
    required this.badgeText,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String badgeText;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      color: selected ? AppColors.accentLight : AppColors.textMuted,
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
  const _EmptyUpgradesState({
    required this.categoryName,
    this.onAdd,
  });

  final String categoryName;
  final VoidCallback? onAdd;

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
              'No upgrades running in $categoryName.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (onAdd != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Track new upgrade'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
