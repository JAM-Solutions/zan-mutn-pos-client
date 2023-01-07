import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/models/pos_charge.dart';

class PosChargeService {
  static final PosChargeService _instance = PosChargeService._();
  factory PosChargeService() => _instance;
  PosChargeService._();

  final String api = '/pos-charges';

  Future<List<PosCharge>> getPendingCharges(String taxCollectorUuid) async {
    var resp = await Api().dio.get('$api/$taxCollectorUuid');
    return (resp.data['data'] as List<dynamic>)
        .map((e) => PosCharge.fromJson(e))
        .toList();
  }

  Future<void> createBill(String chargeUuid) async {
     await Api().dio.post('$api/create-bill/$chargeUuid');
  }
}

final posChargeService = PosChargeService();
