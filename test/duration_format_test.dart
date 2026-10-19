import 'package:clash_command/core/formatting/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatDuration', () {
    test('returns "< 1m" for zero duration', () {
      expect(formatDuration(Duration.zero), '< 1m');
    });

    test('returns "< 1m" for negative duration', () {
      expect(formatDuration(const Duration(seconds: -10)), '< 1m');
    });

    test('formats minutes only', () {
      expect(formatDuration(const Duration(minutes: 45)), '45m');
    });

    test('formats hours and minutes', () {
      expect(formatDuration(const Duration(hours: 2, minutes: 30)), '2h 30m');
    });

    test('omits zero minutes when hours > 0', () {
      expect(formatDuration(const Duration(hours: 3)), '3h');
    });

    test('formats days, hours, and minutes', () {
      expect(
        formatDuration(
            const Duration(days: 1, hours: 4, minutes: 15)),
        '1d 4h 15m',
      );
    });

    test('formats days only when hours and minutes are zero', () {
      expect(formatDuration(const Duration(days: 2)), '2d');
    });

    test('handles exactly 1 minute', () {
      expect(formatDuration(const Duration(minutes: 1)), '1m');
    });
  });

  group('formatSeconds', () {
    test('converts 3600 seconds to 1h', () {
      expect(formatSeconds(3600), '1h');
    });

    test('converts 90 seconds to 1m (< 2m)', () {
      // 90s = 1m 30s → shows "1m"
      expect(formatSeconds(90), '1m');
    });
  });
}
