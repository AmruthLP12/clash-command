import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';
import 'package:clash_command/core/formatting/duration_format.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/services/upgrade_timer_service.dart';
import 'package:clash_command/features/upgrades/application/upgrades_notifier.dart';

/// A card showing an active upgrade with a live countdown.
class UpgradeCard extends ConsumerStatefulWidget {
  const UpgradeCard({super.key, required this.upgrade});

  final Upgrade upgrade;

  @override
  ConsumerState<UpgradeCard> createState() => _UpgradeCardState();
}

class _UpgradeCardState extends ConsumerState<UpgradeCard> {
  Timer? _ticker;
  DateTime _now = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    // Refresh every 30 seconds for countdown display
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() => _now = DateTime.now().toUtc()),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upgrade = widget.upgrade;
    const service = UpgradeTimerService();
    final remaining = service.remainingTime(_now, upgrade);
    final isPastDue = service.isPastDue(_now, upgrade);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: () => _showActions(context, upgrade),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _categoryColor(upgrade.category.name),
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
                      upgrade.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          upgrade.category.displayName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
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
                          Text(
                            upgrade.slotKey!,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Countdown + completion time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isPastDue ? 'Past due' : formatDuration(remaining),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isPastDue ? AppColors.pastDue : AppColors.active,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ends ${DateTimeFormat.shortDateTime(upgrade.expectedCompletionAtUtc)}',
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
      ),
    );
  }

  void _showActions(BuildContext context, Upgrade upgrade) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _UpgradeActionsSheet(upgrade: upgrade),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'hero':
        return Colors.purpleAccent;
      case 'laboratory':
        return Colors.blueAccent;
      case 'defense':
        return Colors.redAccent;
      case 'building':
        return AppColors.accent;
      case 'troop':
        return Colors.teal;
      case 'spell':
        return Colors.deepPurple;
      default:
        return AppColors.textMuted;
    }
  }
}

class _UpgradeActionsSheet extends ConsumerWidget {
  const _UpgradeActionsSheet({required this.upgrade});
  final Upgrade upgrade;

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
              leading: const Icon(Icons.check_circle_outline,
                  color: AppColors.active),
              title: const Text('Mark complete'),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(upgradesNotifierProvider.notifier)
                    .completeUpgrade(upgrade);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined,
                  color: AppColors.pastDue),
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
                      'This will permanently remove "${upgrade.name}".',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
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
