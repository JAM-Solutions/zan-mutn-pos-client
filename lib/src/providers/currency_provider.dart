import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/currency.dart';
import 'package:zanmutm_pos_client/src/services/currency_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';

class CurrencyProvider extends ChangeNotifier with MessageNotifierMixin {
  final currencyService = getIt<CurrencyService>();
  List<Currency> _currencies = List.empty(growable: true);
  Currency? _defaultCurrency;
  bool _isLoading = false;

  List<Currency> get currencies => _currencies;

  set currencies(List<Currency> val) {
    _currencies = val;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Currency? get defaultCurrency => _defaultCurrency;

  set defaultCurrency(Currency? val) {
    _defaultCurrency = val;
    notifyListeners();
  }

  loadCurrencies() async {
    try {
      _currencies = await currencyService.queryFromDb();
      _defaultCurrency = currencies
          .cast<Currency?>()
          .firstWhere((c) => c?.isDefault == true, orElse: () => null);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      notifyError(e.toString());
    }
  }

  fetchCurrencies() async {
    try {
      _currencies = await currencyService.fetchAndStore();
      _defaultCurrency = currencies
          .cast<Currency?>()
          .firstWhere((c) => c?.isDefault == true, orElse: () => null);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      notifyError(e.toString());
    }
  }

  setDefault(Currency currency) async {
    currency.isDefault = true;
    await currencyService.saveDefault(currency);
    loadCurrencies();
  }
}
