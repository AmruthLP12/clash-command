import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/services/notification_plan_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = NotificationPlanService();
  final now = DateTime.utc(2026, 10, 19, 12, 0, 0);

  Upgrade makeActive({
    String id = 'u1',
    required DateTime completesAt,
  }) =>
      Upgrade(
        id: id,
        villageId: 'v1',
        name: 'Lab upgrade',
        category: UpgradeCategory.laboratory,
        startedAtUtc: now,
        expectedCompletionAtUtc: completesAt,
        status: UpgradeStatus.active,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

  group('NotificationPlanService.completionId and preAlertId', () {
    test('completion ID is stable across invocations', () {
      const upgradeId = 'abc-123';
      expect(service.completionId(upgradeId), service.completionId(upgradeId));
    });

    test('pre-alert IDs differ from completion ID', () {
      const upgradeId = 'abc-123';
      expect(service.preAlertId(upgradeId, 0),
          isNot(equals(service.completionId(upgradeId))));
    });

    test('different upgrade IDs produce different notification IDs', () {
      expect(service.completionId('upgrade-1'),
          isNot(equals(service.completionId('upgrade-2'))));
    });
  });

  group('NotificationPlanService.buildPlan', () {
    test('returns empty list for non-active upgrade', () {
      final completed = makeActive(
        completesAt: now.add(const Duration(hours: 2)),
      ).copyWith(status: UpgradeStatus.completed);
      expect(service.buildPlan(completed, now), isEmpty);
    });

    test('schedules completion + pre-alerts when completion is in the future', () {
      final completesAt = now.add(const Duration(hours: 3));
      final upgrade = makeActive(completesAt: completesAt);
      final plans = service.buildPlan(upgrade, now);

      // 1 completion + 2 pre-alerts (30m and 5m) — all in the future
      expect(plans.length, 3);
      expect(
        plans.any((p) => p.type == NotificationPlanType.completion),
        isTrue,
      );
      expect(
        plans.where((p) => p.type == NotificationPlanType.preAlert).length,
        2,
      );
    });

    test('skips pre-alert when its time has already passed', () {
      // Upgrade completes in 10 minutes — 30m pre-alert is in the past
      final completesAt = now.add(const Duration(minutes: 10));
      final upgrade = makeActive(completesAt: completesAt);
      final plans = service.buildPlan(upgrade, now);

      // 1 completion + 1 pre-alert (5m, which is within 10m window)
      // The 30m pre-alert would be at now - 20m → skipped
      expect(plans.where((p) => p.type == NotificationPlanType.completion).length, 1);
      // 5m pre-alert is at now + 5m → scheduled
      expect(plans.where((p) => p.type == NotificationPlanType.preAlert).length, 1);
    });

    test('skips all notifications when completion is already in the past', () {
      final completesAt = now.subtract(const Duration(minutes: 5));
      final upgrade = makeActive(completesAt: completesAt);
      final plans = service.buildPlan(upgrade, now);
      expect(plans, isEmpty);
    });

    test('completion notification ID is stable', () {
      const id = 'upgrade-abc';
      final upgrade = makeActive(
        id: id,
        completesAt: now.add(const Duration(hours: 2)),
      );
      final plans = service.buildPlan(upgrade, now);
      final completionPlan =
          plans.firstWhere((p) => p.type == NotificationPlanType.completion);
      expect(completionPlan.id, service.completionId(id));
    });

    test('respects custom reminder offsets', () {
      final completesAt = now.add(const Duration(hours: 5));
      final upgrade = makeActive(completesAt: completesAt);
      final plans = service.buildPlan(
        upgrade,
        now,
        reminderOffsetMinutes: [60, 15],
      );
      // 1 completion + 2 custom pre-alerts
      expect(plans.length, 3);
    });

    test('completion notification is omitted when completionEnabled is false', () {
      final completesAt = now.add(const Duration(hours: 2));
      final upgrade = makeActive(completesAt: completesAt);
      final plans = service.buildPlan(
        upgrade,
        now,
        completionEnabled: false,
      );
      expect(
        plans.any((p) => p.type == NotificationPlanType.completion),
        isFalse,
      );
    });
  });

  group('NotificationPlanService.idsForUpgrade', () {
    test('returns IDs including completion and pre-alerts', () {
      const upgradeId = 'u1';
      final ids = service.idsForUpgrade(upgradeId, maxPreAlerts: 2);
      expect(ids.length, 3); // 1 completion + 2 pre-alerts
      expect(ids.contains(service.completionId(upgradeId)), isTrue);
    });

    test('default idsForUpgrade provides 11 IDs to cancel up to 10 pre-alerts', () {
      const upgradeId = 'u1';
      final ids = service.idsForUpgrade(upgradeId);
      expect(ids.length, 11); // 1 completion + 10 pre-alerts
    });

    test('60-second test upgrade calculates completion at exactly 60 seconds and builds completion plan', () {
      final start = DateTime.utc(2026, 10, 22, 10, 0, 0);
      final completesAt = start.add(const Duration(seconds: 60));
      final upgrade = Upgrade(
        id: 'fast-upgrade-1',
        villageId: 'v1',
        name: 'Cannon Lv 1',
        category: UpgradeCategory.defense,
        startedAtUtc: start,
        expectedCompletionAtUtc: completesAt,
        status: UpgradeStatus.active,
        createdAtUtc: start,
        updatedAtUtc: start,
      );

      final testNow = start;
      final plans = service.buildPlan(
        upgrade,
        testNow,
        villageName: 'War Base',
      );

      expect(upgrade.expectedCompletionAtUtc.difference(start).inSeconds, 60);
      expect(plans.length, 1); // 1 completion plan, pre-alerts (minutes) are skipped
      final compPlan = plans.first;
      expect(compPlan.type, NotificationPlanType.completion);
      expect(compPlan.scheduledAtUtc, completesAt);
      expect(compPlan.title, contains('Cannon Lv 1'));
      expect(compPlan.body, contains('War Base'));
    });
  });
}
