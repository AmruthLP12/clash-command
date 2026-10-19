import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/upgrade_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpgradeCategory', () {
    test('fromString returns correct category', () {
      expect(UpgradeCategory.fromString('building'), UpgradeCategory.building);
      expect(UpgradeCategory.fromString('hero'), UpgradeCategory.hero);
      expect(UpgradeCategory.fromString('defense'), UpgradeCategory.defense);
    });

    test('fromString returns other for unknown value', () {
      expect(UpgradeCategory.fromString('unknown'), UpgradeCategory.other);
    });

    test('displayName is non-empty for all categories', () {
      for (final category in UpgradeCategory.values) {
        expect(category.displayName, isNotEmpty);
      }
    });
  });

  group('UpgradeStatus', () {
    test('fromString returns correct status', () {
      expect(UpgradeStatus.fromString('active'), UpgradeStatus.active);
      expect(UpgradeStatus.fromString('completed'), UpgradeStatus.completed);
      expect(UpgradeStatus.fromString('cancelled'), UpgradeStatus.cancelled);
    });

    test('fromString returns active for unknown value', () {
      expect(UpgradeStatus.fromString('unknown'), UpgradeStatus.active);
    });
  });
}
