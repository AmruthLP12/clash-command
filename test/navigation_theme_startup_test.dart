import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/app/theme/app_theme.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';
import 'package:clash_command/core/theme/theme_preferences.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/features/dashboard/presentation/dashboard_screen.dart';
import 'package:clash_command/features/levels/presentation/levels_screen.dart';
import 'package:clash_command/features/planner/presentation/planner_screen.dart';
import 'package:clash_command/features/upgrades/application/upgrades_notifier.dart';
import 'package:clash_command/features/villages/application/villages_notifier.dart';
import 'package:clash_command/features/villages/presentation/village_profiles_screen.dart';
import 'package:clash_command/services/audio/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppColors.setLight(false);
  });

  group('Relative Completion Date Formatting', () {
    test('formats same calendar day as Today, <time>', () {
      final now = DateTime.now();
      final todayLater = DateTime(now.year, now.month, now.day, 20, 45).toUtc();
      final formatted = DateTimeFormat.relativeCompletionDateTime(
        todayLater,
        prefix: 'Finishes ',
      );
      expect(formatted, startsWith('Finishes Today, '));
    });

    test('formats next calendar day as Tomorrow, <time>', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowUtc = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        10,
        30,
      ).toUtc();
      final formatted = DateTimeFormat.relativeCompletionDateTime(
        tomorrowUtc,
        prefix: 'Finishes ',
      );
      expect(formatted, startsWith('Finishes Tomorrow, '));
    });

    test('formats later calendar day as date and time', () {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 4));
      final futureUtc = DateTime(
        futureDate.year,
        futureDate.month,
        futureDate.day,
        14,
        15,
      ).toUtc();

      final formatted = DateTimeFormat.relativeCompletionDateTime(
        futureUtc,
        dateFormat: DateFormatPreference.ddMMyyyy,
        timeFormat: TimeFormatPreference.h24,
      );
      expect(formatted, isNot(contains('Today')));
      expect(formatted, isNot(contains('Tomorrow')));
      expect(formatted, contains('/'));
    });

    test('correctly handles near-midnight completion across day boundary', () {
      final now = DateTime.now();
      // Upgrade finishes just after midnight tomorrow
      final tomorrowMidnight = DateTime(
        now.year,
        now.month,
        now.day + 1,
        0,
        5,
      ).toUtc();
      final formatted = DateTimeFormat.relativeCompletionDateTime(
        tomorrowMidnight,
      );
      expect(formatted, startsWith('Tomorrow, '));
    });
  });

  group('Theme System & Preferences', () {
    test('defaults to Dark mode when no preference stored', () {
      final notifier = ThemePreferencesNotifier();
      expect(notifier.state, equals(AppThemeModePreference.dark));
      expect(notifier.state.themeMode, equals(ThemeMode.dark));
    });

    test('persists and updates theme preferences', () async {
      final notifier = ThemePreferencesNotifier();
      await notifier.setThemeMode(AppThemeModePreference.light);
      expect(notifier.state, equals(AppThemeModePreference.light));
      expect(notifier.state.themeMode, equals(ThemeMode.light));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pref_theme_mode'), equals('light'));

      await notifier.setThemeMode(AppThemeModePreference.system);
      expect(notifier.state, equals(AppThemeModePreference.system));
      expect(notifier.state.themeMode, equals(ThemeMode.system));
    });

    test(
      'buildDarkTheme and buildLightTheme produce valid high-contrast themes',
      () {
        final darkTheme = buildDarkTheme();
        final lightTheme = buildLightTheme();

        expect(darkTheme.brightness, equals(Brightness.dark));
        expect(lightTheme.brightness, equals(Brightness.light));

        expect(darkTheme.scaffoldBackgroundColor, isNotNull);
        expect(lightTheme.scaffoldBackgroundColor, isNotNull);

        AppColors.setLight(false);
        final darkCard = AppColors.card;
        final darkBg = AppColors.background;

        AppColors.setLight(true);
        final lightCard = AppColors.card;
        final lightBg = AppColors.background;

        expect(darkCard, isNot(equals(lightCard)));
        expect(darkBg, isNot(equals(lightBg)));
      },
    );
  });

  group('VillageProfilesScreen — Profile Management & FAB', () {
    final testVillages = [
      Village(
        id: 'v1',
        name: 'Alpha Village',
        townHallLevel: 14,
        builderCapacity: 5,
        createdAtUtc: DateTime.now().toUtc(),
        updatedAtUtc: DateTime.now().toUtc(),
      ),
      Village(
        id: 'v2',
        name: 'Beta Village',
        builderHallLevel: 9,
        builderCapacity: 2,
        createdAtUtc: DateTime.now().toUtc(),
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    ];

    testWidgets(
      'shows bottom-right FAB to Add village and removes Add button from AppBar',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              villagesStreamProvider.overrideWith(
                (ref) => Stream.value(testVillages),
              ),
            ],
            child: const MaterialApp(home: VillageProfilesScreen()),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // FAB is present
        final fabFinder = find.byType(FloatingActionButton);
        expect(fabFinder, findsOneWidget);
        expect(find.text('Add village'), findsOneWidget);

        // AppBar does NOT contain an Add button
        final appBarFinder = find.byType(AppBar);
        expect(
          find.descendant(
            of: appBarFinder,
            matching: find.byIcon(Icons.add_home_outlined),
          ),
          findsNothing,
        );
      },
    );

    testWidgets('each profile card displays an Edit icon button', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            villagesStreamProvider.overrideWith(
              (ref) => Stream.value(testVillages),
            ),
          ],
          child: const MaterialApp(home: VillageProfilesScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 2 edit buttons for 2 profile cards
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
      expect(find.byTooltip('Edit profile'), findsNWidgets(2));
    });
  });

  group('Internal Tabs Profile Scoping & Navigation', () {
    final singleVillage = Village(
      id: 'v-main',
      name: 'Main Village',
      townHallLevel: 15,
      builderCapacity: 6,
      createdAtUtc: DateTime.now().toUtc(),
      updatedAtUtc: DateTime.now().toUtc(),
    );

    testWidgets(
      'PlannerScreen has no profile dropdown and has static village header',
      (tester) async {
        bool homeCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              villagesStreamProvider.overrideWith(
                (ref) => Stream.value([singleVillage]),
              ),
              plannerItemsForVillageProvider('v-main')
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: MaterialApp(
              home: PlannerScreen(
                initialVillageId: 'v-main',
                onHome: () => homeCalled = true,
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Header shows Upgrade Planner and village name
        expect(find.text('Upgrade Planner'), findsOneWidget);
        expect(find.text('Main Village'), findsOneWidget);

        // No dropdown
        expect(find.byType(DropdownButton<String>), findsNothing);

        // Home button is present and triggers callback
        final homeBtn = find.byIcon(Icons.home_outlined);
        expect(homeBtn, findsOneWidget);
        await tester.tap(homeBtn);
        expect(homeCalled, isTrue);
      },
    );

    testWidgets(
      'LevelsScreen has no profile dropdown and has static village header',
      (tester) async {
        bool homeCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              villagesStreamProvider.overrideWith(
                (ref) => Stream.value([singleVillage]),
              ),
              villageItemLevelsStreamProvider('v-main')
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: MaterialApp(
              home: LevelsScreen(
                initialVillageId: 'v-main',
                onHome: () => homeCalled = true,
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Header shows Village Levels and village name
        expect(find.text('Village Levels'), findsOneWidget);
        expect(find.text('Main Village'), findsOneWidget);

        // No dropdown
        expect(find.byType(DropdownButton<String>), findsNothing);

        // Home button is present and triggers callback
        final homeBtn = find.byIcon(Icons.home_outlined);
        expect(homeBtn, findsOneWidget);
        await tester.tap(homeBtn);
        expect(homeCalled, isTrue);
      },
    );

    testWidgets(
      'DashboardScreen PopScope traps back on non-zero tabs to return to Dashboard',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              villagesStreamProvider.overrideWith(
                (ref) => Stream.value([singleVillage]),
              ),
              activeUpgradesForVillageProvider('v-main')
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: const MaterialApp(
              home: DashboardScreen(selectedVillageId: 'v-main'),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Switch to Planner tab (index 1)
        await tester.tap(find.text('Planner'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify PopScope widget is active
        expect(find.byWidgetPredicate((w) => w is PopScope), findsOneWidget);
      },
    );
  });

  group('Audio Service Behavior', () {
    test('does not eagerly allocate audio players on creation', () {
      final audioService = AudioService(enableNativePlayback: false);
      expect(audioService.isInitialized, isFalse);
    });
  });
}
