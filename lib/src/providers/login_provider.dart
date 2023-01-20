import 'package:flutter/cupertino.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/services/auth_service.dart';

class LoginProvider extends ChangeNotifier with MessageNotifierMixin {
  bool _isLoading = false;
  bool _showPassword = false;

  bool get showPassword => _showPassword;

  set showPassword(bool val) {
    _showPassword = val;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<User?> login(Map<String, dynamic> payload) async {
    isLoading = true;
    try {
      User user = await authService.login(payload);
      isLoading = false;
      return user;
    } catch (e) {
      debugPrint(e.toString());
      isLoading = false;
      notifyError(e.toString());
      return null;
    }
  }
}
