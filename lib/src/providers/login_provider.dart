import 'package:flutter/cupertino.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/services/auth_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';

class LoginProvider extends ChangeNotifier with MessageNotifierMixin {
  bool _isLoading = false;
  var _numberLogs = 0;
  bool _showPassword = false;
  final loginService = getIt<AuthService>();

  bool get showPassword => _showPassword;

  set showPassword(bool val) {
    _showPassword = val;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  get numberLogs => _numberLogs;

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set numberLogs(var val) {
    _numberLogs = val;
    notifyListeners();
  }

  Future addLogs() async {
    numberLogs = 4;
    debugPrint(numberLogs.toString());
  }

  Future<User?> login(Map<String, dynamic> payload) async {
    isLoading = true;
    try {
      User user = await loginService.login(payload);
      isLoading = false;
      return user;
    } catch (e) {
      debugPrint(e.toString());
      isLoading = false;
      numberLogs = numberLogs + 1;
      debugPrint(numberLogs.toString());
      notifyError(e.toString());
      return null;
    }
  }
}
