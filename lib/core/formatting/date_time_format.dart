/// Formats a [DateTime] for display in the UI.
///
/// All times are converted to local time before formatting so the user
/// sees their own timezone.
class DateTimeFormat {
  DateTimeFormat._();

  /// "19/10 14:30" style — day/month hour:minute
  static String shortDateTime(DateTime utc) {
    final local = utc.toLocal();
    return '${local.day}/${local.month} '
        '${local.hour}:${local.minute.toString().padLeft(2, '0')}';
  }

  /// "Oct 19, 14:30" style
  static String mediumDateTime(DateTime utc) {
    final local = utc.toLocal();
    return '${_monthAbbr(local.month)} ${local.day}, '
        '${local.hour}:${local.minute.toString().padLeft(2, '0')}';
  }

  /// Returns the time portion only: "14:30"
  static String timeOnly(DateTime utc) {
    final local = utc.toLocal();
    return '${local.hour}:${local.minute.toString().padLeft(2, '0')}';
  }

  static String _monthAbbr(int month) {
    const abbr = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return abbr[month];
  }
}
