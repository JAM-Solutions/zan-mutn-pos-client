
import 'package:dio/dio.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';

Future<Response<dynamic>> fetchPosConfig(int posDeviceId) {
  return Api().dio.get("pos-devices/$posDeviceId/configurations");
}

Future<Response<dynamic>> fetchFinancialYear() {
  return Api().dio.get("financial-years/current");
}

Future<Response<dynamic>> fetchRevenueSource() {
  return Api().dio.get("revenue-sources");
}