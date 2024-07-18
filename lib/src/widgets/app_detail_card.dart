import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/models/format_type.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class AppDetailColumn {
  final String header;
  final dynamic value;
  final FormatType? format;

  AppDetailColumn({
    required this.header,
    required this.value,
    this.format,
  });
}

class AppDetailCard extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Map<String, dynamic>? data;
  final List<AppDetailColumn> columns;
  final double? elevation;
  final bool isNumbered;
  final Widget Function(Map<String, dynamic>? row)? actionBuilder;

  const AppDetailCard(
      {Key? key,
      required this.data,
      required this.columns,
      this.actionBuilder,
      required this.title,
      this.subTitle,
      this.elevation,
      this.isNumbered = false})
      : super(key: key);

  static const TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.normal, color: Color.fromARGB(255, 71, 85, 105));
  static const TextStyle cellStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 71, 85, 105));

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isNumbered ? _buildWithAvatar() :  _buildWithTitle(),
      ),
    );
  }

  _buildWithAvatar() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              children: [
                if (data == null) _buildDataNoData(),
                if (data != null)
                  ...columns.map(
                    (col) => _buildRows(col),
                  ),
                if (actionBuilder != null)
                  SizedBox(
                    child: actionBuilder!(data),
                  ),
              ],
            ),
          )
        ],
      );

  _buildWithTitle() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (subTitle != null)
                    const SizedBox(
                      height: 1,
                    ),
                  if (subTitle != null)
                    Text(subTitle!, style: const TextStyle(fontSize: 11))
                ],
              ),
            ],
          ),
          const Divider(
            height: 12,
            thickness: 1,
          ),
          if (data == null) _buildDataNoData(),
          if (data != null)
            ...columns.map(
              (col) => _buildRows(col),
            ),
          if (actionBuilder != null)
            SizedBox(
              child: actionBuilder!(data),
            ),
        ],
      );

  _buildDataNoData() => const Center(
        child: Text(
          "No data found!",
          style: TextStyle(fontSize: 11),
        ),
      );

  _buildRows(col) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Text(
                col.header,
                style: headerStyle,
              )),
              SizedBox(
                  child: Text(
                formatValue(col.format, col.value),
                style: cellStyle,
              )),
            ],
          ),
          const SizedBox(
            height: 12,
          )
        ],
      );

  _buildAvatar() => CircleAvatar(
        backgroundColor: Colors.blueGrey,
        radius: 12,
        child: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.normal, color: Colors.white, fontSize: 14),
        ),
      );
}
