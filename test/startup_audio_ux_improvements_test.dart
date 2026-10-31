import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/database/app_database.dart';
import 'package:clash_command/domain/catalog/upgrade_catalog.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/features/dashboard/presentation/dashboard_screen.dart';
import 'package:clash_command/features/planner/presentation/add_planner_sheet.dart';
import 'package:clash_command/features/upgrades/presentation/add_upgrade_sheet.dart';
import 'package:clash_command/services/audio/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TH17 Hero Max Levels & Catalogue Data', () {
    test('Hero max levels match TH17 release caps', () {
      final bk = UpgradeCatalog.find('Barbarian King', UpgradeCategory.homeBuilder);
      expect(bk, isNotNull);
      expect(bk!.maxLevel, 100);

      final aq = UpgradeCatalog.find('Archer Queen', UpgradeCategory.homeBuilder);
      expect(aq, isNotNull);
      expect(aq!.maxLevel, 100);

      final gw = UpgradeCatalog.find('Grand Warden', UpgradeCategory.homeBuilder);
      expect(gw, isNotNull);
      expect(gw!.maxLevel, 75);

      final rc = UpgradeCatalog.find('Royal Champion', UpgradeCategory.homeBuilder);
      expect(rc, isNotNull);
      expect(rc!.maxLevel, 50);

      final mp = UpgradeCatalog.find('Minion Prince', UpgradeCategory.homeBuilder);
      expect(mp, isNotNull);
      expect(mp!.maxLevel, 90);

      final dd = UpgradeCatalog.find('Dragon Duke', UpgradeCategory.homeBuilder);
      expect(dd, isNotNull);
      expect(dd!.maxLevel, 20);
      expect(dd.minTownHall, 17);

      final bm = UpgradeCatalog.find('Battle Machine', UpgradeCategory.builderBaseBuilder);
      expect(bm, isNotNull);
      expect(bm!.maxLevel, 35);

      final bc = UpgradeCatalog.find('Battle Copter', UpgradeCategory.builderBaseBuilder);
      expect(bc, isNotNull);
      expect(bc!.maxLevel, 35);
    });
  });

  group('Track Upgrade — Duration Inputs & Transfer', () {
    late AppDatabase db;
    late ProviderContainer container;

    final testVillage = Village(
      id: 'v-test',
      name: 'Test Village',
      townHallLevel: 17,
      builderCapacity: 6,
      createdAtUtc: DateTime.utc(2026, 1, 1),
      updatedAtUtc: DateTime.utc(2026, 1, 1),
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    testWidgets('Duration fields start empty (not prefilled with 0)', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AddUpgradeSheet(village: testVillage),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final daysField = find.widgetWithText(TextFormField, 'Days');
      final hoursField = find.widgetWithText(TextFormField, 'Hours');
      final minField = find.widgetWithText(TextFormField, 'Min');

      expect(daysField, findsOneWidget);
      expect(hoursField, findsOneWidget);
      expect(minField, findsOneWidget);

      final daysWidget = tester.widget<TextFormField>(daysField);
      final hoursWidget = tester.widget<TextFormField>(hoursField);
      final minWidget = tester.widget<TextFormField>(minField);

      expect(daysWidget.controller!.text, isEmpty);
      expect(hoursWidget.controller!.text, isEmpty);
      expect(minWidget.controller!.text, isEmpty);
    });

    testWidgets('initialDurationSeconds transfers duration from Planner to Upgrade Sheet', (tester) async {
      // 2 days, 14 hours, 30 minutes = 2 * 86400 + 14 * 3600 + 30 * 60 = 172800 + 50400 + 1800 = 225000 seconds
      const durSec = 225000;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AddUpgradeSheet(
                village: testVillage,
                initialDurationSeconds: durSec,
                initialName: 'Giga Inferno',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final daysField = find.widgetWithText(TextFormField, 'Days');
      final hoursField = find.widgetWithText(TextFormField, 'Hours');
      final minField = find.widgetWithText(TextFormField, 'Min');

      final daysWidget = tester.widget<TextFormField>(daysField);
      final hoursWidget = tester.widget<TextFormField>(hoursField);
      final minWidget = tester.widget<TextFormField>(minField);

      expect(daysWidget.controller!.text, '2');
      expect(hoursWidget.controller!.text, '14');
      expect(minWidget.controller!.text, '30');
    });

    testWidgets('Validation fails when duration is 0 or empty', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AddUpgradeSheet(
                village: testVillage,
                initialName: 'Cannon',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final trackBtn = find.text('Start tracking');
      await tester.ensureVisible(trackBtn);
      await tester.tap(trackBtn);
      await tester.pumpAndSettle();

      expect(find.text('Duration is required (must be greater than zero).'), findsOneWidget);
    });
  });

  group('Planner Single Resource Cost', () {
    late AppDatabase db;
    late ProviderContainer container;

    final testVillage = Village(
      id: 'v-test',
      name: 'Test Village',
      townHallLevel: 17,
      builderCapacity: 6,
      createdAtUtc: DateTime.utc(2026, 1, 1),
      updatedAtUtc: DateTime.utc(2026, 1, 1),
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    testWidgets('AddPlannerSheet provides single resource selector + amount without + button', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AddPlannerSheet(village: testVillage),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Required Resources (optional)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
      // No '+' button icon or chip wrap
      expect(find.byTooltip('Add resource'), findsNothing);
    });

    testWidgets('AddPlannerSheet saves single resource directly on submit', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AddPlannerSheet(village: testVillage),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name
      final nameField = find.widgetWithText(TextFormField, 'Upgrade name *');
      await tester.enterText(nameField, 'Eagle Artillery');

      // Enter amount
      final amountField = find.widgetWithText(TextFormField, 'Amount');
      await tester.enterText(amountField, '18000000');

      // Save
      final saveBtn = find.text('Add to planner');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final rows = await (db.select(db.plannerItems)..where((t) => t.villageId.equals('v-test'))).get();
      expect(rows, hasLength(1));
      expect(rows.first.name, 'Eagle Artillery');
      expect(rows.first.resourcesJson, contains('Gold'));
      expect(rows.first.resourcesJson, contains('18000000'));
    });
  });

  group('Audio Service & Settings', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('AudioService default state: music OFF, SFX ON', (tester) async {
      final service = AudioService(enableNativePlayback: false);
      expect(service.musicEnabled, isFalse);
      expect(service.sfxEnabled, isTrue);
      service.dispose();
    });

    testWidgets('AudioService toggles and persists settings', (tester) async {
      final service = AudioService(enableNativePlayback: false);
      await service.setMusicEnabled(true);
      expect(service.musicEnabled, isTrue);

      await service.setSfxEnabled(false);
      expect(service.sfxEnabled, isFalse);

      await service.setMusicVolume(0.8);
      expect(service.musicVolume, closeTo(0.8, 0.01));

      await service.setSfxVolume(0.3);
      expect(service.sfxVolume, closeTo(0.3, 0.01));

      service.dispose();
    });
  });

  group('Dashboard Navigation & Profile Switcher', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );

      // Add two villages
      await db.into(db.villages).insert(
            VillagesCompanion.insert(
              id: 'v1',
              name: 'Main Base',
              townHallLevel: const Value(17),
              builderCapacity: const Value(6),
              sortOrder: const Value(0),
              createdAtUtc: DateTime.utc(2026, 1, 1),
              updatedAtUtc: DateTime.utc(2026, 1, 1),
            ),
          );
      await db.into(db.villages).insert(
            VillagesCompanion.insert(
              id: 'v2',
              name: 'Second Base',
              townHallLevel: const Value(15),
              builderCapacity: const Value(5),
              sortOrder: const Value(1),
              createdAtUtc: DateTime.utc(2026, 1, 1),
              updatedAtUtc: DateTime.utc(2026, 1, 1),
            ),
          );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    testWidgets('Dashboard has 4 navbar destinations (Dashboard, Planner, Levels, Settings)', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navBar = find.byType(NavigationBar);
      expect(navBar, findsOneWidget);

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Planner'), findsOneWidget);
      expect(find.text('Levels'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      // History should NOT be in bottom nav
      expect(find.widgetWithText(NavigationDestination, 'History'), findsNothing);
    });

    testWidgets('Dashboard shows prominent village profile chips for multiple villages', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both village chips are displayed prominently
      expect(find.widgetWithText(ChoiceChip, 'Main Base'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Second Base'), findsOneWidget);
    });
  });
}
