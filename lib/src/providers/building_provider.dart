import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/models/building.dart';
import 'package:zanmutm_pos_client/src/services/buildings_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';

class BuildingProvider extends ChangeNotifier {
  bool _fyIsLoading = false;
  Building? _building;
  List<Building> _buildings = List.empty(growable: true);
  final buildingsService = getIt<BuildingsService>();

  List<Building> get buildings => _buildings;

  set buildings(List<Building> val) {
    _buildings = val;
    notifyListeners();
  }
  bool get fyIsLoading => _fyIsLoading;
  set fyIsLoading(bool val) {
    _fyIsLoading = val;
    notifyListeners();
  }
set building(Building? val) {
    _building = val;
    notifyListeners();
  }



  fetchbuildings(houseNumber) async {
    fyIsLoading = true;
    try {
      building = await  buildingsService.gethousenumber(houseNumber);
      fyIsLoading = false;
      notifyListeners();
    } catch(e) {
      fyIsLoading = false;
    }
  }

}
