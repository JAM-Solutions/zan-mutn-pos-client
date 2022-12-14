import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/auth_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/configuration_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';

class PosConfigScreen extends StatefulWidget {
  const PosConfigScreen({Key? key}) : super(key: key);

  @override
  State<PosConfigScreen> createState() => _PosConfigScreenState();
}

class _PosConfigScreenState extends State<PosConfigScreen> {

  late AppStateProvider authProvider;
  bool _isLoading = false;

  @override
  void initState() {
    authProvider = Provider.of<AppStateProvider>(context, listen: false);
    if (authProvider.posConfiguration == null) {
      _loadConfig();
    }
    super.initState();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
    });
    try {
     var resp = await  fetchPosConfig(1);
     if (resp.data != null && resp.data['data'] != null) {
       authProvider.updateConfiguration(resp.data['data']);
     } else {

     }
     setState(() {
       _isLoading = false;
     });
    } catch(e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint(e.toString());
    }
    debugPrint("Loading config from api ");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
  builder: (context, provider, child) {
  return AppBaseScreen(
        appBar: AppBar(
          title: const Text("Pos Configurations"),
        ),
        isLoading: _isLoading,
        child: ListView(
          children: [
            AppDetailCard(
                title: "Pos Configuration",
                data: provider.posConfiguration != null ? provider.posConfiguration!.toJson() : null,
                columns: [
                  AppDetailColumn(header: 'Device name', value: 'posDeviceName'),
                  AppDetailColumn(header: 'Offline', value: 'offlineLimit'),
                  AppDetailColumn(header: 'Amount Limit', value: 'amountLimit'),
                ],
              actionBuilder: (data) =>IconButton(
                splashRadius: 24,
                padding: EdgeInsets.all(1),
                  onPressed: () => _loadConfig(), icon: const Icon(Icons.sync)),
            )
          ],
        ));
  },
);
  }

}
