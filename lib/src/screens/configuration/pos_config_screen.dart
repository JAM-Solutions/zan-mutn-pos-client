import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/services/pos_config_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

class PosConfigScreen extends StatefulWidget {
  const PosConfigScreen({Key? key}) : super(key: key);

  @override
  State<PosConfigScreen> createState() => _PosConfigScreenState();
}

class _PosConfigScreenState extends State<PosConfigScreen> {
  late PosConfigProvider _configProvider;
  bool _isLoading = false;

  @override
  void initState() {
    _configProvider = Provider.of<PosConfigProvider>(context, listen: false);
    if (_configProvider.posConfiguration == null) {
      _loadConfig();
    }
    super.initState();
  }

  Future<void> _loadConfig() async {
    String? deviceId = _configProvider.deviceInfo?.id;
    if (deviceId == null) {
      AppMessages.showError(context, 'No device id found');
    }
    setState(() => _isLoading = true);
    try {
      PosConfiguration? config =
          await posConfigService.fetchAndStore(deviceId!);
      _configProvider.setPosConfig(config);
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
        var config = provider.posConfiguration;

        return AppBaseScreen(
            appBar: AppBar(
              title: const Text("Pos Configurations"),
            ),
            isLoading: _isLoading,
            floatingAction: FloatingActionButton(
              onPressed: () =>_loadConfig(),
              child: const Icon(Icons.refresh),
            ),
            child: Column(
              children: [
                AppDetailCard(
                  title: "Pos Configuration",
                  subTitle: "POS ID: ${provider.deviceInfo?.id ?? ''}",
                  data: provider.posConfiguration != null
                      ? provider.posConfiguration!.toJson()
                      : null,
                  columns: [
                    AppDetailColumn(
                        header: 'Device name', value: config?.posDeviceName),
                    AppDetailColumn(
                        header: 'Offline Limit', value: config?.offlineLimit),
                    AppDetailColumn(
                        header: 'Amount Limit', value: config?.amountLimit),
                    AppDetailColumn(
                        header: 'Last Update', value: config?.lastUpdate),
                  ],
                ),
              ],
            ));
      },
    );
  }
}
