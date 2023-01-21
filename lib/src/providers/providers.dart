import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/generate_bill_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_collection_provider.dart';
import 'package:zanmutm_pos_client/src/providers/device_info_provider.dart';
import 'package:zanmutm_pos_client/src/providers/financial_year_provider.dart';
import 'package:zanmutm_pos_client/src/providers/login_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_configuration_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_status_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_source_provider.dart';
import 'package:zanmutm_pos_client/src/providers/tab_provider.dart';

final appProviders = [
  ChangeNotifierProvider<AppStateProvider>(create: (_) => appStateProvider),
  ChangeNotifierProvider<PosConfigurationProvider>(
    create: (_) => PosConfigurationProvider(),
  ),
  ChangeNotifierProvider<TabProvider>(create: (_) => tabProvider),
  ChangeNotifierProvider<FinancialYearProvider>(
      create: (_) => FinancialYearProvider()),
  ChangeNotifierProvider<RevenueSourceProvider>(
      create: (_) => RevenueSourceProvider()),
  ChangeNotifierProvider<DeviceInfoProvider>(
      create: (_) => DeviceInfoProvider()),
  ChangeNotifierProvider<CartProvider>(create: (_) => cartProvider),
  ChangeNotifierProvider<PosStatusProvider>(create: (_) => posStatusProvider),
  ChangeNotifierProvider<LoginProvider>(
    create: (_) => LoginProvider(),
    lazy: true,
  ),
  ChangeNotifierProxyProvider<RevenueSourceProvider, RevenueCollectionProvider>(
      create: (_) => RevenueCollectionProvider(_.read<PosStatusProvider>()),
      update: (_, revProvider, dashProvider) =>
          dashProvider!..update(revProvider)),
  ChangeNotifierProxyProvider<AppStateProvider, GenerateBillProvider>(
      create: (_) => GenerateBillProvider(),
      update: (_, userProvider, generateBillProvider) =>
          generateBillProvider!..update(userProvider.user?.taxCollectorUuid))
];
