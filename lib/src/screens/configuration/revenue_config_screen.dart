import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_source_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_table.dart';

class RevenueConfigScreen extends StatefulWidget {
  const RevenueConfigScreen({Key? key}) : super(key: key);

  @override
  State<RevenueConfigScreen> createState() => _RevenueConfigScreenState();
}

class _RevenueConfigScreenState extends State<RevenueConfigScreen> {
  late User? user;

  @override
  void initState() {
    super.initState();
    user = context.read<AppStateProvider>().user;
    _loadRevenueSources();
    if (context.read<RevenueSourceProvider>().revenueSource.isEmpty) {
      Future.delayed(Duration.zero, () => _loadRevenueSources());
    }
  }

  _loadRevenueSources() async {
    context
        .read<RevenueSourceProvider>()
        .loadRevenueSource(user?.taxCollectorUuid);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RevenueSourceProvider>(
      builder: (context, provider, child) {
        return AppBaseScreen(
            isLoading: provider.revSourcesIsLoading,
            floatingAction: FloatingActionButton(
              onPressed: () => _loadRevenueSources(),
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
