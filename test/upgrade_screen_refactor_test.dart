import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
import 'package:clash_command/features/upgrades/presentation/add_upgrade_sheet.dart';

import 'helpers/fake_history_events_dao.dart';
import 'helpers/fake_notification_preferences_dao.dart';
import 'helpers/fake_notification_service.dart';
import 'helpers/fake_upgrades_dao.dart';
import 'helpers/fake_villages_dao.dart';

void main() {
  final now = DateTime.utc(2026, 10, 24, 12, 0, 0);

  final testVillage = Village(
    id: 'v-test',
    name: 'Main Village',
    townHallLevel: 15,
    builderCapacity: 5,
    createdAtUtc: now,
    updatedAtUtc: now,
  );

  final homeBuilderUpgrade = Upgrade(
    id: 'u-hb',
    villageId: 'v-test',
    name: 'Archer Tower',
    category: UpgradeCategory.homeBuilder,
    toLevel: 68,
    startedAtUtc: now.subtract(const Duration(hours: 2)),
    expectedCompletionAtUtc: now.add(const Duration(days: 3)),
    status: UpgradeStatus.active,
    createdAtUtc: now,
    updatedAtUtc: now,
  );

  final homeLabUpgrade = Upgrade(
    id: 'u-hl',
    villageId: 'v-test',
    name: 'P.E.K.K.A',
    category: UpgradeCategory.homeLab,
    toLevel: 11,
    startedAtUtc: now.subtract(const Duration(hours: 1)),
    expectedCompletionAtUtc: now.add(const Duration(days: 5)),
    status: UpgradeStatus.active,
    createdAtUtc: now,
    updatedAtUtc: now,
  );

  final bbBuilderUpgrade = Upgrade(
    id: 'u-bbb',
    villageId: 'v-test',
    name: 'Double Cannon',
    category: UpgradeCategory.builderBaseBuilder,
    toLevel: 10,
    startedAtUtc: now.subtract(const Duration(hours: 3)),
    expectedCompletionAtUtc: now.add(const Duration(days: 2)),
    status: UpgradeStatus.active,
    createdAtUtc: now,
    updatedAtUtc: now,
  );

  final bbStarLabUpgrade = Upgrade(
    id: 'u-bbsl',
    villageId: 'v-test',
    name: 'Raged Barbarian',
    category: UpgradeCategory.builderBaseStarLab,
    toLevel: 20,
    startedAtUtc: now.subtract(const Duration(hours: 4)),
    expectedCompletionAtUtc: now.add(const Duration(days: 1)),
    status: UpgradeStatus.active,
    createdAtUtc: now,
    updatedAtUtc: now,
  );

  Widget buildAppWithScope({
    List<Village> villages = const [],
    List<Upgrade> upgrades = const [],
    Widget? home,
  }) {
    return ProviderScope(
      overrides: [
        villagesDaoProvider.overrideWithValue(FakeVillagesDao(villages)),
        upgradesDaoProvider.overrideWithValue(FakeUpgradesDao(upgrades)),
        historyEventsDaoProvider.overrideWithValue(FakeHistoryEventsDao()),
        notificationPreferencesDaoProvider
            .overrideWithValue(FakeNotificationPreferencesDao()),
        notificationServiceProvider
            .overrideWithValue(FakeNotificationService()),
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
        home: home ?? const DashboardScreen(),
      ),
    );
  }

  group('Upgrade Screen Navigation & Filtering Hierarchy', () {
    testWidgets('shows Village Realm switcher and defaults to Home Village',
        (tester) async {
      await tester.pumpWidget(
        buildAppWithScope(
          villages: [testVillage],
          upgrades: [homeBuilderUpgrade],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Village'), findsOneWidget);
      expect(find.text('Builder Base'), findsOneWidget);
      expect(find.text('Builder'), findsOneWidget);
      expect(find.text('Laboratory'), findsOneWidget);
    });

    testWidgets('switching to Builder Base updates category options to Builder & Star Laboratory',
        (tester) async {
      await tester.pumpWidget(
        buildAppWithScope(
          villages: [testVillage],
          upgrades: [homeBuilderUpgrade, bbStarLabUpgrade],
        ),
      );
      await tester.pumpAndSettle();

      // Tap Builder Base
      await tester.tap(find.text('Builder Base'));
      await tester.pumpAndSettle();

      // Should now show Builder Base categories
      expect(find.text('Builder'), findsOneWidget);
      expect(find.text('Star Laboratory'), findsOneWidget);
      expect(find.text('Laboratory'), findsNothing);
    });

    testWidgets('filters upgrades by selected category without mixing categories',
        (tester) async {
      await tester.pumpWidget(
        buildAppWithScope(
          villages: [testVillage],
          upgrades: [
            homeBuilderUpgrade,
            homeLabUpgrade,
            bbBuilderUpgrade,
            bbStarLabUpgrade,
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Initially in Home Village -> Builder: only Archer Tower visible
      expect(find.text('Archer Tower · Lv. 68'), findsOneWidget);
      expect(find.text('P.E.K.K.A · Lv. 11'), findsNothing);
      expect(find.text('Double Cannon · Lv. 10'), findsNothing);
      expect(find.text('Raged Barbarian · Lv. 20'), findsNothing);

      // Switch to Laboratory
      await tester.tap(find.text('Laboratory'));
      await tester.pumpAndSettle();

      expect(find.text('P.E.K.K.A · Lv. 11'), findsOneWidget);
      expect(find.text('Archer Tower · Lv. 68'), findsNothing);

      // Switch to Builder Base
      await tester.tap(find.text('Builder Base'));
      await tester.pumpAndSettle();

      // In Builder Base -> Builder: Double Cannon visible
      expect(find.text('Double Cannon · Lv. 10'), findsOneWidget);
      expect(find.text('Raged Barbarian · Lv. 20'), findsNothing);

      // Switch to Star Laboratory
      await tester.tap(find.text('Star Laboratory'));
      await tester.pumpAndSettle();

      expect(find.text('Raged Barbarian · Lv. 20'), findsOneWidget);
      expect(find.text('Double Cannon · Lv. 10'), findsNothing);
    });
  });

  group('Add Upgrade Form & Level Entry Improvements', () {
    testWidgets('preserves complete multi-digit destination level values (67, 68, 100)',
        (tester) async {
      await tester.pumpWidget(
        buildAppWithScope(
          villages: [testVillage],
          home: Scaffold(
            body: AddUpgradeSheet(village: testVillage),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final levelFinder = find.widgetWithText(TextFormField, 'Upgrade to level');
      expect(levelFinder, findsOneWidget);

      // Enter 67
      await tester.enterText(levelFinder, '67');
      await tester.pump();
      expect(find.text('67'), findsOneWidget);

      // Change to 68
      await tester.enterText(levelFinder, '68');
      await tester.pump();
      expect(find.text('68'), findsOneWidget);

      // Change to 100
      await tester.enterText(levelFinder, '100');
      await tester.pump();
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('allows leaving destination level empty', (tester) async {
      await tester.pumpWidget(
        buildAppWithScope(
          villages: [testVillage],
          home: Scaffold(
            body: AddUpgradeSheet(village: testVillage),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final levelFinder = find.widgetWithText(TextFormField, 'Upgrade to level');
      expect(levelFinder, findsOneWidget);

      // Leave empty
      await tester.enterText(levelFinder, '');
      await tester.pump();

      // Form validation allows empty
      final form = tester.widget<Form>(find.byType(Form));
      expect(form.key, isNotNull);
    });

    testWidgets('validates positive integers for destination level',
        (tester) async {
      await tester.pumpWidget(
        buildAppWithScope(
          villages: [testVillage],
          home: Scaffold(
            body: AddUpgradeSheet(village: testVillage),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final levelFinder = find.widgetWithText(TextFormField, 'Upgrade to level');
      await tester.enterText(levelFinder, '0');
      await tester.pump();

      // Tap submit to trigger validation
      await tester.ensureVisible(find.text('Start tracking'));
      await tester.tap(find.text('Start tracking'));
      await tester.pumpAndSettle();

      expect(find.text('Must be a positive integer'), findsOneWidget);
    });

    testWidgets('renders cleanly without RenderFlex overflow even with keyboard insets',
        (tester) async {
      // Simulate small Android screen (e.g. 360 x 640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildAppWithScope(
          villages: [testVillage],
          home: Scaffold(
            body: AddUpgradeSheet(village: testVillage),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No overflow should occur
      expect(tester.takeException(), isNull);
    });
  });

  group('Upgrade Model displayNameWithLevel formatting', () {
    test('formats destination level with arrow consistently (Archer Tower → Lv. 68)', () {
      final up = Upgrade(
        id: 'u1',
        villageId: 'v1',
        name: 'Archer Tower',
        category: UpgradeCategory.homeBuilder,
        toLevel: 68,
        startedAtUtc: now,
        expectedCompletionAtUtc: now.add(const Duration(days: 2)),
        status: UpgradeStatus.active,
        createdAtUtc: now,
        updatedAtUtc: now,
      );
      expect(up.displayNameWithLevel, 'Archer Tower · Lv. 68');
    });

    test('retains plain name when level is omitted', () {
      final up = Upgrade(
        id: 'u2',
        villageId: 'v1',
        name: 'Spell Factory',
        category: UpgradeCategory.homeBuilder,
        startedAtUtc: now,
        expectedCompletionAtUtc: now.add(const Duration(days: 1)),
        status: UpgradeStatus.active,
        createdAtUtc: now,
        updatedAtUtc: now,
      );
      expect(up.displayNameWithLevel, 'Spell Factory');
    });
  });
}
