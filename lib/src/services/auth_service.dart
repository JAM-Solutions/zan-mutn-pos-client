import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/config/app_exceptions.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/utils/app_const.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final String authenticationApi= "/authenticate";

  //Login user from api
  Future<void> login(Map<String, dynamic> payload) async {
    var resp = await Api().dio.post(authenticationApi,data: payload);
    User user = User.fromJson(resp.data['User']);
    if (user.adminHierarchyId == null) {
      throw ValidationException("User has no admin areas");
    }
    String token = resp.data['access_token'];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConst.userKey, jsonEncode(user.toJson()));
    await prefs.setString(AppConst.tokenKey, token);
    await appStateProvider.setAuthenticated(user);
  }

  //Get user session if exist localy
  Future<void> getSession() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString(AppConst.tokenKey);
      final String? userString = prefs.getString(AppConst.userKey);
      User? user;
      if (token != null && userString != null) {
        user = User.fromJson(jsonDecode(userString));
      }
      appStateProvider.sessionFetched(user);
    } catch (e) {
      appStateProvider.sessionFetched(null);
      debugPrint(e.toString());
    }
  }



}
final authService = AuthService();