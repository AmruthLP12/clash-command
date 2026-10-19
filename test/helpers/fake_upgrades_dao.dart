import 'package:clash_command/database/daos/upgrades_dao.dart';
import 'package:clash_command/domain/models/upgrade.dart';

/// In-test fake that returns fixed upgrade lists without a real database.
class FakeUpgradesDao implements UpgradesDao {
  FakeUpgradesDao(this._upgrades);

  final List<Upgrade> _upgrades;

  List<Upgrade> get _active =>
      _upgrades.where((u) => u.status.name == 'active').toList();

  @override
  Stream<List<Upgrade>> watchActiveForVillage(String villageId) =>
      Stream.value(
        _active.where((u) => u.villageId == villageId).toList(),
      );

  @override
  Stream<List<Upgrade>> watchAllActive() => Stream.value(_active);

  @override
  Stream<List<Upgrade>> watchAllForVillage(String villageId) =>
      Stream.value(_upgrades.where((u) => u.villageId == villageId).toList());

  @override
  Future<Upgrade?> findById(String id) async =>
      _upgrades.cast<Upgrade?>().firstWhere(
            (u) => u?.id == id,
            orElse: () => null,
          );

  @override
  Future<void> upsert(Upgrade upgrade) async {}

  @override
  Future<void> deleteUpgrade(String id) async {}

  @override
  Future<List<Upgrade>> getAllActive() async => _active;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
