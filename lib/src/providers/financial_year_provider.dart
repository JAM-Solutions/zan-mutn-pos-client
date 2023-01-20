import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/services/financial_year_service.dart';

class FinancialYearProvider extends ChangeNotifier with MessageNotifierMixin {
  bool _fyIsLoading = false;
  FinancialYear? _financialYear;

  bool get fyIsLoading => _fyIsLoading;
  set fyIsLoading(bool val) {
    _fyIsLoading = val;
    notifyListeners();
  }

  FinancialYear? get financialYear=> _financialYear;
  set financialYear(FinancialYear? val) {
    _financialYear = val;
    notifyListeners();
  }

  loadFinancialYear() async {
    fyIsLoading = true;
    try {
      financialYear = await  financialYearService.fetchAndStore();
      fyIsLoading = false;
    } catch(e) {
      fyIsLoading = false;
    //  notifyError(e.toString());
    }
  }

}
