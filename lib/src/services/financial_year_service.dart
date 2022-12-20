import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/config/app_exceptions.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class FinancialYearService {
  static final FinancialYearService _instance = FinancialYearService._();

  factory FinancialYearService() => _instance;

  FinancialYearService._();

  final String dbName = 'financial_years';

  Future<void> fetchFromApi() async {
    try {
      var resp = await Api().dio.get("/financial-years/current");
      if (resp.data != null && resp.data['data'] != null) {
        FinancialYear year = FinancialYear.fromJson(resp.data['data']);
        await storeToDb(year);
      }
    } on NoInternetConnectionException {
      await queryFromDb();
    } catch (e) {
      debugPrint(e.toString());
      throw ValidationException(e.toString());
    }
  }

  /// Get Pos config from local db
  Future<void> queryFromDb() async {
    var db = await DbProvider().database;
    var result = await db.query(dbName,
        where: 'isCurrent=?', whereArgs: [1], limit: 1);
    if (result.isNotEmpty) {
      FinancialYear year = FinancialYear.fromJson(result.single);
       appStateProvider.setFinancialYear(year);
    } else {
      appStateProvider.setFinancialYear(null);
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
     appStateProvider.setFinancialYear(year);
    return result;
  }
}

final financialYearService = FinancialYearService();
