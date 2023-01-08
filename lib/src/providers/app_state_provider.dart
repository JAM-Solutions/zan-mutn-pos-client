import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';

class AppStateProvider with ChangeNotifier {
  bool isAuthenticated = false;
  bool sessionHasBeenFetched = false;
  bool configurationHasBeenLoaded = false;
  User? user;

  static final AppStateProvider _instance = AppStateProvider._();
  factory AppStateProvider() => _instance;
  AppStateProvider._();

  void sessionFetched(User? sessionUser)  {
    user = sessionUser;
    isAuthenticated = sessionUser != null;
      sessionHasBeenFetched = true;
      notifyListeners();
  }

  void setAuthenticated(User loggedInUser)  {
    isAuthenticated = true;
    sessionHasBeenFetched = true;
    user = loggedInUser;
    notifyListeners();
  }

  void userLoggedOut() async {
    isAuthenticated = false;
    sessionHasBeenFetched = true;
    notifyListeners();
  }

  void setConfigLoaded() {
    configurationHasBeenLoaded = true;
    notifyListeners();
  }

}

final appStateProvider = AppStateProvider();
