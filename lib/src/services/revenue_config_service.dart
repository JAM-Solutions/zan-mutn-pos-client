import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/config/app_exceptions.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source_config.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class RevenueSourceService {
  final String tableName = 'revenue_sources';
  final String resource = '/revenue-sources';

  Future<List<RevenueSource>> fetchAndStore(String taxCollectorUuid) async {
    List<RevenueSource> sources = List.empty(growable: true);
    try {
      var resp = await Api().dio.get("$resource/by-collector/$taxCollectorUuid");
      if (resp.data != null && resp.data['data'] != null) {
        sources = (resp.data['data'] as List<dynamic>)
            .map((e) => RevenueSource.fromJson(e))
            .toList();
        // Store to db
        await storeToDb(sources);
        return sources;
      }
    } on NoInternetConnectionException {
      sources = await queryFromDb(taxCollectorUuid);
      return sources;
    } catch (e) {
      debugPrint(e.toString());
      throw ValidationException(e.toString());
    }
    return sources;
  }

  /// Get Pos config from local db
  Future<List<RevenueSource>> queryFromDb(String taxCollectorUuid) async {
    try {
      var db = await DbProvider().database;
      var result =
          await db.query(tableName, where: 'taxCollectorUuid=?', whereArgs: [taxCollectorUuid]);
      return result.map((e) => RevenueSource.fromJson(e)).toList();
    } catch (e) {
      throw ValidationException(e.toString());
    }
  }

  ///Save pos config to database
  Future<void> storeToDb(List<RevenueSource> sources) async {
    try {
      var db = await DbProvider().database;
      await db.delete(tableName);
      for (var source in sources) {
        var data = {
          ...source.toJson(),
          'isMiscellaneous': source.isMiscellaneous ? 1 : 0,
          'isActive': source.isActive ? 1 : 0,
          'penalty': source.penalty == true ? 1 : 0,
          'lastUpdate': dateFormat.format(DateTime.now())
        };
        db.insert(tableName, data);
      }
    } catch (e) {
      throw ValidationException(e.toString());
    }
  }

  Future<RevenueSourceConfig?> getRevenueSource(
      int revenueSourceId,
      int adminHierarchyId,
      int financialYearId) async {
    var resp = await Api().dio.get(
        "/revenue-source-configurations/current/$revenueSourceId/$adminHierarchyId/$financialYearId");
    if (resp.data != null && resp.data['data'] != null) {
      return RevenueSourceConfig.formJson(resp.data['data']);
    } else {
      return null;
    }
  }
}
