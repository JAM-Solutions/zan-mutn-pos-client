import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/config/app_exceptions.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class FinancialYearService {

  final String dbName = 'financial_years';

  Future<FinancialYear?> fetchAndStore() async {
    try {
      var resp = await Api().dio.get("/financial-years/current");
      if (resp.data != null && resp.data['data'] != null) {
        FinancialYear year = FinancialYear.fromJson(resp.data['data']);
        await storeToDb(year);
        return year;
      }
    } on NoInternetConnectionException {
      return (await queryFromDb());
    } on DeadlineExceededException {
      return (await queryFromDb());
    } catch (e) {
      debugPrint(e.toString());
      throw ValidationException(e.toString());
    }
    return null;
  }

  /// Get Pos config from local db
  Future<FinancialYear?> queryFromDb() async {
    var db = await DbProvider().database;
    var result = await db.query(dbName,
        where: 'isCurrent=?', whereArgs: [1], limit: 1);
    if (result.isNotEmpty) {
      var data = result.single;
      FinancialYear year = FinancialYear.fromJson({
          ...data,
        'isCurrent': data['isCurrent'] == 1
      });
      return year;
    } else {
      return null;
    }
  }

  ///Save pos config to database
  Future<int> storeToDb(FinancialYear year) async {
    var db = await DbProvider().database;
    var existing = await db.query(dbName,
        where: 'isCurrent=?', whereArgs: [1], limit: 1);
    var data = {
      ...year.toJson(),
      'isCurrent': year.isCurrent ? 1 : 0,
      'lastUpdate': dateFormat.format(DateTime.now())
    };
    var result = await (existing.isNotEmpty
        ? db.update(dbName, data)
        : db.insert(dbName, data));
    return result;
  }
}

//final financialYearService = FinancialYearService();
