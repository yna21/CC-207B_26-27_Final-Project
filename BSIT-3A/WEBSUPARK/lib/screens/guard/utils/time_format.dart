const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// "10:42"
String formatHm(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

/// "10:42:16"
String formatHms(DateTime d) => '${formatHm(d)}:${_two(d.second)}';

/// "Nov 20"
String formatMonthDay(DateTime d) => '${_months[d.month - 1]} ${d.day}';

/// "Nov 20, 2026"
String formatDate(DateTime d) => '${formatMonthDay(d)}, ${d.year}';

/// "0920" style month+day used in incident numbers.
String monthDayCode(DateTime d) => '${_two(d.month)}${_two(d.day)}';