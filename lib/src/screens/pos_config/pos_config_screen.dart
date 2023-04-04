import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/models/device_info.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/device_info_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_configuration_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';

class PosConfigScreen extends StatefulWidget {
  const PosConfigScreen({Key? key}) : super(key: key);

  @override
  State<PosConfigScreen> createState() => _PosConfigScreenState();
}

class _PosConfigScreenState extends State<PosConfigScreen> {
  User? _user;
   AppDeviceInfo? deviceInfo;

  @override
  void initState() {
    super.initState();
    _user = context.read<AppStateProvider>().user;
    deviceInfo = context.read<DeviceInfoProvider>().deviceInfo;
    Future.delayed(Duration.zero, () => _loadConfig());
  }

  _loadConfig() {
    context
        .read<PosConfigurationProvider>()
        .fetchPosConfig(_user!.taxCollectorUuid!);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosConfigurationProvider>(
      builder: (context, provider, child) {
        var config = provider.posConfiguration;
        return MessageListener<PosConfigurationProvider>(
          child: AppBaseScreen(
              appBar: AppBar(
                title: const Text("Pos Configurations"),
              ),
              isLoading: provider.posConfigIsLoading,
              child: Column(
                children: [
                  AppDetailCard(
                    title: "Pos Configuration",
                    subTitle: deviceInfo?.id ?? "",
                    data: {},
                    columns: [
                      AppDetailColumn(
                          header: 'Offline Limit', value: config?.offlineLimit),
                      AppDetailColumn(
                          header: 'Amount Limit', value: config?.amountLimit),
                      AppDetailColumn(
                          header: 'Last Update', value: config?.lastUpdate),
                    ],
                    actionBuilder: (data) => IconButton(
                        splashRadius: 24,
                        onPressed: () =>
                            provider.fetchPosConfig(_user!.taxCollectorUuid!),
                        icon: const Icon(Icons.sync)),
                  ),
                ],
              )),
        );
      },
    );
  }
}
