// Small date/time helpers so we don't need the intl package.

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// e.g. "Wed, Oct 28"
String fmtDate(DateTime d) =>
    '${_days[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

/// e.g. "9:30 AM"
String fmtTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $ap';
}

/// e.g. "9:00 AM - 9:30 AM"
String fmtRange(DateTime start, DateTime end) =>
    '${fmtTime(start)} - ${fmtTime(end)}';

/// e.g. "Wed, Oct 28 · 9:30 AM"
String fmtDateTime(DateTime d) => '${fmtDate(d)} · ${fmtTime(d)}';

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
