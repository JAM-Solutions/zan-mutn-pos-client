import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/services/revenue_config_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';
import 'package:zanmutm_pos_client/src/widgets/app_table.dart';

class RevenueConfigScreen extends StatefulWidget {
  const RevenueConfigScreen({Key? key}) : super(key: key);

  @override
  State<RevenueConfigScreen> createState() => _RevenueConfigScreenState();
}

class _RevenueConfigScreenState extends State<RevenueConfigScreen> {

  List<Map<String, dynamic>> _sources = List.empty(growable: true);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRevenueSources();
  }

  _loadRevenueSources() async {
    setState(() {
      _isLoading = true;
    });
    try {
     var sources = await revenueConfigService.fetchFromApi();
     setState(() {
       _sources = sources.map((e) => e.toJson()).toList();
       _isLoading = false;
     });
    } catch(e) {
      setState(() {
        _isLoading = false;
      });
      AppMessages.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
      isLoading: _isLoading,
      appBar: AppBar(title: const Text('Revenue Sources'),),
        child: AppTable(
          data: _sources,
          columns: [
            AppTableColumn(header: 'Name', value: 'name'),
            AppTableColumn(header: 'Gfs Code', value: 'gfsCode')
          ],
        ));
  }


}
