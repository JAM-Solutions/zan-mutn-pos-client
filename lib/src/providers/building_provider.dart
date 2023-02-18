import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/models/building.dart';
import 'package:zanmutm_pos_client/src/models/household.dart';
import 'package:zanmutm_pos_client/src/services/buildings_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';

class BuildingProvider extends ChangeNotifier with MessageNotifierMixin {
  bool register = false;
  bool view = false;
  bool fyIsLoading = false;
  List<Households> _houseHolds = [];
  Building? _building;
  

  set building(Building? val) {
    _building = val;
    notifyListeners();
  }

  set houseHolds(List<Households> val) {
    _houseHolds = val;
  }

  List<Households> get houseHolds => _houseHolds;

  Building? get building => _building;

  fetchbuildings(houseNumber) async {
    fyIsLoading = true;
    try {
      _building = (await getIt<BuildingsService>().gethousenumber(houseNumber));
      fyIsLoading = false;
      if (_building != null) {
        register = false;
        view = true;
      } else {
        register = true;
        view = false;
      }
      notifyListeners();
    } catch (e) {
      fyIsLoading = false;
      notifyListeners();
      notifyError(e.toString());
    }
  }

  registerHouse(payload, houseNumber) async {
    fyIsLoading = true;
    try {
      await getIt<BuildingsService>().registerHouse(payload);
      fyIsLoading = false;
      fetchbuildings(houseNumber);
      notifyListeners();
    } catch (e) {
      fyIsLoading = false;
      notifyListeners();
      notifyError(e.toString());
    }
  }

  registerHousehold(payload) async {
    fyIsLoading = true;
    try {
      await getIt<BuildingsService>().registerHousehold(payload);
      fyIsLoading = false;
      notifyListeners();
    } catch (e) {
      fyIsLoading = false;
      notifyListeners();
      notifyError(e.toString());
    }
  }

  fetchHouseholds(houseNumber, id) async {
    fyIsLoading = true;
    try {
      _houseHolds =
          (await getIt<BuildingsService>().households(houseNumber, id));
      fyIsLoading = false;
      notifyListeners();
    } catch (e) {
      fyIsLoading = false;
      notifyListeners();
      notifyError(e.toString());
    }
  }
}
