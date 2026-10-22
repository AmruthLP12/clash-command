import 'dart:developer' as developer;
import 'package:home_widget/home_widget.dart';

import '../../database/daos/upgrades_dao.dart';
import '../../database/daos/villages_dao.dart';
import '../../domain/models/village.dart';

/// Synchronizes a lightweight read-only snapshot of the active village,
/// upgrade status, and builder availability to Android Home Screen Widgets.
class HomeWidgetSyncService {
  const HomeWidgetSyncService({
    required this.villagesDao,
    required this.upgradesDao,
  });

  final VillagesDao villagesDao;
  final UpgradesDao upgradesDao;

  static const String upgradeOverviewProvider = 'UpgradeOverviewWidgetProvider';
  static const String builderStatusProvider = 'BuilderStatusWidgetProvider';

  /// Syncs data for the current active village (or first village) to the home widgets.
  Future<void> syncWidgets({String? specificVillageId}) async {
    try {
      final villages = await villagesDao.getAll();
      if (villages.isEmpty) {
        await _clearWidgetData();
        return;
      }

      Village? targetVillage;
      if (specificVillageId != null) {
        targetVillage = villages.firstWhere(
          (v) => v.id == specificVillageId,
          orElse: () => villages.first,
        );
      } else {
        // Default to the first village
        targetVillage = villages.first;
      }

      final activeUpgrades =
          await upgradesDao.getActiveForVillage(targetVillage.id);
      final now = DateTime.now().toUtc();

      // Find nearest upcoming completion
      activeUpgrades.sort(
        (a, b) =>
            a.expectedCompletionAtUtc.compareTo(b.expectedCompletionAtUtc),
      );

      final hasActive = activeUpgrades.isNotEmpty;
      final nearest = hasActive ? activeUpgrades.first : null;

      String nearestTime = '';
      int progressPercent = 0;
      if (nearest != null) {
        final remaining = nearest.expectedCompletionAtUtc.difference(now);
        nearestTime = formatRemaining(remaining);
        progressPercent = computeProgressPercent(
          nearest.startedAtUtc,
          nearest.expectedCompletionAtUtc,
          now,
        );
      }

      // Builder stats
      final totalBuilders = targetVillage.builderCapacity;
      final busyBuilders = activeUpgrades.length;
      final availableBuilders = (totalBuilders - busyBuilders).clamp(0, totalBuilders);

      // Builder occupancy summary text
      final occupancyLines = <String>[];
      for (final u in activeUpgrades.take(4)) {
        final rem = u.expectedCompletionAtUtc.difference(now);
        occupancyLines.add('🔨 ${u.name} (${formatRemaining(rem)})');
      }
      if (activeUpgrades.length > 4) {
        occupancyLines.add('+${activeUpgrades.length - 4} more');
      }
      final occupancyText = occupancyLines.isEmpty
          ? 'All builders are resting.'
          : occupancyLines.join('\n');

      // Save to SharedPreferences for Android widgets
      await HomeWidget.saveWidgetData<String>('village_name', targetVillage.name);
      await HomeWidget.saveWidgetData<int>('active_count', activeUpgrades.length);
      await HomeWidget.saveWidgetData<bool>('has_upgrades', hasActive);
      await HomeWidget.saveWidgetData<String>(
        'nearest_name',
        nearest?.name ?? 'No active upgrades',
      );
      await HomeWidget.saveWidgetData<String>(
        'nearest_category',
        nearest?.category.displayName ?? '',
      );
      await HomeWidget.saveWidgetData<String>('nearest_time', nearestTime);
      await HomeWidget.saveWidgetData<int>('nearest_progress', progressPercent);

      // Builder widget data
      await HomeWidget.saveWidgetData<int>('total_builders', totalBuilders);
      await HomeWidget.saveWidgetData<int>('busy_builders', busyBuilders);
      await HomeWidget.saveWidgetData<int>('available_builders', availableBuilders);
      await HomeWidget.saveWidgetData<String>('builder_occupancy_text', occupancyText);
      await HomeWidget.saveWidgetData<bool>('has_builders', totalBuilders > 0);

      // Update both widgets on Android
      await HomeWidget.updateWidget(
        name: upgradeOverviewProvider,
        androidName: upgradeOverviewProvider,
      );
      await HomeWidget.updateWidget(
        name: builderStatusProvider,
        androidName: builderStatusProvider,
      );

      developer.log(
        'Synced home widgets for village ${targetVillage.name} (${activeUpgrades.length} upgrades)',
        name: 'widgets',
      );
    } catch (e) {
      developer.log('Failed to sync home widgets: $e', name: 'widgets');
    }
  }

  Future<void> _clearWidgetData() async {
    try {
      await HomeWidget.saveWidgetData<String>('village_name', 'No Village');
      await HomeWidget.saveWidgetData<int>('active_count', 0);
      await HomeWidget.saveWidgetData<bool>('has_upgrades', false);
      await HomeWidget.saveWidgetData<String>('nearest_name', 'No active upgrades');
      await HomeWidget.saveWidgetData<String>('nearest_category', '');
      await HomeWidget.saveWidgetData<String>('nearest_time', '');
      await HomeWidget.saveWidgetData<int>('nearest_progress', 0);
      await HomeWidget.saveWidgetData<int>('total_builders', 0);
      await HomeWidget.saveWidgetData<int>('busy_builders', 0);
      await HomeWidget.saveWidgetData<int>('available_builders', 0);
      await HomeWidget.saveWidgetData<String>(
        'builder_occupancy_text',
        'Create a village to track builders.',
      );
      await HomeWidget.saveWidgetData<bool>('has_builders', false);

      await HomeWidget.updateWidget(
        name: upgradeOverviewProvider,
        androidName: upgradeOverviewProvider,
      );
      await HomeWidget.updateWidget(
        name: builderStatusProvider,
        androidName: builderStatusProvider,
      );
    } catch (_) {}
  }

  static String formatRemaining(Duration duration) {
    if (duration.isNegative || duration.inSeconds <= 0) {
      return 'Ready to collect';
    }
    if (duration.inSeconds < 300) {
      final minutes = duration.inSeconds ~/ 60;
      final seconds = duration.inSeconds % 60;
      final mm = minutes.toString().padLeft(2, '0');
      final ss = seconds.toString().padLeft(2, '0');
      return '$mm:$ss';
    }
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    if (days > 0) {
      return hours > 0 ? '${days}d ${hours}h' : '${days}d';
    }
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  static int computeProgressPercent(
    DateTime startedAt,
    DateTime expectedCompletion,
    DateTime now,
  ) {
    final totalMs = expectedCompletion.difference(startedAt).inMilliseconds;
    if (totalMs <= 0) return 100;
    final elapsedMs = now.difference(startedAt).inMilliseconds;
    return (elapsedMs / totalMs * 100).clamp(0, 100).toInt();
  }
}
