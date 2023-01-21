import 'package:flutter/cupertino.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/config/app_exceptions.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._();

  factory ConfigService() => _instance;
  final String tableName = 'pos_configurations';

  ConfigService._();

  /// Get Pos config from local db
  Future<PosConfiguration?> queryFromDb(String posDeviceNumber) async {
    var db = await DbProvider().database;
    var result = await db.query(tableName,
        where: 'posDeviceNumber=?', whereArgs: [posDeviceNumber], limit: 1);
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
  Future<PosConfiguration?> fetchAndStore(String posDeviceNumber) async {
    try {
      var resp = await Api()
          .dio
          .get("/pos-configurations/$posDeviceNumber/configurations");
      if (resp.data != null && resp.data['data'] != null) {
        PosConfiguration config = PosConfiguration.fromJson({
          ...resp.data['data'],
          'posDeviceNumber': posDeviceNumber,
          'lastUpdate': dateFormat.format(DateTime.now())
        });
        await storeToDb(config);
        return config;
      } else {
        return null;
      }
    } on NoInternetConnectionException {
      var fromDb = await queryFromDb(posDeviceNumber);
      return fromDb;
    } on DeadlineExceededException {
      var fromDb = await queryFromDb(posDeviceNumber);
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
        where: 'posDeviceNumber=?',
        whereArgs: [config.posDeviceNumber],
        limit: 1);
    var result = await (existing.isNotEmpty
        ? db.update(tableName, data)
        : db.insert(tableName, data));
    return result;
  }
}

final posConfigService = ConfigService();
