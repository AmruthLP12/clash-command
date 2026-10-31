import 'display_preferences.dart';

/// Formats a [DateTime] for display in the UI respecting user preferences.
///
/// All times are converted to local time before formatting so the user
/// sees their own timezone.
class DateTimeFormat {
  DateTimeFormat._();

  /// Default time preference fallback.
  static TimeFormatPreference defaultTimeFormat = TimeFormatPreference.h12;

  /// Default date preference fallback.
  static DateFormatPreference defaultDateFormat = DateFormatPreference.ddMMyyyy;

  /// Formats the time portion only according to [timeFormat].
  ///
  /// E.g. "03:45 PM" (12h) or "15:45" (24h).
  static String timeOnly(DateTime utc, [TimeFormatPreference? timeFormat]) {
    final local = utc.toLocal();
    final format = timeFormat ?? defaultTimeFormat;

    if (format == TimeFormatPreference.h12) {
      final hour24 = local.hour;
      final period = hour24 >= 12 ? 'PM' : 'AM';
      final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
      final mm = local.minute.toString().padLeft(2, '0');
      return '${hour12.toString().padLeft(2, '0')}:$mm $period';
    } else {
      final hh = local.hour.toString().padLeft(2, '0');
      final mm = local.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
  }

  /// Formats the full date portion according to [dateFormat].
  ///
  /// E.g. "31/10/2026", "10/31/2026", or "2026-10-31".
  static String formatDate(DateTime utc, [DateFormatPreference? dateFormat]) {
    final local = utc.toLocal();
    final format = dateFormat ?? defaultDateFormat;
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    switch (format) {
      case DateFormatPreference.mmDDyyyy:
        return '$month/$day/$year';
      case DateFormatPreference.yyyyMMdd:
        return '$year-$month-$day';
      case DateFormatPreference.ddMMyyyy:
        return '$day/$month/$year';
    }
  }

  /// Formats short day & month according to [dateFormat].
  ///
  /// E.g. "31/10", "10/31", or "10-31".
  static String shortDate(DateTime utc, [DateFormatPreference? dateFormat]) {
    final local = utc.toLocal();
    final format = dateFormat ?? defaultDateFormat;
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');

    switch (format) {
      case DateFormatPreference.mmDDyyyy:
        return '$month/$day';
      case DateFormatPreference.yyyyMMdd:
        return '$month-$day';
      case DateFormatPreference.ddMMyyyy:
        return '$day/$month';
    }
  }

  /// "31/10 03:45 PM" or "31/10 15:45" style — short date + formatted time.
  static String shortDateTime(
    DateTime utc, {
    DateFormatPreference? dateFormat,
    TimeFormatPreference? timeFormat,
  }) {
    return '${shortDate(utc, dateFormat)} ${timeOnly(utc, timeFormat)}';
  }

  /// "31/10/2026 03:45 PM" — full date + formatted time.
  static String fullDateTime(
    DateTime utc, {
    DateFormatPreference? dateFormat,
    TimeFormatPreference? timeFormat,
  }) {
    return '${formatDate(utc, dateFormat)} ${timeOnly(utc, timeFormat)}';
  }

  /// Formats completion time using relative calendar labels:
  /// - Same calendar day: "Today, 8:45 PM" (or "Today, 20:45")
  /// - Next calendar day: "Tomorrow, 10:30 AM" (or "Tomorrow, 10:30")
  /// - Any later date: "05/11/2026, 8:45 PM" (using the user's date format)
  ///
  /// Compares local calendar dates to accurately handle near-midnight upgrades.
  static String relativeCompletionDateTime(
    DateTime targetUtc, {
    DateTime? nowUtc,
    DateFormatPreference? dateFormat,
    TimeFormatPreference? timeFormat,
    String prefix = '',
  }) {
    final localTarget = targetUtc.toLocal();
    final localNow = (nowUtc ?? DateTime.now().toUtc()).toLocal();

    final targetDate = DateTime(
      localTarget.year,
      localTarget.month,
      localTarget.day,
    );
    final nowDate = DateTime(localNow.year, localNow.month, localNow.day);
    final dayDifference = targetDate.difference(nowDate).inDays;

    final time = timeOnly(targetUtc, timeFormat);
    final String label;

    if (dayDifference == 0) {
      label = 'Today, $time';
    } else if (dayDifference == 1) {
      label = 'Tomorrow, $time';
    } else {
      label = '${formatDate(targetUtc, dateFormat)}, $time';
    }

    return prefix.isEmpty ? label : '$prefix$label';
  }

  /// "Oct 31, 03:45 PM" style.
  static String mediumDateTime(
    DateTime utc, {
    TimeFormatPreference? timeFormat,
  }) {
    final local = utc.toLocal();
    return '${_monthAbbr(local.month)} ${local.day}, ${timeOnly(utc, timeFormat)}';
  }

  static String _monthAbbr(int month) {
    const abbr = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return abbr[month];
  }
}
