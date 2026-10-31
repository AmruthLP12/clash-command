import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/core/constants/app_support_links.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';
import 'package:clash_command/core/formatting/display_preferences.dart';
import 'package:clash_command/database/app_database.dart';
import 'package:clash_command/features/dashboard/presentation/dashboard_screen.dart';
import 'package:clash_command/features/settings/presentation/settings_screen.dart';
import 'package:clash_command/features/villages/presentation/village_profiles_screen.dart';
import 'package:clash_command/services/audio/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Support & Dynamic QR Code', () {
    test('AppSupportLinks.qrPayload contains exact requested UPI ID', () {
      expect(AppSupportLinks.qrPayload, equals('9739337301@jupiteraxis'));
    });

    testWidgets('Settings screen renders dynamic QR code and copy button', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          audioServiceProvider.overrideWithValue(
            AudioService(enableNativePlayback: false),
          ),
        ],
      );
      addTearDown(() {
        container.dispose();
        db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Support section is at the top
      expect(find.text('SUPPORT CLASH COMMAND'), findsOneWidget);

      // Verify dynamic QrImageView exists
      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);
      final qrWidget = tester.widget<QrImageView>(qrFinder);
      expect(qrWidget.backgroundColor, equals(Colors.white));

      // Verify clean white container wrapping QR code
      final containerFinder = find.ancestor(
        of: qrFinder,
        matching: find.byType(Container),
      );
      expect(containerFinder, findsWidgets);

      // Verify UPI ID text and instruction
      expect(find.text('9739337301@jupiteraxis'), findsOneWidget);
      expect(
        find.text('Scan with any supported UPI app to support Clash Command.'),
        findsOneWidget,
      );

      // Verify copy button exists and can be tapped
      final copyBtnFinder = find.byTooltip('Copy UPI ID');
      expect(copyBtnFinder, findsOneWidget);
      await tester.tap(copyBtnFinder);
      await tester.pumpAndSettle();
      expect(find.textContaining('UPI ID copied to clipboard'), findsOneWidget);

      // Verify external links: Portfolio, Ko-fi, PayPal
      expect(find.text('Developer Portfolio'), findsOneWidget);
      expect(find.text('Support via Ko-fi'), findsOneWidget);
      expect(find.text('Support via PayPal'), findsOneWidget);

      // Verify simplified external links: no in-app GitHub repository or GitHub profile
      expect(find.text('GitHub Repository'), findsNothing);
      expect(find.text('Developer Profile (GitHub)'), findsNothing);
    });
  });

  group('Display Preferences & DateTime Formatting', () {
    test('DateTimeFormat formats correctly based on preferences', () {
      final testDateUtc = DateTime.utc(2026, 10, 31, 15, 45, 0);

      // 12h vs 24h
      final time12 = DateTimeFormat.timeOnly(testDateUtc, TimeFormatPreference.h12);
      final time24 = DateTimeFormat.timeOnly(testDateUtc, TimeFormatPreference.h24);
      expect(time12, contains('M')); // Contains AM or PM
      expect(time24, matches(r'^\d{2}:\d{2}$'));

      // Date formats
      final ddMMyyyy = DateTimeFormat.formatDate(testDateUtc, DateFormatPreference.ddMMyyyy);
      final mmDDyyyy = DateTimeFormat.formatDate(testDateUtc, DateFormatPreference.mmDDyyyy);
      final yyyyMMdd = DateTimeFormat.formatDate(testDateUtc, DateFormatPreference.yyyyMMdd);

      expect(ddMMyyyy, contains('/'));
      expect(mmDDyyyy, contains('/'));
      expect(yyyyMMdd, contains('-'));
    });

    testWidgets('Settings screen allows changing Time and Date format preferences', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          audioServiceProvider.overrideWithValue(
            AudioService(enableNativePlayback: false),
          ),
        ],
      );
      addTearDown(() {
        container.dispose();
        db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Display section exists
      expect(find.text('DISPLAY & FORMATTING'), findsOneWidget);
      expect(find.text('Time Format'), findsOneWidget);
      expect(find.text('Date Format'), findsOneWidget);

      // Switch to 24-hour time format
      final segment24 = find.text('24-hour (15:45)');
      expect(segment24, findsOneWidget);
      await tester.tap(segment24);
      await tester.pumpAndSettle();

      expect(
        container.read(displayPreferencesProvider).timeFormat,
        equals(TimeFormatPreference.h24),
      );
    });
  });

  group('Profile-First Navigation Flow', () {
    testWidgets('VillageProfilesScreen renders village cards and opens dashboard on tap', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          audioServiceProvider.overrideWithValue(
            AudioService(enableNativePlayback: false),
          ),
        ],
      );
      addTearDown(() {
        container.dispose();
        db.close();
      });

      // Insert two test villages
      await db.into(db.villages).insert(
            VillagesCompanion.insert(
              id: 'village-1',
              name: 'Alpha Village',
              townHallLevel: const Value(15),
              builderHallLevel: const Value(9),
              builderCapacity: const Value(5),
              createdAtUtc: DateTime.utc(2026, 1, 1),
              updatedAtUtc: DateTime.utc(2026, 1, 1),
            ),
          );
      await db.into(db.villages).insert(
            VillagesCompanion.insert(
              id: 'village-2',
              name: 'Beta Village',
              townHallLevel: const Value(12),
              builderCapacity: const Value(4),
              createdAtUtc: DateTime.utc(2026, 1, 1),
              updatedAtUtc: DateTime.utc(2026, 1, 1),
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: VillageProfilesScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Displays both villages as profile cards
      expect(find.text('Alpha Village'), findsOneWidget);
      expect(find.text('Beta Village'), findsOneWidget);
      expect(find.text('TH 15'), findsOneWidget);
      expect(find.text('BH 9'), findsOneWidget);
      expect(find.text('TH 12'), findsOneWidget);

      // Tapping Alpha Village navigates to its Dashboard
      await tester.tap(find.text('Alpha Village'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Dashboard screen is displayed with village name and TH level in AppBar
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Alpha Village'), findsOneWidget);
      expect(find.text('TH 15 · BH 9'), findsOneWidget);

      // Redundant switcher dropdown and horizontal choice chips are absent
      expect(find.byType(ChoiceChip), findsNothing);

      // Back button returns cleanly to profiles
      final backButton = find.byTooltip('Back to profiles');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(VillageProfilesScreen), findsOneWidget);
      expect(find.text('Alpha Village'), findsOneWidget);
    });
  });

  group('Audio Service Pool', () {
    test('Rapid SFX calls do not throw errors or drop states', () async {
      SharedPreferences.setMockInitialValues({});
      final audioService = AudioService(enableNativePlayback: false);

      // Rapidly dispatch multiple SFX calls sequentially
      for (int i = 0; i < 10; i++) {
        audioService.playTap();
        audioService.playVillageSwitch();
        audioService.playUpgradeStart();
      }

      expect(audioService.sfxEnabled, isTrue);
      audioService.dispose();
    });
  });
}
