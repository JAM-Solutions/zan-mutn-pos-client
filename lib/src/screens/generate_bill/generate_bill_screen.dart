import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/providers/generate_bill_provider.dart';
import 'package:zanmutm_pos_client/src/screens/generate_bill/generate_bill_builder.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';

import '../../providers/app_state_provider.dart';

class GenerateBillScreen extends StatefulWidget {
  const GenerateBillScreen({Key? key}) : super(key: key);

  @override
  State<GenerateBillScreen> createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  @override
  void initState() {
    super.initState();
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
            child: AppBaseTabScreen(
                floatingActionButton: FloatingActionButton(
                  onPressed: () => provider.getUnCompiled(),
                  child: const Icon(Icons.refresh),
                ),
                child: GenerateBillBuilder(
                  provider: provider,
                  child: const Center(
                    child: Text('No Pending transaction found',textAlign: TextAlign.center,),
                  ),
                )),
          );
        },
      ),
    );
  }
}
