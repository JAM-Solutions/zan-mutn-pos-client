import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/apps/auth/user.dart';

class AuthProvider with ChangeNotifier {
  bool isAuthenticated = false;
  bool sessionHasBeenFetched = false;
  bool isLoading = false;
  User? user;
  String? errorMessage;

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

  void onUnAuthorized() {
    isAuthenticated = false;
    notifyListeners();
  }

  void login(dynamic logins, Function onError) async {
    try {
      // TODO login
      isAuthenticated = true;
      sessionHasBeenFetched = true;
      notifyListeners();
    } catch (e) {
      onError(e.toString());
      debugPrint(e.toString());
    }
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isAuthenticated = false;
    sessionHasBeenFetched = true;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    errorMessage = message;
    notifyListeners();
  }
}

final authProvider = AuthProvider();
