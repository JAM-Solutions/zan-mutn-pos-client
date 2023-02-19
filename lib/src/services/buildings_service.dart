import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/models/building.dart';
import 'package:zanmutm_pos_client/src/models/household.dart';

class BuildingsService {
  final String api = '/solid-waste-buildings';
  final String _api = '/solid-waste-households';
  Future<Building?> gethousenumber(String houseNumber) async {
    var resp = await Api().dio.get('$api/by-house-number/$houseNumber');
    var houseHold = resp.data['data'];

    return houseHold != null ? Building.fromJson(houseHold) : null;
  }

  Future<List<Households>> households(String houseNumber, int id) async {
    var resp = await Api().dio.get('$api/by-house-number/$houseNumber');
    List<dynamic> houseHoldDetails = resp.data['data']['households'];
    debugPrint(houseHoldDetails.toString());
    return houseHoldDetails != null ? houseHoldDetails.map((e) => Households.fromJson(e)).toList()  : [];
  }

  Future registerHouse(payload) async {
    var response = await Api().dio.post('$api', data: payload);
  }

  Future registerHousehold(payload) async {
    debugPrint(payload.toString());
    var response = await Api().dio.post('$_api', data: payload);
  }
}
