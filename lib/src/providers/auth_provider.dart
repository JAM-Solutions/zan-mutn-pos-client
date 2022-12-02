import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/screens/auth/user.dart';

class AuthProvider with ChangeNotifier {
  bool isAuthenticated = false;
  bool sessionHasBeenFetched = false;
  User? user;

  void getSession() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("TODO");
      final String? userString = prefs.getString("TODO");
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

  void userUnAuthorized() {
    isAuthenticated = false;
    notifyListeners();
  }

  void userAuthorized() {
    isAuthenticated = true;
    sessionHasBeenFetched = true;
    notifyListeners();
  }

  void userLoggedOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isAuthenticated = false;
    sessionHasBeenFetched = true;
    notifyListeners();
  }
}

final authProvider = AuthProvider();
