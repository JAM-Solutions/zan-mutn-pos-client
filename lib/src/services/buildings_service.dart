import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/models/buildings.dart';

class BuildingsService {
  final String api = '/solid-waste-buildings';
  final String tableName = 'solid_waste_buildings';
  Future<List<Buildings>> gethousenumber(String houseNumber) async {
    var resp = await Api().dio.get('$api/get-house-number/$houseNumber');
    return (resp.data['data'] as List<dynamic>)
        ?.map((e) => Buildings.fromJson(e))
        ?.toList() ?? [];
  }

}
