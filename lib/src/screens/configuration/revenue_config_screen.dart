import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
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
  bool _isLoading = false;
  late PosConfigProvider _configProvider;

  @override
  void initState() {
    _configProvider = Provider.of<PosConfigProvider>(context, listen: false);
    if (_configProvider.revenueSource.isEmpty) {
      _loadRevenueSources();
    }
    _loadRevenueSources();
    super.initState();
  }

  _loadRevenueSources() async {
    setState(() => _isLoading = true);
    try {
      var sources = await revenueConfigService.fetchAndStore();
      _configProvider.setRevenueSources(sources);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      AppMessages.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosConfigProvider>(
      builder: (context, provider, child) {
        return AppBaseScreen(
            isLoading: _isLoading,
            floatingAction: FloatingActionButton(
              onPressed: () =>_loadRevenueSources(),
              child: const Icon(Icons.refresh),
            ),
            appBar: AppBar(
              title: const Text('Revenue Sources'),
            ),
            child: AppTable(
              data: provider.revenueSource.map((e) => e.toJson()).toList(),
              columns: [
                AppTableColumn(header: 'Name', value: 'name'),
                AppTableColumn(header: 'Gfs Code', value: 'gfsCode')
              ],
            ));
      },
    );
  }
}
