import 'package:drift/drift.dart';

import '../../core/ids/id_generator.dart';
import '../../domain/catalog/upgrade_catalog.dart';
import '../../domain/models/upgrade_category.dart';
import '../app_database.dart';
import '../tables/custom_upgrade_suggestions_table.dart';

part 'custom_upgrade_suggestions_dao.g.dart';

@DriftAccessor(tables: [CustomUpgradeSuggestions])
class CustomUpgradeSuggestionsDao extends DatabaseAccessor<AppDatabase>
    with _$CustomUpgradeSuggestionsDaoMixin {
  CustomUpgradeSuggestionsDao(super.db);

  /// Streams all custom suggestions for a given primary upgrade category.
  Stream<List<CustomUpgradeSuggestionRow>> watchForCategory(
    UpgradeCategory category,
  ) {
    final primName = category.primaryCategory.name;
    return (select(customUpgradeSuggestions)
          ..where((tbl) => tbl.category.equals(primName))
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.updatedAtUtc,
                  mode: OrderingMode.desc,
                )
          ]))
        .watch();
  }

  /// Gets all custom suggestion names for a given category.
  Future<List<String>> getNamesForCategory(UpgradeCategory category) async {
    final primName = category.primaryCategory.name;
    final rows = await (select(customUpgradeSuggestions)
          ..where((tbl) => tbl.category.equals(primName)))
        .get();
    return rows.map((r) => r.name).toList();
  }

  /// Adds a custom suggestion if it does not already exist in the built-in
  /// catalogue or previously saved custom suggestions (checked case-insensitively).
  Future<bool> addSuggestion(String rawName, UpgradeCategory category) async {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return false;

    final targetCategory = category.primaryCategory;
    final cleanLower = trimmed.toLowerCase();

    // 1. Check against built-in catalogue
    final builtIn = UpgradeCatalog.find(trimmed, targetCategory);
    if (builtIn != null) {
      return false; // Already a built-in suggestion
    }

    // 2. Check against existing custom suggestions in the database
    final existing = await (select(customUpgradeSuggestions)
          ..where(
            (tbl) =>
                tbl.category.equals(targetCategory.name) &
                tbl.name.lower().equals(cleanLower),
          ))
        .get();

    if (existing.isNotEmpty) {
      return false; // Duplicate
    }

    // 3. Insert new custom suggestion
    final now = DateTime.now().toUtc();
    await into(customUpgradeSuggestions).insert(
      CustomUpgradeSuggestionsCompanion.insert(
        id: const IdGenerator().newId(),
        name: trimmed,
        category: targetCategory.name,
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
    return true;
  }
}

