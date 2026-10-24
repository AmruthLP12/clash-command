import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';
import 'package:clash_command/core/formatting/duration_format.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/services/upgrade_timer_service.dart';
import 'package:clash_command/features/upgrades/application/upgrades_notifier.dart';
import 'package:clash_command/features/upgrades/presentation/add_upgrade_sheet.dart';
import 'package:clash_command/features/upgrades/presentation/upgrade_detail_sheet.dart';
import 'package:clash_command/features/villages/application/villages_notifier.dart';

/// A card showing an active upgrade with a live countdown, tap-to-inspect,
/// and visible action controls.
class UpgradeCard extends ConsumerStatefulWidget {
  const UpgradeCard({
    super.key,
    required this.upgrade,
    this.village,
  });

  final Upgrade upgrade;
  final Village? village;

  @override
  ConsumerState<UpgradeCard> createState() => _UpgradeCardState();
}

class _UpgradeCardState extends ConsumerState<UpgradeCard> {
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
  void didUpdateWidget(UpgradeCard oldWidget) {
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

  Village _resolveVillage(WidgetRef ref) {
    if (widget.village != null) return widget.village!;
    final villages = ref.read(villagesStreamProvider).valueOrNull ?? [];
    return villages.firstWhere(
      (v) => v.id == widget.upgrade.villageId,
      orElse: () => Village(
        id: widget.upgrade.villageId,
        name: 'Village',
        createdAtUtc: DateTime.now().toUtc(),
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  void _openDetails(BuildContext context, Village village) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpgradeDetailSheet(
        upgrade: widget.upgrade,
        village: village,
      ),
    );
  }

  void _openEdit(BuildContext context, Village village) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddUpgradeSheet(
        village: village,
        upgrade: widget.upgrade,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upgrade = widget.upgrade;
    final village = _resolveVillage(ref);
    const service = UpgradeTimerService();
    final remaining = service.remainingTime(_now, upgrade);
    final isPastDue = service.isPastDue(_now, upgrade);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetails(context, village),
        onLongPress: () => _showActions(context, upgrade, village),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _categoryColor(upgrade.category),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Name + category + slot
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upgrade.displayNameWithLevel,
                      maxLines: 2,
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
                            upgrade.category.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (upgrade.slotKey != null) ...[
                          const Text(
                            ' • ',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              upgrade.slotKey!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.accentLight,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Countdown + completion time
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 80, maxWidth: 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPastDue
                          ? 'Ready to collect'
                          : formatRemaining(remaining, completedLabel: 'Ready to collect'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isPastDue ? AppColors.pastDue : AppColors.active,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ends ${DateTimeFormat.shortDateTime(upgrade.expectedCompletionAtUtc)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // Visible action menu affordance
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                color: AppColors.surfaceVariant,
                onSelected: (value) async {
                  switch (value) {
                    case 'details':
                      _openDetails(context, village);
                      break;
                    case 'complete':
                      await ref
                          .read(upgradesNotifierProvider.notifier)
                          .completeUpgrade(upgrade);
                      break;
                    case 'edit':
                      _openEdit(context, village);
                      break;
                    case 'cancel':
                      await ref
                          .read(upgradesNotifierProvider.notifier)
                          .cancelUpgrade(upgrade);
                      break;
                    case 'delete':
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
                      if (confirm == true) {
                        await ref
                            .read(upgradesNotifierProvider.notifier)
                            .deleteUpgrade(upgrade.id);
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppColors.textPrimary),
                        SizedBox(width: 8),
                        Text('Details'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 18, color: AppColors.active),
                        SizedBox(width: 8),
                        Text('Complete now'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.accent),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined, size: 18, color: AppColors.pastDue),
                        SizedBox(width: 8),
                        Text('Cancel'),
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
                        Text('Delete', style: TextStyle(color: AppColors.error)),
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

  void _showActions(BuildContext context, Upgrade upgrade, Village village) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _UpgradeActionsSheet(
        upgrade: upgrade,
        village: village,
      ),
    );
  }

  Color _categoryColor(UpgradeCategory category) {
    switch (category.primaryCategory) {
      case UpgradeCategory.homeBuilder:
        return AppColors.accent;
      case UpgradeCategory.homeLab:
        return Colors.blueAccent;
      case UpgradeCategory.builderBaseBuilder:
        return Colors.deepOrangeAccent;
      case UpgradeCategory.builderBaseStarLab:
        return Colors.tealAccent;
      default:
        return AppColors.textMuted;
    }
  }
}

class _UpgradeActionsSheet extends ConsumerWidget {
  const _UpgradeActionsSheet({
    required this.upgrade,
    required this.village,
  });

  final Upgrade upgrade;
  final Village village;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              upgrade.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.textPrimary),
              title: const Text('View full details'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => UpgradeDetailSheet(
                    upgrade: upgrade,
                    village: village,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: AppColors.active),
              title: const Text('Mark complete'),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(upgradesNotifierProvider.notifier)
                    .completeUpgrade(upgrade);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.accent),
              title: const Text('Edit upgrade'),
              onTap: () {
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
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: AppColors.pastDue),
              title: const Text('Cancel upgrade'),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(upgradesNotifierProvider.notifier)
                    .cancelUpgrade(upgrade);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.pop(context);
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
                if (confirm == true) {
                  await ref
                      .read(upgradesNotifierProvider.notifier)
                      .deleteUpgrade(upgrade.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
