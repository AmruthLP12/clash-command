import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/core/ids/id_generator.dart';
import 'package:clash_command/database/app_database.dart';
import 'package:clash_command/database/daos/planner_dao.dart';
import 'package:clash_command/database/daos/village_item_levels_dao.dart';
import 'package:clash_command/database/daos/villages_dao.dart';
import 'package:clash_command/domain/catalog/upgrade_catalog.dart';
import 'package:clash_command/domain/models/game_constants.dart';
import 'package:clash_command/domain/models/planner_item.dart';
import 'package:clash_command/domain/models/upgrade.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/domain/models/village_item_level.dart';
import 'package:clash_command/features/levels/presentation/levels_screen.dart';
import 'package:clash_command/features/planner/presentation/planner_screen.dart';
import 'package:clash_command/features/upgrades/presentation/upgrade_card.dart';

void main() {
  late AppDatabase db;
  late VillagesDao villagesDao;
  late PlannerDao plannerDao;
  late VillageItemLevelsDao levelsDao;

  final now = DateTime.utc(2026, 10, 24, 10, 0);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    villagesDao = VillagesDao(db);
    plannerDao = PlannerDao(db);
    levelsDao = VillageItemLevelsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('1. Builder Hall Level Support & Village Persistence', () {
    test('stores and retrieves Builder Hall level on a village', () async {
      final village = Village(
        id: 'v-bb',
        name: 'Builder Base Village',
        builderHallLevel: 10,
        townHallLevel: null,
        builderCapacity: 2,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      await villagesDao.upsert(village);
      final fetched = await villagesDao.findById('v-bb');

      expect(fetched, isNotNull);
      expect(fetched!.name, 'Builder Base Village');
      expect(fetched.builderHallLevel, 10);
      expect(fetched.townHallLevel, isNull);
    });

    test('supports setting both Town Hall and Builder Hall levels on a multi-realm account', () async {
      final village = Village(
        id: 'v-main',
        name: 'Main Account',
        townHallLevel: 18,
        builderHallLevel: 9,
        builderCapacity: 6,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      await villagesDao.upsert(village);
      final fetched = await villagesDao.findById('v-main');

      expect(fetched!.townHallLevel, 18);
      expect(fetched.builderHallLevel, 9);
    });

    test('validates Builder Hall constants up to level 10', () {
      expect(BuilderHallConstants.minLevel, 1);
      expect(BuilderHallConstants.maxSupportedLevel, 10);
      expect(BuilderHallConstants.availableLevels, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      expect(BuilderHallConstants.isValidLevel(10), isTrue);
      expect(BuilderHallConstants.isValidLevel(11), isFalse);
    });

    test('prioritizes Builder Base catalogue suggestions matching builderHallLevel', () {
      final results = UpgradeCatalog.search(
        query: '',
        category: UpgradeCategory.builderBaseBuilder,
        builderHallLevel: 4,
      );

      expect(results, isNotEmpty);
      // First results should be items unlockable at BH 4 or below
      final firstItem = results.first;
      expect((firstItem.minBuilderHall ?? 1) <= 4, isTrue);
    });
  });

  group('2. Upgrade Planner Operations & Isolation', () {
    test('planned upgrade persists with all fields without starting active timers', () async {
      final plan = PlannerItem(
        id: 'plan-1',
        villageId: 'v-1',
        category: UpgradeCategory.homeBuilder,
        name: 'Eagle Artillery',
        targetLevel: 7,
        priority: 'High',
        notes: 'Upgrade after CWL',
        sortOrder: 0,
        status: 'planned',
        isNext: true,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      await plannerDao.upsert(plan);
      final fetched = await plannerDao.findById('plan-1');

      expect(fetched, isNotNull);
      expect(fetched!.name, 'Eagle Artillery');
      expect(fetched.targetLevel, 7);
      expect(fetched.priority, 'High');
      expect(fetched.status, 'planned');
      expect(fetched.isNext, isTrue);
      expect(fetched.displayNameWithLevel, 'Eagle Artillery · Lv. 7');
    });

    test('can edit, mark as next, and delete planned upgrades', () async {
      final plan1 = PlannerItem(
        id: 'p-1',
        villageId: 'v-1',
        category: UpgradeCategory.homeBuilder,
        name: 'Archer Queen',
        targetLevel: 95,
        priority: 'Medium',
        sortOrder: 0,
        status: 'planned',
        isNext: false,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      final plan2 = PlannerItem(
        id: 'p-2',
        villageId: 'v-1',
        category: UpgradeCategory.homeBuilder,
        name: 'Barbarian King',
        targetLevel: 95,
        priority: 'Low',
        sortOrder: 1,
        status: 'planned',
        isNext: false,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      await plannerDao.upsert(plan1);
      await plannerDao.upsert(plan2);

      // Mark plan2 as next: should set plan2.isNext=true and clear plan1
      await plannerDao.markAsNext('v-1', 'p-2');
      final fetched2 = await plannerDao.findById('p-2');
      final fetched1 = await plannerDao.findById('p-1');
      expect(fetched2!.isNext, isTrue);
      expect(fetched1!.isNext, isFalse);

      // Reorder items
      await plannerDao.reorder('v-1', ['p-2', 'p-1']);
      final reordered2 = await plannerDao.findById('p-2');
      final reordered1 = await plannerDao.findById('p-1');
      expect(reordered2!.sortOrder, 0);
      expect(reordered1!.sortOrder, 1);

      // Update status to started
      await plannerDao.updateStatus('p-2', 'started');
      final started = await plannerDao.findById('p-2');
      expect(started!.status, 'started');

      // Delete item
      await plannerDao.deleteItem('p-1');
      final deleted = await plannerDao.findById('p-1');
      expect(deleted, isNull);
    });
  });

  group('3. Village Item Levels Tracker & Account Scoping', () {
    test('stores and updates current levels scoped strictly to each village', () async {
      final levelV1 = VillageItemLevel(
        id: 'lvl-1',
        villageId: 'v-1',
        category: UpgradeCategory.homeBuilder,
        itemName: 'Archer Tower',
        currentLevel: 18,
        updatedAtUtc: now,
      );

      final levelV2 = VillageItemLevel(
        id: 'lvl-2',
        villageId: 'v-2',
        category: UpgradeCategory.homeBuilder,
        itemName: 'Archer Tower',
        currentLevel: 12,
        updatedAtUtc: now,
      );

      await levelsDao.upsert(levelV1);
      await levelsDao.upsert(levelV2);

      // Query v-1
      final v1Record = await levelsDao.findByItem(
        'v-1',
        UpgradeCategory.homeBuilder,
        'Archer Tower',
      );
      // Query v-2
      final v2Record = await levelsDao.findByItem(
        'v-2',
        UpgradeCategory.homeBuilder,
        'Archer Tower',
      );

      expect(v1Record, isNotNull);
      expect(v1Record!.currentLevel, 18);
      expect(v1Record.villageId, 'v-1');

      expect(v2Record, isNotNull);
      expect(v2Record!.currentLevel, 12);
      expect(v2Record.villageId, 'v-2');

      // Modifying v-1 does not affect v-2
      final updatedV1 = v1Record.copyWith(
        currentLevel: 19,
        updatedAtUtc: now.add(const Duration(days: 1)),
      );
      await levelsDao.upsert(updatedV1);

      final recheckedV1 = await levelsDao.findByItem('v-1', UpgradeCategory.homeBuilder, 'Archer Tower');
      final recheckedV2 = await levelsDao.findByItem('v-2', UpgradeCategory.homeBuilder, 'Archer Tower');

      expect(recheckedV1!.currentLevel, 19);
      expect(recheckedV2!.currentLevel, 12); // Unaltered
    });

    test('updating levels to target level is idempotent and avoids duplicate increments', () async {
      final record = VillageItemLevel(
        id: 'lvl-c1',
        villageId: 'v-1',
        category: UpgradeCategory.homeBuilder,
        itemName: 'Cannon',
        currentLevel: 15,
        updatedAtUtc: now,
      );
      await levelsDao.upsert(record);

      const targetLevel = 16;

      // First completion update
      final existing1 = await levelsDao.findByItem('v-1', UpgradeCategory.homeBuilder, 'Cannon');
      expect(existing1!.currentLevel, 15);
      if (existing1.currentLevel < targetLevel) {
        await levelsDao.upsert(existing1.copyWith(currentLevel: targetLevel, updatedAtUtc: now));
      }

      final afterFirst = await levelsDao.findByItem('v-1', UpgradeCategory.homeBuilder, 'Cannon');
      expect(afterFirst!.currentLevel, 16);

      // Duplicate revisit / completion click
      final existing2 = await levelsDao.findByItem('v-1', UpgradeCategory.homeBuilder, 'Cannon');
      if (existing2!.currentLevel < targetLevel) {
        await levelsDao.upsert(existing2.copyWith(currentLevel: targetLevel, updatedAtUtc: now));
      }

      final afterSecond = await levelsDao.findByItem('v-1', UpgradeCategory.homeBuilder, 'Cannon');
      expect(afterSecond!.currentLevel, 16); // Still exactly 16, no double increment
    });
  });

  group('4. Cleaner Upgrade Cards (Redundant Label Removal)', () {
    testWidgets('omits redundant category label from upgrade card when showCategory is false', (tester) async {
      final upgrade = Upgrade(
        id: 'u-1',
        villageId: 'v-1',
        name: 'Hidden Tesla',
        category: UpgradeCategory.homeBuilder,
        slotKey: 'Builder 3',
        startedAtUtc: now,
        expectedCompletionAtUtc: now.add(const Duration(days: 1)),
        status: UpgradeStatus.active,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      final village = Village(
        id: 'v-1',
        name: 'Main Village',
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: UpgradeCard(
                upgrade: upgrade,
                village: village,
                showCategory: false, // Default in dashboard
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Card shows name and slotKey
      expect(find.text('Hidden Tesla'), findsOneWidget);
      expect(find.text('Builder 3'), findsOneWidget);

      // Card does NOT display redundant category label "Home Village — Builder"
      expect(find.text(UpgradeCategory.homeBuilder.displayName), findsNothing);
    });

    testWidgets('displays category label only when showCategory is explicitly true', (tester) async {
      final upgrade = Upgrade(
        id: 'u-1',
        villageId: 'v-1',
        name: 'Dragon',
        category: UpgradeCategory.homeLab,
        startedAtUtc: now,
        expectedCompletionAtUtc: now.add(const Duration(days: 1)),
        status: UpgradeStatus.active,
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      final village = Village(
        id: 'v-1',
        name: 'Main Village',
        createdAtUtc: now,
        updatedAtUtc: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: UpgradeCard(
                upgrade: upgrade,
                village: village,
                showCategory: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dragon'), findsOneWidget);
      expect(find.text(UpgradeCategory.homeLab.displayName), findsOneWidget);
    });
  });
}

