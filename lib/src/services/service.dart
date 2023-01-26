import 'package:get_it/get_it.dart';
import 'package:zanmutm_pos_client/src/services/auth_service.dart';
import 'package:zanmutm_pos_client/src/services/bill_service.dart';
import 'package:zanmutm_pos_client/src/services/currency_service.dart';
import 'package:zanmutm_pos_client/src/services/device_info_service.dart';
import 'package:zanmutm_pos_client/src/services/financial_year_service.dart';
import 'package:zanmutm_pos_client/src/services/buildings_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_charge_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_configuration_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/services/revenue_config_service.dart';

final getIt = GetIt.instance;

void registerServices() {
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<DeviceInfoService>(DeviceInfoService());
  getIt.registerSingleton<FinancialYearService>(FinancialYearService());
  getIt.registerSingleton<PosConfigurationService>(PosConfigurationService());
  getIt.registerLazySingleton<BillService>(() => BillService());
  getIt.registerLazySingleton<PosChargeService>(() => PosChargeService());
  getIt.registerLazySingleton<PosTransactionService>(
      () => PosTransactionService());
  getIt.registerLazySingleton<RevenueSourceService>(
      () => RevenueSourceService());
  getIt.registerLazySingleton<CurrencyService>(() => CurrencyService());
  getIt.registerLazySingleton<BuildingsService>(() => BuildingsService());
}
