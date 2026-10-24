/// Clash of Clans game constants and level configurations.
///
/// Designed to allow future Town Hall and Builder Hall levels (such as TH19)
/// to be added via configuration without requiring code rewrites.
class TownHallConstants {
  const TownHallConstants._();

  /// Minimum supported Town Hall level.
  static const int minLevel = 1;

  /// Maximum currently confirmed and supported Town Hall level.
  /// Increasing this constant enables higher Town Hall levels throughout the app.
  static const int maxSupportedLevel = 18;

  /// List of all supported Town Hall levels in ascending order.
  static List<int> get availableLevels => List.generate(
        maxSupportedLevel - minLevel + 1,
        (i) => minLevel + i,
      );

  /// Validates whether a Town Hall level is within the supported range.
  static bool isValidLevel(int? level) {
    if (level == null) return false;
    return level >= minLevel && level <= maxSupportedLevel;
  }
}

/// Builder Hall level configurations.
class BuilderHallConstants {
  const BuilderHallConstants._();

  static const int minLevel = 1;
  static const int maxSupportedLevel = 10;

  static List<int> get availableLevels => List.generate(
        maxSupportedLevel - minLevel + 1,
        (i) => minLevel + i,
      );

  static bool isValidLevel(int? level) {
    if (level == null) return false;
    return level >= minLevel && level <= maxSupportedLevel;
  }
}

