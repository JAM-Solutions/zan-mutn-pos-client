import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class PosConfigurationService {

  final String tableName = 'pos_configurations';

  /// Get Pos config from local db
  Future<PosConfiguration?> queryFromDb(String taxCollectorUuid) async {
    var db = await DbProvider().database;
    var result = await db.query(tableName,
        where: 'taxCollectorUuid=?', whereArgs: [taxCollectorUuid], limit: 1);
    if (result.isNotEmpty) {
      PosConfiguration posConfiguration =
          PosConfiguration.fromJson(result.single);
      return posConfiguration;
    } else {
      return null;
    }
  }

  /// Fetch config from api
  /// Store to database
  /// Update State
  Future<PosConfiguration?> fetchAndStore(String taxCollectorUuid) async {
    try {
      var resp = await Api()
          .dio
          .get("/tax-collectors/$taxCollectorUuid/active-configurations");
      if (resp.data != null && resp.data['data'] != null) {
        PosConfiguration config = PosConfiguration.fromJson({
          ...resp.data['data'],
          'lastUpdate': dateFormat.format(DateTime.now())
        });
        await storeToDb(config);
        return config;
      } else {
        return null;
      }
    } on NoInternetConnectionException {
      var fromDb = await queryFromDb(taxCollectorUuid);
      return fromDb;
    } on DeadlineExceededException {
      var fromDb = await queryFromDb(taxCollectorUuid);
      return fromDb;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  ///Save pos config to database
  Future<int> storeToDb(PosConfiguration config) async {
    var db = await DbProvider().database;
    var data = config.toJson();
    var existing = await db.query(tableName,
        where: 'taxCollectorUuid=?',
        whereArgs: [config.taxCollectorUuid],
        limit: 1);
    var result = await (existing.isNotEmpty
        ? db.update(tableName, data, where: "id=?", whereArgs: [existing.single['id']])
        : db.insert(tableName, data));
    return result;
  }
}

//final posConfigService = ConfigService();
