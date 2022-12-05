import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/screens/auth/user.dart';
import 'package:zanmutm_pos_client/src/utils/app_const.dart';

class AuthProvider with ChangeNotifier {
  bool isAuthenticated = false;
  bool sessionHasBeenFetched = false;
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
      sessionHasBeenFetched = true;
      notifyListeners();
    } catch (e) {
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
