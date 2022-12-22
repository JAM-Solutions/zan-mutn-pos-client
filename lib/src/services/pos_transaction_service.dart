import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/config/app_exceptions.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';

class PosTransactionService {
  static final PosTransactionService _instance = PosTransactionService._();
  factory PosTransactionService() => _instance;
  PosTransactionService._();

  final String dbName = 'pos_transactions';
  final String api = '/pos-transactions';

  Future<int> save(PosTransaction txn) async {
    try {
      var resp = await Api().dio.post(api, data: txn.toJson());
     return resp.statusCode ?? 400;
    } on NoInternetConnectionException   {
       int dbResp = await storeToDb(txn);
       return dbResp == 1 ? 200: 400;
    } on DeadlineExceededException {
      int dbResp = await storeToDb(txn);
      return dbResp == 1 ? 200: 400;
    }
    catch (e) {
       debugPrint(e.toString());
       throw ValidationException(e.toString());
    }
  }

  Future<int> storeToDb(PosTransaction txn) async {
    var db = await DbProvider().database;
    var data = {
      ...txn.toJson(),
      'isPrinted': txn.isPrinted ? 1 : 0,
    };
    var result = await db.insert(dbName, data);
    debugPrint(result.toString());

    return result;
  }
}

final posTransactionService= PosTransactionService();
