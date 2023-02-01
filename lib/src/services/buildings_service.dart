import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/models/buildings.dart';

class BuildingsService {
  final String api = '/solid-waste-buildings';
  final String tableName = 'solid_waste_buildings';
  Future<Buildings?> gethousenumber(String houseNumber) async {
    var resp = await Api().dio.get('$api/get-house-number/$houseNumber');
    var houseHold = resp.data['data'];

    return houseHold != null ? Buildings.fromJson(houseHold) : null;
  }

  Future registerHouse(payload) async {
    var response = await Api().dio.post('$api', 
    data: payload);
  }
}
