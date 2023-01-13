import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class CollectionSummaryTable extends StatelessWidget {
  final List<RevenueItem> items;

  const CollectionSummaryTable({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(columnSpacing: 14, columns: [
      _getTableHeader("Revenue"),
      _getTableHeader("Quantity", width: 50),
      _getTableHeader("Amount", width: 50),
      _getTableHeader("Sub Total", width: 50),
    ], rows: [
      ...items.map((e) {
        return DataRow(cells: [
          _getTableCell(e.revenueSource.name),
          _getTableCell(e.quantity.toString(), width: 50),
          _getTableCell(currency.format(e.amount), width: 50),
          _getTableCell(
              currency.format(e.amount * e.quantity),
              width: 50),
        ]);
      }).toList(),
      DataRow(cells: [
        const DataCell(Text("")),
        const DataCell(Text("")),
        const DataCell(Text(
          "Total",
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold),
        )),
        DataCell(Text(
            currency.format(items
                .map((e) => e.amount * e.quantity)
                .fold(0.0, (value, next) => value + next)),
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold)))
      ])
    ]);
  }

  _getTableHeader(String label, {double? width}) {
    var h = Text(
      label,
      style: const TextStyle(fontSize: 11,fontWeight: FontWeight.bold),
    );
    return DataColumn(label: h);
  }

  _getTableCell(String value, {double? width}) {
    var h = Text(
      value,
      style: const TextStyle(fontSize: 11),
    );
    return DataCell(h);
  }
}
