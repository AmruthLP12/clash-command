import 'package:clash_command/database/daos/villages_dao.dart';
import 'package:clash_command/domain/models/village.dart';

/// In-test fake that returns fixed village lists without a real database.
class FakeVillagesDao implements VillagesDao {
  FakeVillagesDao(this._villages);

  final List<Village> _villages;

  @override
  Stream<List<Village>> watchAll() => Stream.value(_villages);

  @override
  Future<List<Village>> getAll() async => _villages;

  @override
  Future<Village?> findById(String id) async =>
      _villages.cast<Village?>().firstWhere(
            (v) => v?.id == id,
            orElse: () => null,
          );

  @override
  Future<void> upsert(Village village) async {}

  @override
  Future<void> archive(String id) async {}

  @override
  Future<void> deleteVillage(String id) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
