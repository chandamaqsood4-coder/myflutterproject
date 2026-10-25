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

/// Formats a quantity without trailing zeros: 19 -> `19`, 2.5 -> `2.5`.
String formatQuantity(double quantity) =>
    quantity.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

/// Parses a user-entered amount (`1,234.5`) into minor units, or null when the
/// text is not a valid non-negative money value with at most two decimals.
int? parseMinorUnits(String text) {
  final normalized = text.trim().replaceAll(',', '');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalized)) return null;

  final parts = normalized.split('.');
  final whole = int.tryParse(parts.first);
  if (whole == null) return null;
  final fraction = parts.length > 1 ? parts[1].padRight(2, '0') : '00';
  return whole * 100 + int.parse(fraction);
}
