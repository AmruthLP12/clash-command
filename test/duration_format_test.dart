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

  group('formatRemaining', () {
    test('returns "Completed" for zero duration', () {
      expect(formatRemaining(Duration.zero), 'Completed');
    });

    test('returns custom completed label for zero duration', () {
      expect(
        formatRemaining(Duration.zero, completedLabel: 'Ready to collect'),
        'Ready to collect',
      );
    });

    test('returns "Completed" for negative duration (never shows negative time)', () {
      expect(formatRemaining(const Duration(seconds: -10)), 'Completed');
      expect(
        formatRemaining(const Duration(seconds: -60), completedLabel: 'Ready to collect'),
        'Ready to collect',
      );
    });

    test('formats MM:SS countdown when strictly less than 5 minutes (< 300s)', () {
      // 4m 59s = 299s
      expect(formatRemaining(const Duration(seconds: 299)), '04:59');
      // 2m 37s = 157s
      expect(formatRemaining(const Duration(seconds: 157)), '02:37');
      // 1m = 60s
      expect(formatRemaining(const Duration(seconds: 60)), '01:00');
      // 45s
      expect(formatRemaining(const Duration(seconds: 45)), '00:45');
      // 9s
      expect(formatRemaining(const Duration(seconds: 9)), '00:09');
      // 1s
      expect(formatRemaining(const Duration(seconds: 1)), '00:01');
    });

    test('formats standard duration when 5 minutes or more (>= 300s)', () {
      // Exactly 5 minutes (300s)
      expect(formatRemaining(const Duration(minutes: 5)), '5m');
      // 2 hours 15 minutes
      expect(formatRemaining(const Duration(hours: 2, minutes: 15)), '2h 15m');
      // 1 day 4 hours
      expect(formatRemaining(const Duration(days: 1, hours: 4)), '1d 4h');
    });
  });
}
