import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/models/currency.dart';
import 'package:zanmutm_pos_client/src/providers/currency_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_table.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  @override
  void initState() {
    super.initState();
    if (context.read<CurrencyProvider>().currencies.isEmpty) {
      Future.delayed(Duration.zero, () => _loadCurrencies());
    }
  }

  _loadCurrencies() {
    context.read<CurrencyProvider>().fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, provider, child) {
        return MessageListener<CurrencyProvider>(
          child: AppBaseScreen(
              isLoading: provider.isLoading,
              floatingAction: FloatingActionButton(
                onPressed: () => _loadCurrencies(),
                child: const Icon(Icons.refresh),
              ),
              appBar: AppBar(
                title: const Text('Currencies'),
              ),
              child: AppTable(
                data: provider.currencies.map((e) => e.toJson()).toList(),
                columns: [
                  AppTableColumn(header: 'Name', value: 'name'),
                  AppTableColumn(header: 'Code', value: 'code'),
                ],
                leadingBuilder: (currency) => currency['isDefault']
                    ? const Icon(Icons.check)
                    : Container(),
                actionBuilder: (currency) => TextButton(
                    onPressed: () =>
                        provider.setDefault(Currency.fromJson(currency)),
                    child: Row(
                      children: const [Text('Set Default')],
                    )),
              )),
        );
      },
    );
  }
}
