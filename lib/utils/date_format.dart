/// Date formatting used across the app, matching the wireframes.
/// Kept dependency-free (no intl) on purpose.
class DateFormatter {
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
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

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// "18:00"
  static String time(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

  /// "10 Nov 2026" (Edit Event date field)
  static String date(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// "Tue 10 Nov 18:00" (event cards)
  static String card(DateTime d) =>
      '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]} ${time(d)}';

  /// "Tue 10 Nov, 18:00" (Event Detail)
  static String detail(DateTime d) =>
      '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}, ${time(d)}';

  /// Combine the Date and Time pickers' results into one DateTime.
  static DateTime combine(DateTime date, int hour, int minute) =>
      DateTime(date.year, date.month, date.day, hour, minute);
}
