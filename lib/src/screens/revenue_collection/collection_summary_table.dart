import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CollectionSummaryTable extends StatelessWidget {
  final List<RevenueItem> items;

  const CollectionSummaryTable({Key? key, required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var language = AppLocalizations.of(context);
    return DataTable(columnSpacing: 10, columns: [
      _getTableHeader(language?.revenue ?? "Revenue"),
      _getTableHeader(language?.quantity ?? "Quantity"),
      _getTableHeader(language?.amount ?? "Amount"),
      _getTableHeader(language?.subTotal ?? "Sub Total"),
    ], rows: [
      ...items.map((e) {
        return DataRow(cells: [
          _getTableCell(e.revenueSource.name),
          _getTableCell(e.quantity.toString()),
          _getTableCell(currency.format(e.amount)),
          _getTableCell(currency.format(e.amount * e.quantity)),
        ]);
      }).toList(),
      DataRow(cells: [
        const DataCell(Text("")),
        const DataCell(Text("")),
        DataCell(Text(
          language?.total ?? "Total",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        )),
        DataCell(Text(
            currency.format(items
                .map((e) => e.amount * e.quantity)
                .fold(0.0, (value, next) => value + next)),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
      ])
    ]);
  }

  _getTableHeader(String label, {double? width}) {
    var h = Text(
      label,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
    );
    return DataColumn(label: h);
  }

  _getTableCell(String value, {double? width}) {
    var h = Text(
      value,
      softWrap: true,
      style: const TextStyle(fontSize: 11),
    );
    return DataCell(h);
  }
}
