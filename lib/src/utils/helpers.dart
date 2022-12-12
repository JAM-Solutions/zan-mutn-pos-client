import 'package:zanmutm_pos_client/src/models/format_type.dart';
import 'package:intl/intl.dart';

final currency = NumberFormat("#,##0.00", "en_US");
final dateFormat = DateFormat.yMMMd();

dynamic formatValue(FormatType? format, dynamic value) {
  String valueString;
  switch (format) {
    case FormatType.currency:
      valueString = currency.format(value ?? '');
      break;
    case FormatType.date:
      valueString =
      value != null ? dateFormat.format(DateTime.parse(value)) : '';
      break;
    default:
      valueString = value != null ? value.toString() : '';
  }
  return valueString;
}