import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/screens/auth/user.dart';
import 'package:zanmutm_pos_client/src/utils/app_const.dart';

class AuthProvider with ChangeNotifier {
  bool isAuthenticated = false;
  bool sessionHasBeenFetched = false;
  bool configurationHasBeenLoaded = false;
  PosConfiguration? posConfiguration;

  User? user;

  void getSession() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString(AppConst.tokenKey);
      final String? userString = prefs.getString(AppConst.userKey);
      if (token != null && userString != null) {
        user = User.fromJson(jsonDecode(userString));
        isAuthenticated = true;
      }
      await getConfiguration();
      sessionHasBeenFetched = true;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getConfiguration() async {
    try {
      int posId=1;
      var db = await DbProvider().database;
      var result = await db.query('pos_configurations',where: 'id=?',whereArgs: [posId], limit: 1);
      debugPrint(result.toString());
      debugPrint((result.isNotEmpty).toString());
      debugPrint(result.single.toString());
      if(result.isNotEmpty) {
        posConfiguration = PosConfiguration.fromJson(result.single);
      }
      configurationHasBeenLoaded = true;
      notifyListeners();
    } catch(e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateConfiguration(Map<String, dynamic> payload) async {
    var db = await DbProvider().database;
    try {
      var  data = {
        'id': payload['id'],
        'uuid': payload['uuid'],
        'offlineLimit': payload['offlineLimit'],
        'amountLimit': payload['amountLimit'],
        'posDeviceId': payload['posDeviceId'],
        'posDeviceName': payload['posDeviceName'],
      };
      var result = await ( posConfiguration == null
          ? db.insert('pos_configurations', data)
          : db.update('pos_configurations', data));
      if (result == 1) {
        posConfiguration = PosConfiguration.fromJson(payload);
        notifyListeners();
      }
    } catch(e) {
      debugPrint(e.toString());
    }
  }

  void userUnAuthorized()  {
    isAuthenticated = false;
    notifyListeners();
  }

  void userAuthorized(Map<String, dynamic> credentials) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConst.userKey, jsonEncode(credentials['User']));
    await prefs.setString(AppConst.tokenKey, credentials['access_token']);
    isAuthenticated = true;
    sessionHasBeenFetched = true;
    notifyListeners();
  }

  void userLoggedOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConst.userKey);
    await prefs.remove(AppConst.tokenKey);
    isAuthenticated = false;
    sessionHasBeenFetched = true;
    notifyListeners();
  }
}

final authProvider = AuthProvider();
