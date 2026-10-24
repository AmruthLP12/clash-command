import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';
import 'package:clash_command/core/formatting/duration_format.dart';
import 'package:clash_command/core/ids/id_generator.dart';
import 'package:clash_command/domain/models/history_event.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/models/village_item_level.dart';
import 'package:clash_command/domain/services/upgrade_timer_service.dart';
import 'package:clash_command/features/upgrades/application/upgrades_notifier.dart';
import 'package:clash_command/features/upgrades/presentation/add_upgrade_sheet.dart';

/// Full-detail bottom sheet for an upgrade with visible status actions,
/// edit affordance, and event history.
class UpgradeDetailSheet extends ConsumerStatefulWidget {
  const UpgradeDetailSheet({
    super.key,
    required this.upgrade,
    required this.village,
  });

  final Upgrade upgrade;
  final Village village;

  @override
  ConsumerState<UpgradeDetailSheet> createState() => _UpgradeDetailSheetState();
}

class _UpgradeDetailSheetState extends ConsumerState<UpgradeDetailSheet> {
  Timer? _ticker;
  DateTime _now = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _scheduleTick();
  }

  void _scheduleTick() {
    _ticker?.cancel();
    final remaining = widget.upgrade.expectedCompletionAtUtc.difference(_now);
    if (remaining.inSeconds <= 0) return;

    if (remaining.inSeconds < 300) {
      // 1-second ticker when strictly less than 5 minutes remain
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final curRemaining =
            widget.upgrade.expectedCompletionAtUtc.difference(DateTime.now().toUtc());
        setState(() => _now = DateTime.now().toUtc());
        if (curRemaining.inSeconds <= 0) {
          _ticker?.cancel();
        }
      });
    } else {
      // Periodic check, scheduling next wake-up right at the 300s threshold if within 30s
      final secondsUntil5Min = remaining.inSeconds - 300;
      final nextInterval = secondsUntil5Min > 0 && secondsUntil5Min < 30
          ? Duration(seconds: secondsUntil5Min + 1)
          : const Duration(seconds: 30);
      _ticker = Timer(nextInterval, () {
        if (!mounted) return;
        setState(() => _now = DateTime.now().toUtc());
        _scheduleTick();
      });
    }
  }

  @override
  void didUpdateWidget(UpgradeDetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.upgrade.expectedCompletionAtUtc != widget.upgrade.expectedCompletionAtUtc ||
        oldWidget.upgrade.status != widget.upgrade.status) {
      _now = DateTime.now().toUtc();
      _scheduleTick();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upgrade = widget.upgrade;
    final village = widget.village;
    const timerService = UpgradeTimerService();
    final remaining = timerService.remainingTime(_now, upgrade);
    final isPastDue = timerService.isPastDue(_now, upgrade);
    final totalDuration =
        upgrade.expectedCompletionAtUtc.difference(upgrade.startedAtUtc);
    final elapsed = _now.difference(upgrade.startedAtUtc);
    final progress = totalDuration.inSeconds > 0
        ? (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0)
        : 1.0;

    final historyAsync = ref.watch(upgradeHistoryEventsProvider(upgrade.id));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          upgrade.displayNameWithLevel,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                upgrade.category.displayName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (upgrade.fromLevel != null || upgrade.toLevel != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  upgrade.fromLevel != null && upgrade.toLevel != null
                                      ? 'Lv. ${upgrade.fromLevel} → ${upgrade.toLevel}'
                                      : (upgrade.toLevel != null
                                          ? 'Lv. ${upgrade.toLevel}'
                                          : 'From Lv. ${upgrade.fromLevel}'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (upgrade.slotKey != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  upgrade.slotKey!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: upgrade.status, isPastDue: isPastDue),
                ],
              ),
              const SizedBox(height: 20),

              // Timer / Progress Card
              Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (upgrade.status == UpgradeStatus.active) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Remaining time',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              isPastDue
                                  ? 'Ready to collect'
                                  : formatRemaining(remaining, completedLabel: 'Ready to collect'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isPastDue ? AppColors.pastDue : AppColors.active,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: isPastDue ? 1.0 : progress,
                          backgroundColor: AppColors.surfaceVariant,
                          color: isPastDue ? AppColors.pastDue : AppColors.accent,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Started:',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                          Text(
                            DateTimeFormat.shortDateTime(upgrade.startedAtUtc),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Expected completion:',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                          Text(
                            DateTimeFormat.shortDateTime(upgrade.expectedCompletionAtUtc),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      if (upgrade.completedAtUtc != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Completed at:',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            Text(
                              DateTimeFormat.shortDateTime(upgrade.completedAtUtc!),
                              style: const TextStyle(color: AppColors.active, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Notes section if present
              if (upgrade.notes != null && upgrade.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    upgrade.notes!,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  ),
                ),
              ],

              // Current Level Tracker Integration
              if ((upgrade.toLevel ?? upgrade.fromLevel) != null) ...[
                const SizedBox(height: 16),
                _VillageLevelCard(
                  upgrade: upgrade,
                  village: village,
                ),
              ],
              const SizedBox(height: 20),

              // Visible Action Controls
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (upgrade.status == UpgradeStatus.active) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.active,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref
                            .read(upgradesNotifierProvider.notifier)
                            .completeUpgrade(upgrade);

                        // If upgrade had a target level, update or record in village levels idempotently
                        final destLevel = upgrade.toLevel ?? upgrade.fromLevel;
                        if (destLevel != null) {
                          final existing = await ref
                              .read(villageItemLevelsDaoProvider)
                              .findByItem(
                                upgrade.villageId,
                                upgrade.category,
                                upgrade.name,
                              );
                          if (existing == null) {
                            await ref.read(villageItemLevelsDaoProvider).upsert(
                                  VillageItemLevel(
                                    id: const IdGenerator().newId(),
                                    villageId: upgrade.villageId,
                                    category: upgrade.category,
                                    itemName: upgrade.name,
                                    currentLevel: destLevel,
                                    updatedAtUtc: DateTime.now().toUtc(),
                                  ),
                                );
                          } else if (existing.currentLevel < destLevel) {
                            await ref.read(villageItemLevelsDaoProvider).upsert(
                                  existing.copyWith(
                                    currentLevel: destLevel,
                                    updatedAtUtc: DateTime.now().toUtc(),
                                  ),
                                );
                          }
                        }
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Complete now'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => AddUpgradeSheet(
                            village: village,
                            upgrade: upgrade,
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.pastDue,
                        side: const BorderSide(color: AppColors.pastDue),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref
                            .read(upgradesNotifierProvider.notifier)
                            .cancelUpgrade(upgrade);
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel'),
                    ),
                  ],
                  if (upgrade.status != UpgradeStatus.active) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        // Reopen with remaining 1 day default
                        await ref
                            .read(upgradesNotifierProvider.notifier)
                            .reopenUpgrade(
                              upgrade,
                              DateTime.now().toUtc().add(const Duration(days: 1)),
                            );
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reopen'),
                    ),
                  ],
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete upgrade?'),
                          content: Text(
                            'Permanently delete "${upgrade.name}"? Historical activity will be preserved.',
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
                      if (confirm == true && context.mounted) {
                        Navigator.pop(context);
                        await ref
                            .read(upgradesNotifierProvider.notifier)
                            .deleteUpgrade(upgrade.id);
                      }
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Activity History
              const Text(
                'Activity History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              historyAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (e, _) => Text(
                  'Could not load history: $e',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                data: (events) {
                  if (events.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No history events recorded yet.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _HistoryEventTile(event: event);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.isPastDue});
  final UpgradeStatus status;
  final bool isPastDue;

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    if (status == UpgradeStatus.completed) {
      color = AppColors.completed;
      text = 'Completed';
    } else if (status == UpgradeStatus.cancelled) {
      color = AppColors.cancelled;
      text = 'Cancelled';
    } else if (isPastDue) {
      color = AppColors.pastDue;
      text = 'Past due';
    } else {
      color = AppColors.active;
      text = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HistoryEventTile extends StatelessWidget {
  const _HistoryEventTile({required this.event});
  final HistoryEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _iconForEvent(event.eventType),
            size: 16,
            color: _colorForEvent(event.eventType),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateTimeFormat.shortDateTime(event.createdAtUtc),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
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
      default:
        return Icons.circle;
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
      default:
        return AppColors.textSecondary;
    }
  }
}

class _VillageLevelCard extends ConsumerStatefulWidget {
  const _VillageLevelCard({
    required this.upgrade,
    required this.village,
  });

  final Upgrade upgrade;
  final Village village;

  @override
  ConsumerState<_VillageLevelCard> createState() => _VillageLevelCardState();
}

class _VillageLevelCardState extends ConsumerState<_VillageLevelCard> {
  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    final destLevel = widget.upgrade.toLevel ?? widget.upgrade.fromLevel;
    if (destLevel == null) return const SizedBox.shrink();

    return FutureBuilder<VillageItemLevel?>(
      future: ref.read(villageItemLevelsDaoProvider).findByItem(
            widget.upgrade.villageId,
            widget.upgrade.category,
            widget.upgrade.name,
          ),
      builder: (context, snapshot) {
        final record = snapshot.data;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_list_numbered, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Text(
                    'Village Progress Tracker',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (record != null)
                    Text(
                      'Current: Lv. ${record.currentLevel}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    )
                  else
                    const Text(
                      'Not recorded',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (record == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Track ${widget.upgrade.name} at Lv. $destLevel in ${widget.village.name} levels?',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: _updating
                          ? null
                          : () async {
                              setState(() => _updating = true);
                              try {
                                await ref.read(villageItemLevelsDaoProvider).upsert(
                                      VillageItemLevel(
                                        id: const IdGenerator().newId(),
                                        villageId: widget.upgrade.villageId,
                                        category: widget.upgrade.category,
                                        itemName: widget.upgrade.name,
                                        currentLevel: destLevel,
                                        updatedAtUtc: DateTime.now().toUtc(),
                                      ),
                                    );
                                setState(() {});
                              } finally {
                                if (mounted) setState(() => _updating = false);
                              }
                            },
                      child: const Text('Record Lv.', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ] else if (record.currentLevel < destLevel) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Update tracker from Lv. ${record.currentLevel} → Lv. $destLevel?',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: _updating
                          ? null
                          : () async {
                              setState(() => _updating = true);
                              try {
                                await ref.read(villageItemLevelsDaoProvider).upsert(
                                      record.copyWith(
                                        currentLevel: destLevel,
                                        updatedAtUtc: DateTime.now().toUtc(),
                                      ),
                                    );
                                setState(() {});
                              } finally {
                                if (mounted) setState(() => _updating = false);
                              }
                            },
                      child: Text('Update to Lv. $destLevel', style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.active),
                    const SizedBox(width: 6),
                    Text(
                      'Recorded in levels (Lv. ${record.currentLevel})',
                      style: const TextStyle(fontSize: 12, color: AppColors.active),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

