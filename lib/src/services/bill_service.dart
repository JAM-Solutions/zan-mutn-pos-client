import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/models/bill.dart';

class BillService {

  final String api = '/bills';

  Future<List<Bill>> getPendingBills(String taxPayerUuid) async {
    var resp = await Api().dio.get('$api/pending/$taxPayerUuid');
    return (resp.data['data'] as List<dynamic>)
        .map((e) => Bill.fromJson(e))
        .toList();
  }

}
