import 'package:intl/intl.dart';

class AppDateFormatter {
  AppDateFormatter._();

  static final DateFormat _tableDate = DateFormat('MMM d, yyyy');

  static String tableDate(dynamic value) {
    if (value == null) return '-';
    final parsed = value is DateTime ? value : DateTime.tryParse(value.toString());
    if (parsed == null) return '-';
    return _tableDate.format(parsed.toLocal());
  }
}
