/// Formats a [Duration] as a human-readable countdown string.
///
/// Examples:
///   3d 4h 5m → "3d 4h 5m"
///   0h 45m   → "45m"
///   0h 0m    → "< 1m"
String formatDuration(Duration duration) {
  if (duration <= Duration.zero) return '< 1m';

  final days = duration.inDays;
  final hours = duration.inHours.remainder(24);
  final minutes = duration.inMinutes.remainder(60);

  final parts = <String>[];
  if (days > 0) parts.add('${days}d');
  if (hours > 0) parts.add('${hours}h');
  if (minutes > 0 || parts.isEmpty) parts.add('${minutes}m');

  return parts.join(' ');
}

/// Formats a [Duration] using days/hours/minutes with no shortening.
String formatDurationVerbose(Duration duration) {
  if (duration <= Duration.zero) return '0 minutes';
  final days = duration.inDays;
  final hours = duration.inHours.remainder(24);
  final minutes = duration.inMinutes.remainder(60);
  final parts = <String>[];
  if (days == 1) parts.add('1 day');
  if (days > 1) parts.add('$days days');
  if (hours == 1) parts.add('1 hour');
  if (hours > 1) parts.add('$hours hours');
  if (minutes == 1) parts.add('1 minute');
  if (minutes > 1) parts.add('$minutes minutes');
  return parts.join(' ');
}

/// Formats a total-seconds integer as a duration string.
String formatSeconds(int totalSeconds) {
  return formatDuration(Duration(seconds: totalSeconds));
}
