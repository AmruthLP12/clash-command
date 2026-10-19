import 'package:uuid/uuid.dart';

/// Generates stable, unique string IDs for domain entities.
///
/// Uses UUID v4 by default. Injecting this class makes tests independent
/// of random values when a fake is substituted.
class IdGenerator {
  const IdGenerator();

  static const _uuid = Uuid();

  String newId() => _uuid.v4();
}
