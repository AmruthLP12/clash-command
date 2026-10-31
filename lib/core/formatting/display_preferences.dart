import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preference for 12-hour or 24-hour time display.
enum TimeFormatPreference {
  h12('12-hour', '03:45 PM'),
  h24('24-hour', '15:45');

  const TimeFormatPreference(this.label, this.example);
  final String label;
  final String example;

  static TimeFormatPreference fromString(String? value) {
    if (value == 'h24' || value == '24h') return TimeFormatPreference.h24;
    return TimeFormatPreference.h12;
  }
}

/// User preference for calendar date format display.
enum DateFormatPreference {
  ddMMyyyy('DD/MM/YYYY', '31/10/2026'),
  mmDDyyyy('MM/DD/YYYY', '10/31/2026'),
  yyyyMMdd('YYYY-MM-DD', '2026-10-31');

  const DateFormatPreference(this.label, this.example);
  final String label;
  final String example;

  static DateFormatPreference fromString(String? value) {
    if (value == 'mmDDyyyy') return DateFormatPreference.mmDDyyyy;
    if (value == 'yyyyMMdd') return DateFormatPreference.yyyyMMdd;
    return DateFormatPreference.ddMMyyyy;
  }
}

/// State container for user-configured display preferences.
class DisplayPreferences {
  const DisplayPreferences({
    this.timeFormat = TimeFormatPreference.h12,
    this.dateFormat = DateFormatPreference.ddMMyyyy,
  });

  final TimeFormatPreference timeFormat;
  final DateFormatPreference dateFormat;

  DisplayPreferences copyWith({
    TimeFormatPreference? timeFormat,
    DateFormatPreference? dateFormat,
  }) {
    return DisplayPreferences(
      timeFormat: timeFormat ?? this.timeFormat,
      dateFormat: dateFormat ?? this.dateFormat,
    );
  }
}

/// Notifier managing persistence and reactive state of display preferences.
class DisplayPreferencesNotifier extends StateNotifier<DisplayPreferences> {
  DisplayPreferencesNotifier() : super(const DisplayPreferences()) {
    _load();
  }

  static const String prefTimeFormatKey = 'pref_time_format';
  static const String prefDateFormatKey = 'pref_date_format';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString(prefTimeFormatKey);
      final dateStr = prefs.getString(prefDateFormatKey);

      state = DisplayPreferences(
        timeFormat: TimeFormatPreference.fromString(timeStr),
        dateFormat: DateFormatPreference.fromString(dateStr),
      );
    } catch (_) {}
  }

  Future<void> setTimeFormat(TimeFormatPreference format) async {
    state = state.copyWith(timeFormat: format);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefTimeFormatKey, format.name);
    } catch (_) {}
  }

  Future<void> setDateFormat(DateFormatPreference format) async {
    state = state.copyWith(dateFormat: format);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefDateFormatKey, format.name);
    } catch (_) {}
  }
}

final displayPreferencesProvider =
    StateNotifierProvider<DisplayPreferencesNotifier, DisplayPreferences>(
  (ref) => DisplayPreferencesNotifier(),
);

