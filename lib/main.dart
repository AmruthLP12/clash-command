import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/services/upgrade_timer_service.dart';
import 'package:clash_command/domain/services/village_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sampleVillageProvider = Provider<Village>((ref) {
  final now = DateTime.now();

  return Village(
    id: 'village-1',
    name: 'North Village',
    createdAtUtc: now.subtract(const Duration(days: 30)),
    updatedAtUtc: now,
    townHallLevel: 14,
    builderCapacity: 2,
  );
});

final sampleUpgradesProvider = Provider<List<Upgrade>>((ref) {
  final now = DateTime.now();

  return [
    Upgrade(
      id: 'upgrade-1',
      villageId: 'village-1',
      name: 'Laboratory',
      category: 'building',
      startedAtUtc: now.subtract(const Duration(minutes: 30)),
      expectedCompletionAtUtc: now.add(const Duration(hours: 2, minutes: 30)),
      status: UpgradeStatus.active,
    ),
    Upgrade(
      id: 'upgrade-2',
      villageId: 'village-1',
      name: 'Barracks',
      category: 'building',
      startedAtUtc: now.subtract(const Duration(hours: 3)),
      expectedCompletionAtUtc: now.add(const Duration(minutes: 45)),
      status: UpgradeStatus.active,
    ),
    Upgrade(
      id: 'upgrade-3',
      villageId: 'village-2',
      name: 'Wall upgrade',
      category: 'defense',
      startedAtUtc: now.subtract(const Duration(days: 1)),
      expectedCompletionAtUtc: now.subtract(const Duration(minutes: 15)),
      status: UpgradeStatus.completed,
      completedAtUtc: now.subtract(const Duration(minutes: 15)),
    ),
  ];
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clash Command',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB78A2E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const VillageDashboard(),
    );
  }
}

class VillageDashboard extends ConsumerWidget {
  const VillageDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final village = ref.watch(sampleVillageProvider);
    final upgrades = ref.watch(sampleUpgradesProvider);
    final timerService = UpgradeTimerService();
    final villageService = VillageService();
    final now = DateTime.now();
    final activeCount = villageService.activeUpgradeCount(upgrades);
    final nextCompletion = villageService.nextCompletionAtUtc(upgrades);
    final hasPastDue = villageService.hasPastDueUpgrade(upgrades);

    return Scaffold(
      appBar: AppBar(title: const Text('Clash Command'), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Village overview',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track active builds and next completion windows.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          village.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$activeCount active upgrades',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Next completion',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextCompletion == null
                              ? 'No active upgrades'
                              : _formatDate(nextCompletion),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: hasPastDue
                                ? Colors.orange
                                : Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: upgrades.length,
                itemBuilder: (context, index) {
                  final upgrade = upgrades[index];
                  final remaining = timerService.remainingTime(now, upgrade);
                  final isPastDue = timerService.isPastDue(now, upgrade);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  upgrade.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${upgrade.category} • ${upgrade.status.name}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isPastDue
                                    ? 'Past due'
                                    : _formatDuration(remaining),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isPastDue
                                      ? Colors.orange
                                      : Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ends ${_formatDate(upgrade.expectedCompletionAtUtc)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  static String _formatDate(DateTime time) {
    final local = time.toLocal();
    return '${local.day}/${local.month} ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
  }
}
