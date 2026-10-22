import 'package:clash_command/services/widgets/home_widget_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeWidgetSyncService formatRemaining', () {
    test('returns "Ready to collect" for negative or zero duration', () {
      expect(
        HomeWidgetSyncService.formatRemaining(const Duration(seconds: 0)),
        'Ready to collect',
      );
      expect(
        HomeWidgetSyncService.formatRemaining(const Duration(seconds: -10)),
        'Ready to collect',
      );
    });

    test('formats MM:SS when strictly less than 5 minutes (< 300s)', () {
      expect(
        HomeWidgetSyncService.formatRemaining(const Duration(seconds: 299)),
        '04:59',
      );
      expect(
        HomeWidgetSyncService.formatRemaining(const Duration(seconds: 157)),
        '02:37',
      );
      expect(
        HomeWidgetSyncService.formatRemaining(const Duration(seconds: 60)),
        '01:00',
      );
      expect(
        HomeWidgetSyncService.formatRemaining(const Duration(seconds: 45)),
        '00:45',
      );
      expect(
        HomeWidgetSyncService.formatRemaining(const Duration(seconds: 9)),
        '00:09',
      );
      expect(
        HomeWidgetSyncService.formatRemaining(const Duration(seconds: 1)),
        '00:01',
      );
    });

    test('formats minutes when less than 1 hour', () {
      expect(
        HomeWidgetSyncService.formatRemaining(const Duration(minutes: 25)),
        '25m',
      );
    });

    test('formats hours and minutes when less than 1 day', () {
      expect(
        HomeWidgetSyncService.formatRemaining(
          const Duration(hours: 3, minutes: 42),
        ),
        '3h 42m',
      );
    });

    test('formats days and hours when 1 day or more', () {
      expect(
        HomeWidgetSyncService.formatRemaining(
          const Duration(days: 4, hours: 16),
        ),
        '4d 16h',
      );
    });
  });

  group('HomeWidgetSyncService computeProgressPercent', () {
    final start = DateTime.utc(2026, 10, 22, 10, 0, 0);
    final end = DateTime.utc(2026, 10, 22, 12, 0, 0); // 2 hours

    test('returns 0 when now is equal to start', () {
      expect(
        HomeWidgetSyncService.computeProgressPercent(start, end, start),
        0,
      );
    });

    test('returns 50 halfway through duration', () {
      final mid = start.add(const Duration(hours: 1));
      expect(
        HomeWidgetSyncService.computeProgressPercent(start, end, mid),
        50,
      );
    });

    test('returns 100 when now is equal to or past completion', () {
      expect(
        HomeWidgetSyncService.computeProgressPercent(start, end, end),
        100,
      );
      final past = end.add(const Duration(hours: 1));
      expect(
        HomeWidgetSyncService.computeProgressPercent(start, end, past),
        100,
      );
    });

    test('clamps percent to 0-100 even if now is before start', () {
      final before = start.subtract(const Duration(minutes: 10));
      expect(
        HomeWidgetSyncService.computeProgressPercent(start, end, before),
        0,
      );
    });
  });
}

