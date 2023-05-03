import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/pos_registration.dart';
import 'package:zanmutm_pos_client/src/utils/app_const.dart';

class PosRegistrationProvider extends ChangeNotifier with MessageNotifierMixin {
  PosRegistration? _posRegistration;
  bool _isLoading = false;
  bool registrationLoaded = false;

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  set posRegistration(PosRegistration? value) {
    _posRegistration = value;
    notifyListeners();
  }

  PosRegistration? get posRegistration => _posRegistration;

  loadRegistration() async {
    registrationLoaded = false;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? reg = prefs.getString(AppConst.registration);
      if (reg != null) {
        posRegistration = PosRegistration.fromJson(jsonDecode(reg));
      }
    } catch (e) {
      posRegistration = null;
      notifyError(e.toString());
    } finally {
    registrationLoaded = true;
    }
  }

  Future<PosRegistration?> fetchRegistration(imei) async {
    isLoading = true;
    try {
      var resp = await Api().dio.get("/pos-devices/by-imei/$imei");
      if (resp.data != null && resp.data['data'] != null) {
        return PosRegistration.fromJson(resp.data['data']);
      }
      return null;
    } catch (e) {
      notifyError(e.toString());
      return null;
    } finally {
      isLoading = false;
    }
  }

  Future<void> register(PosRegistration reg) async {
    isLoading = true;
    try {
      await Api().dio.post("/pos-devices/confirm-registration/${reg.imei}");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConst.registration, jsonEncode(reg.toJson()));
      posRegistration = reg;
    } catch (e) {
      posRegistration = null;
      notifyError(e.toString());
    } finally {
      isLoading = false;
    }
  }
}
