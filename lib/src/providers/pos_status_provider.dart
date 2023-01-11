
import 'package:flutter/material.dart';

class PosStatusProvider with ChangeNotifier {

  DateTime? lastOffline;
  int offlineTime = 0;

  loadStatus() {

  }

  setOfflineTime() {
    var now_ = DateTime.now();
    if(lastOffline == null) {
      lastOffline = now_;
      offlineTime = 0;
    } else {
      Duration diff = now_.difference(lastOffline!);
      offlineTime = offlineTime + diff.inSeconds;
      lastOffline = now_;
    }
    notifyListeners();
  }

  resetOfflineTime() {
    lastOffline = null;
    offlineTime = 0;
    notifyListeners();
  }
}

final posStatusProvider = PosStatusProvider();
