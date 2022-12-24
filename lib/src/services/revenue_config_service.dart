import 'package:flutter/cupertino.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/config/app_exceptions.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class RevenueConfigService {
  static final RevenueConfigService _instance = RevenueConfigService._();

  factory RevenueConfigService() => _instance;

  RevenueConfigService._();

  final String tableName = 'revenue_sources';
  final String resource = '/revenue-sources';

  Future<List<RevenueSource>> fetchAndStore() async {
    List<RevenueSource> sources = List.empty(growable: true);
    try {
      var resp = await Api().dio.get("$resource/by-collector");
      if (resp.data != null && resp.data['data'] != null) {
        sources = (resp.data['data'] as List<dynamic>)
            .map((e) => RevenueSource.fromJson(e))
            .toList();
        // Store to db
        await storeToDb(sources);
        return sources;
      }
    } on NoInternetConnectionException {
      sources = await queryFromDb();
      return sources;
    } catch (e) {
      debugPrint(e.toString());
      throw ValidationException(e.toString());
    }
    return sources;
  }

  /// Get Pos config from local db
  Future<List<RevenueSource>> queryFromDb() async {
    try {
      var db = await DbProvider().database;
      var result =
          await db.query(tableName, where: 'isActive=?', whereArgs: [1]);
      return result.map((e) => RevenueSource.fromJson(e)).toList();
    } catch (e) {
      throw ValidationException(e.toString());
    }
  }

  ///Save pos config to database
  Future<void> storeToDb(List<RevenueSource> sources) async {
    try {
      var db = await DbProvider().database;
      for (var source in sources) {
        var existing = await db.query(tableName,
            where: 'gfsCode=?', whereArgs: [source.gfsCode], limit: 1);
        var data = {
          ...source.toJson(),
          'isMiscellaneous': source.isMiscellaneous ? 1 : 0,
          'isActive': source.isActive ? 1 : 0,
          'lastUpdate': dateFormat.format(DateTime.now())
        };
        await (existing.isNotEmpty
            ? db.update(tableName, data)
            : db.insert(tableName, data));
      }
    } catch (e) {
      throw ValidationException(e.toString());
    }
  }
}

final revenueConfigService = RevenueConfigService();
