import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/config/app_exceptions.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/currency.dart';

class CurrencyService {
  final String api = '/currencies';
  final String tableName = 'currencies';

  Future<List<Currency>> fetchAndStore() async {
    try {
      var resp = await Api().dio.get(api);
      var currencies = (resp.data['data'] as List<dynamic>)
          .map((e) => Currency.fromJson({...e, 'isDefault': false}))
          .toList();
      storeToDb(currencies);
      return currencies;
    } on NoInternetConnectionException{
      return queryFromDb();
    } catch (e) {
      debugPrint(e.toString());
      throw ValidationException(e.toString());
    }
  }

  Future<List<Currency>> queryFromDb() async {
    var db = await DbProvider().database;
    var result = await db.query(tableName);
    return result
        .map((e) => Currency.fromJson({...e, 'isDefault': e['isDefault'] == 1}))
        .toList();
  }

  Future<void> storeToDb(List<Currency> currencies) async {
    try {
      var db = await DbProvider().database;
      await db.delete(tableName);
      for (var value in currencies) {
        var data = {...value.toJson(), 'isDefault': value.isDefault == true ? 1 : 0};
        db.insert(tableName, data);
      }
    } catch (e) {
      debugPrint(e.toString());
      throw DatabaseException(e.toString());
    }
  }

  saveDefault(Currency currency) async {
    var db = await DbProvider().database;
    var data = {...currency.toJson(), 'isDefault': currency.isDefault == true ? 1 : 0};
    db.execute("UPDATE $tableName SET isDefault=0");
    db.update(tableName, data, where: "id=?", whereArgs: [currency.id]);
  }
}
