/// Formats an amount stored in minor units (paisa) as `PKR 54,300.00`.
String formatPkr(int minorUnits) {
  final negative = minorUnits < 0;
  final abs = minorUnits.abs();
  final whole = (abs ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final fraction = (abs % 100).toString().padLeft(2, '0');
  return '${negative ? '-' : ''}PKR $whole.$fraction';
}

const List<String> _months = [
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

/// Formats a date as `28 Aug 2026`.
String formatShortDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';
