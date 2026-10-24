// Widget smoke test — verifies the app boots and shows expected structure.
//
// These tests use a ProviderScope with override providers to avoid needing
// a real database or notification service.
import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_theme.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/services/notification_plan_service.dart';
import 'package:clash_command/domain/services/upgrade_lifecycle_service.dart';
import 'package:clash_command/domain/services/upgrade_timer_service.dart';
import 'package:clash_command/domain/services/village_service.dart';
import 'package:clash_command/features/dashboard/presentation/dashboard_screen.dart';
import 'package:clash_command/features/upgrades/presentation/upgrade_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Minimal fake DAO wrappers that return empty streams/lists
import 'helpers/fake_history_events_dao.dart';
import 'helpers/fake_notification_preferences_dao.dart';
import 'helpers/fake_notification_service.dart';
import 'helpers/fake_upgrades_dao.dart';
import 'helpers/fake_villages_dao.dart';

void main() {
  final now = DateTime.utc(2026, 10, 19, 12, 0, 0);

  final fakeVillage = Village(
    id: 'v1',
    name: 'North Village',
    townHallLevel: 14,
    builderCapacity: 2,
    createdAtUtc: now,
    updatedAtUtc: now,
  );

  final fakeUpgrade = Upgrade(
    id: 'u1',
    villageId: 'v1',
    name: 'Laboratory',
    category: UpgradeCategory.laboratory,
    startedAtUtc: now.subtract(const Duration(hours: 1)),
    expectedCompletionAtUtc: now.add(const Duration(hours: 3)),
    status: UpgradeStatus.active,
    createdAtUtc: now,
    updatedAtUtc: now,
  );

  Widget buildTestApp({
    List<Village> villages = const [],
    List<Upgrade> upgrades = const [],
  }) {
    final fakeVillagesDao = FakeVillagesDao(villages);
    final fakeUpgradesDao = FakeUpgradesDao(upgrades);
    final fakeNotifService = FakeNotificationService();
    final fakeHistoryDao = FakeHistoryEventsDao();
    final fakePrefsDao = FakeNotificationPreferencesDao();

    return ProviderScope(
      overrides: [
        villagesDaoProvider.overrideWithValue(fakeVillagesDao),
        upgradesDaoProvider.overrideWithValue(fakeUpgradesDao),
        historyEventsDaoProvider.overrideWithValue(fakeHistoryDao),
        notificationPreferencesDaoProvider.overrideWithValue(fakePrefsDao),
        notificationServiceProvider.overrideWithValue(fakeNotifService),
        upgradeTimerServiceProvider
            .overrideWithValue(const UpgradeTimerService()),
        villageServiceProvider.overrideWithValue(const VillageService()),
        upgradeLifecycleServiceProvider
            .overrideWithValue(const UpgradeLifecycleService()),
        notificationPlanServiceProvider
            .overrideWithValue(const NotificationPlanService()),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        home: const DashboardScreen(),
      ),
    );
  }

  testWidgets('shows empty state when no villages exist', (tester) async {
    await tester.pumpWidget(buildTestApp(villages: []));
    await tester.pump();
    await tester.pump();

    expect(find.text('Clash Command'), findsOneWidget);
    expect(find.text('No villages yet'), findsOneWidget);
  });

  testWidgets('shows village name in switcher when a village exists',
      (tester) async {
    await tester.pumpWidget(buildTestApp(villages: [fakeVillage]));
    await tester.pump();
    await tester.pump();

    expect(find.text('North Village'), findsWidgets);
  });

  testWidgets('shows empty upgrade state when no active upgrades',
      (tester) async {
    await tester.pumpWidget(
      buildTestApp(villages: [fakeVillage], upgrades: []),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('No active upgrades'), findsOneWidget);
  });

  testWidgets('shows upgrade card when an active upgrade exists',
      (tester) async {
    await tester.pumpWidget(
      buildTestApp(villages: [fakeVillage], upgrades: [fakeUpgrade]),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(UpgradeCard), findsOneWidget);
    expect(find.text('Laboratory'), findsWidgets);
  });

  testWidgets('shows Track upgrade FAB when villages exist', (tester) async {
    await tester.pumpWidget(buildTestApp(villages: [fakeVillage]));
    await tester.pump();
    await tester.pump();

    expect(find.text('Track upgrade'), findsOneWidget);
  });
}
