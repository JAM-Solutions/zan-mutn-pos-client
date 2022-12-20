import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/config/app_exceptions.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._();

  factory ConfigService() => _instance;

  final String dbName = 'pos_configurations';

  ConfigService._();

  /// Get Pos config from local db
  Future<void> queryFromDb(String posDeviceNumber) async {
    var db = await DbProvider().database;
    var result = await db.query(dbName,
        where: 'posDeviceNumber=?', whereArgs: [posDeviceNumber], limit: 1);
    if (result.isNotEmpty) {
      PosConfiguration posConfiguration =
          PosConfiguration.fromJson(result.single);
      appStateProvider.setPosConfig(posConfiguration);
    } else {
      appStateProvider.setPosConfig(null);
    }
  }

  /// Fetch config from api
  /// Store to database
  /// Update State
  Future<void> fetchFromApi(String posDeviceNumber) async {
    var resp = await Api()
        .dio
        .get("/pos-configurations/$posDeviceNumber/configurations");
    if (resp.data != null && resp.data['data'] != null) {
      PosConfiguration config = PosConfiguration.fromJson({
        ...resp.data['data'],
        'posDeviceNumber': posDeviceNumber,
        'lastUpdate': dateFormat.format(DateTime.now())
      });
      await storeToDb(config,
          update: appStateProvider.posConfiguration != null);
      await appStateProvider.setPosConfig(config);
    } else {
      throw ValidationException("No POS config found for this POS");
    }
  }

  ///Save pos config to database
  Future<int> storeToDb(PosConfiguration config,
      {bool update = false}) async {
    var db = await DbProvider().database;
    var data = config.toJson();
    var result =
        await (update ? db.update(dbName, data) : db.insert(dbName, data));
    return result;
  }
}

final configService = ConfigService();
