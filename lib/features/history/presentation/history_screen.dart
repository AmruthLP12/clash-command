import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';
import 'package:clash_command/domain/models/history_event.dart';
import 'package:clash_command/features/upgrades/application/upgrades_notifier.dart';
import 'package:clash_command/features/villages/application/villages_notifier.dart';

/// Full history and activity log screen.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key, this.initialVillageId});

  final String? initialVillageId;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _selectedVillageId;
  HistoryEventType? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    _selectedVillageId = widget.initialVillageId;
  }

  @override
  Widget build(BuildContext context) {
    final villagesAsync = ref.watch(villagesStreamProvider);
    final eventsAsync = _selectedVillageId != null
        ? ref.watch(villageHistoryEventsProvider(_selectedVillageId!))
        : ref.watch(allHistoryEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          if (_selectedTypeFilter != null || _selectedVillageId != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Clear filters',
              onPressed: () {
                setState(() {
                  _selectedVillageId = null;
                  _selectedTypeFilter = null;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          villagesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (villages) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Villages'),
                      selected: _selectedVillageId == null,
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: _selectedVillageId == null
                            ? Colors.black
                            : AppColors.textSecondary,
                        fontWeight: _selectedVillageId == null
                            ? FontWeight.w700
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                      side: BorderSide.none,
                      onSelected: (_) => setState(() => _selectedVillageId = null),
                    ),
                    const SizedBox(width: 8),
                    ...villages.map((v) {
                      final selected = _selectedVillageId == v.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(v.name),
                          selected: selected,
                          selectedColor: AppColors.accent,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.black
                                : AppColors.textSecondary,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          side: BorderSide.none,
                          onSelected: (_) =>
                              setState(() => _selectedVillageId = v.id),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          // Events list
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (allEvents) {
                final filtered = _selectedTypeFilter != null
                    ? allEvents
                        .where((e) => e.eventType == _selectedTypeFilter)
                        .toList()
                    : allEvents;

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.history,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No activity recorded yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedVillageId != null
                                ? 'No events for the selected village.'
                                : 'Activities will appear here as you track upgrades and villages.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: AppColors.surfaceVariant,
                  ),
                  itemBuilder: (context, index) {
                    final event = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _colorForEvent(event.eventType)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _iconForEvent(event.eventType),
                              size: 18,
                              color: _colorForEvent(event.eventType),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (event.villageName != null) ...[
                                      Text(
                                        event.villageName!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.accentLight,
                                        ),
                                      ),
                                      const Text(
                                        ' • ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                    Text(
                                      DateTimeFormat.shortDateTime(
                                        event.createdAtUtc,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              event.eventType.displayName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForEvent(HistoryEventType type) {
    switch (type) {
      case HistoryEventType.upgradeStarted:
        return Icons.play_arrow;
      case HistoryEventType.upgradeCompleted:
        return Icons.check_circle;
      case HistoryEventType.upgradeCancelled:
        return Icons.cancel;
      case HistoryEventType.upgradeTimerEdited:
        return Icons.schedule;
      case HistoryEventType.upgradeEdited:
        return Icons.edit;
      case HistoryEventType.upgradeReopened:
        return Icons.replay;
      case HistoryEventType.upgradeDeleted:
        return Icons.delete;
      case HistoryEventType.villageCreated:
        return Icons.add_home;
      case HistoryEventType.villageEdited:
        return Icons.edit_note;
      case HistoryEventType.villageArchived:
        return Icons.archive;
      case HistoryEventType.villageDeleted:
        return Icons.delete_forever;
    }
  }

  Color _colorForEvent(HistoryEventType type) {
    switch (type) {
      case HistoryEventType.upgradeCompleted:
        return AppColors.active;
      case HistoryEventType.upgradeStarted:
        return AppColors.accent;
      case HistoryEventType.upgradeCancelled:
        return AppColors.pastDue;
      case HistoryEventType.upgradeDeleted:
        return AppColors.error;
      case HistoryEventType.villageCreated:
        return AppColors.active;
      case HistoryEventType.villageDeleted:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
