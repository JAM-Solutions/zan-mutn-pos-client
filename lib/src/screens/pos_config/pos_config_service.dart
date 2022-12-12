
import 'package:dio/dio.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';

const String resource= "/pos-devices";

Future<Response<dynamic>> fetchPosConfig(int posDeviceId) {
  return Api().dio.get("$resource/$posDeviceId/configurations");
}