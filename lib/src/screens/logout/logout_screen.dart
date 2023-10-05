import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/models/format_type.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/generate_bill_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_configuration_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_source_provider.dart';
import 'package:zanmutm_pos_client/src/screens/generate_bill/generate_bill_builder.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  void initState() {
    super.initState();
  }

  _clearConfig() async {
    context.read<PosConfigurationProvider>().posConfiguration = null;
    context.read<RevenueSourceProvider>().revenueSource = List.empty();
    context.read<AppStateProvider>().userLoggedOut();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<AppStateProvider, GenerateBillProvider>(
      create: (_) => GenerateBillProvider(),
      update: (_, userProvider, generateBillProvider) =>
          generateBillProvider!..update(userProvider.user?.taxCollectorUuid),
      child: Consumer<GenerateBillProvider>(
        builder: (context, provider, child) {
          return MessageListener<GenerateBillProvider>(
              child: AppBaseScreen(
            appBar: AppBar(
              title: const Text("Logout"),
            ),
            child: GenerateBillBuilder(
                provider: provider,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (provider.generatedBill != null)
                        AppDetailCard(
                            elevation: 0,
                            title: "Generated Bill",
                            data: {},
                            columns: [
                              AppDetailColumn(
                                  header: 'Amount',
                                  value: provider.generatedBill!.amount,
                                  format: FormatType.currency),
                              AppDetailColumn(
                                  header: 'Control Number',
                                  value: provider.generatedBill!.controlNumber),
                              AppDetailColumn(
                                  header: 'Due time',
                                  value: provider.generatedBill!.dueTime
                                      ?.toIso8601String(),
                                  format: FormatType.date),
                              AppDetailColumn(
                                  header: 'Expire On',
                                  value: provider.generatedBill!.expireDate
                                      ?.toIso8601String(),
                                  format: FormatType.date)
                            ]),
                      if (provider.generatedBill == null)
                        const Text("No pending transaction found"),
                      const SizedBox(
                        height: 8,
                      ),
                      AppButton(
                          onPress: () => _clearConfig(),
                          label: "Click here to complete Logout")
                    ])),
          ));
        },
      ),
    );
  }
}
