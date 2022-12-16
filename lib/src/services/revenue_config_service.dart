import 'package:zanmutm_pos_client/src/api/api.dart';

class RevenueConfigService {
  static final RevenueConfigService _instance = RevenueConfigService._();
  factory RevenueConfigService() => _instance;
  RevenueConfigService._();

  Future<void> fetchFinancialYear() {
    return Api().dio.get("/financial-years/current");
  }

  Future<void> fetchRevenueSource() {
    return Api().dio.get("/revenue-sources");
  }
}

final revenueConfigService = RevenueConfigService();
