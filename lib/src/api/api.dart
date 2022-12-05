import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/providers/auth_provider.dart';
import 'package:zanmutm_pos_client/src/utils/app_const.dart';

class Api {
  final dio = createDio();
  Api._internal();

  static final _singleton = Api._internal();

  factory Api() => _singleton;

  static Dio createDio() {
    var dio = Dio(BaseOptions(
        baseUrl: dotenv.env['API_SERVER'] ?? 'http://noapi',
        connectTimeout: int.parse(dotenv.env['API_CONNECTION_TIMEOUT'] ?? '10000'),
        receiveTimeout: int.parse(dotenv.env['API_RECEIVE_TIMEOUT'] ?? '15000'),
        sendTimeout: int.parse(dotenv.env['API_SEND_TIMEOUT'] ?? '10000')));
    dio.interceptors.add(AppInterceptor());
    return dio;
  }
}

class AppInterceptor extends Interceptor {
  AppInterceptor();
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  String clientAuth = base64.encode(
      utf8.encode("${dotenv.env['0AUTH_CLIENT_ID']}:${dotenv.env['0AUTH_CLIENT_SECRET']}"));

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString(AppConst.tokenKey);

    if (accessToken != null && !options.path.contains("/authenticate")) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      options.headers['Content-Type'] = 'application/json';

    }
    if (options.path.contains("/authenticate")) {
      options.headers['Authorization'] = 'Basic $clientAuth';
      options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    }
    debugPrint(
        "Api request: [${options.method}] [${options.baseUrl}${options.path}]");
    debugPrint(
        "Request Headers ${options.headers.toString()}");
    if (['PUT','POST','PATCH'].contains(options.method)) {
      debugPrint(
          "Payload:  ${options.data.toString() ?? ''}");
    }
    debugPrint("---------------------------------------------------");
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint("Api response: [${response.statusCode}]");
   // debugPrint("Payload: [${response.data?.toString() ?? ''}]");
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    debugPrint("Api response code: [${err.response?.statusCode}]");
    debugPrint("response data: [${err.response?.data}]");
    switch (err.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        throw DeadlineExceededException(err.requestOptions);
      case DioErrorType.response:
        // debugPrint(err.response?.data);

        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException(
                err.requestOptions,
                err.response?.data['message'] ??
                    err.response?.data['errors'] ??
                    err.response?.data['error_description'] ??
                    'Bad request');
          case 401:
            authProvider.userUnAuthorized();
            throw UnauthorizedException(err.requestOptions);
          case 403:
            throw PermissionDenied(err.requestOptions);
          case 404:
            throw NotFoundException(err.requestOptions);
          case 409:
            throw ConflictException(err.requestOptions);
          case 500:
            throw InternalServerErrorException(err.requestOptions);
        }
        break;
      case DioErrorType.cancel:
        break;
      case DioErrorType.other:
      //  debugPrint(err.message);
        throw NoInternetConnectionException(err.requestOptions);
    }

    return handler.next(err);
  }
}

class BadRequestException extends DioError {
  final String _message;

  BadRequestException(RequestOptions r, this._message)
      : super(requestOptions: r);

  @override
  String toString() {
    return _message;
  }
}

class InternalServerErrorException extends DioError {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Unknown error occurred, please try again later.';
  }
}

class ConflictException extends DioError {
  ConflictException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Conflict occurred';
  }
}

class PermissionDenied extends DioError {
  PermissionDenied(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Permission Denied';
  }
}

class UnauthorizedException extends DioError {
  UnauthorizedException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Access denied';
  }
}

class NotFoundException extends DioError {
  NotFoundException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The requested information could not be found';
  }
}

class NoInternetConnectionException extends DioError {
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'No internet connection detected, please try again.';
  }
}

class DeadlineExceededException extends DioError {
  DeadlineExceededException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The connection has timed out, please try again.';
  }
}
