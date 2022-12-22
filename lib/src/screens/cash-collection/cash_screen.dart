import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/services/revenue_config_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

class CashScreen extends StatefulWidget {
  const CashScreen({Key? key}) : super(key: key);
  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {


  List<RevenueSource> _sources = List.empty(growable: true);
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadRevenueSources();
  }

  _openCollectionScreen(RevenueSource source) {
    context.push(AppRoutes.cashCollection,extra: source);
  }

  _loadRevenueSources() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var sources = await revenueConfigService.fetchAndStore();
      setState(() {
        _sources = sources;
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
      appBar: AppBar(title: Text("Collect Cash"),),
        child: ListView.separated(
            itemBuilder: (BuildContext context, idx) =>
            ListTile(
              title: Text(_sources[idx].name),
              onTap: () => _openCollectionScreen(_sources[idx]),
            ),
            separatorBuilder: (BuildContext context, idx) =>Divider(),
            itemCount: _sources.length));
  }
}
