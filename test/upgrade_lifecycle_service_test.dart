import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/services/upgrade_lifecycle_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = UpgradeLifecycleService();
  final now = DateTime.utc(2026, 10, 19, 12, 0, 0);

  Upgrade makeActive({String id = 'u1'}) => Upgrade(
        id: id,
        villageId: 'v1',
        name: 'Test',
        category: UpgradeCategory.building,
        startedAtUtc: now.subtract(const Duration(hours: 1)),
        expectedCompletionAtUtc: now.add(const Duration(hours: 2)),
        status: UpgradeStatus.active,
        notificationRevision: 0,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

  Upgrade makeCompleted() => makeActive().copyWith(
        status: UpgradeStatus.completed,
        completedAtUtc: now.subtract(const Duration(minutes: 10)),
      );

  Upgrade makeCancelled() => makeActive().copyWith(status: UpgradeStatus.cancelled);

  group('UpgradeLifecycleService.complete', () {
    test('transitions active → completed', () {
      final result = service.complete(makeActive(), now);
      expect(result.isSuccess, isTrue);
      expect(result.value.status, UpgradeStatus.completed);
      expect(result.value.completedAtUtc, now);
    });

    test('bumps notificationRevision on completion', () {
      final result = service.complete(makeActive(), now);
      expect(result.value.notificationRevision, 1);
    });

    test('fails when upgrade is already completed', () {
      final result = service.complete(makeCompleted(), now);
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
    });

    test('fails when upgrade is cancelled', () {
      final result = service.complete(makeCancelled(), now);
      expect(result.isFailure, isTrue);
    });
  });

  group('UpgradeLifecycleService.cancel', () {
    test('transitions active → cancelled', () {
      final result = service.cancel(makeActive(), now);
      expect(result.isSuccess, isTrue);
      expect(result.value.status, UpgradeStatus.cancelled);
    });

    test('bumps notificationRevision on cancellation', () {
      final result = service.cancel(makeActive(), now);
      expect(result.value.notificationRevision, 1);
    });

    test('fails when upgrade is already cancelled', () {
      final result = service.cancel(makeCancelled(), now);
      expect(result.isFailure, isTrue);
    });

    test('fails when upgrade is completed', () {
      final result = service.cancel(makeCompleted(), now);
      expect(result.isFailure, isTrue);
    });
  });

  group('UpgradeLifecycleService.reopen', () {
    final futureCompletion = DateTime.utc(2026, 10, 20, 12, 0, 0);

    test('reopens a completed upgrade to active', () {
      final result = service.reopen(makeCompleted(), futureCompletion, now);
      expect(result.isSuccess, isTrue);
      expect(result.value.status, UpgradeStatus.active);
      expect(result.value.completedAtUtc, isNull);
      expect(result.value.expectedCompletionAtUtc, futureCompletion);
    });

    test('reopens a cancelled upgrade to active', () {
      final result = service.reopen(makeCancelled(), futureCompletion, now);
      expect(result.isSuccess, isTrue);
      expect(result.value.status, UpgradeStatus.active);
    });

    test('fails when upgrade is already active', () {
      final result = service.reopen(makeActive(), futureCompletion, now);
      expect(result.isFailure, isTrue);
    });
  });

  group('UpgradeLifecycleService.editTimer', () {
    test('updates expectedCompletionAtUtc and bumps revision', () {
      final newTime = now.add(const Duration(hours: 4));
      final result = service.editTimer(makeActive(), newTime, now);
      expect(result.isSuccess, isTrue);
      expect(result.value.expectedCompletionAtUtc, newTime);
      expect(result.value.notificationRevision, 1);
    });

    test('fails when new completion is in the past', () {
      final pastTime = now.subtract(const Duration(minutes: 1));
      final result = service.editTimer(makeActive(), pastTime, now);
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
    });

    test('fails when upgrade is not active', () {
      final newTime = now.add(const Duration(hours: 1));
      final result = service.editTimer(makeCompleted(), newTime, now);
      expect(result.isFailure, isTrue);
    });
  });
}
