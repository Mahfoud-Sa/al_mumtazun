import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../navigation/app_navigator.dart';
import '../storage/secure_auth_storage.dart';

class AppHttpClient {
  final Dio dio;
  final SecureAuthStorage authStorage;

  AppHttpClient({Dio? dio, SecureAuthStorage? authStorage})
    : dio = dio ?? Dio(),
      authStorage = authStorage ?? const SecureAuthStorage() {
    this.dio.options
      ..connectTimeout = const Duration(seconds: 20)
      ..receiveTimeout = const Duration(seconds: 20)
      ..sendTimeout = const Duration(seconds: 20)
      ..responseType = ResponseType.plain
      ..validateStatus = (_) => true;

    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await this.authStorage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          if (response.statusCode == 401) {
            await _handleUnauthorized();
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await dio.getUri<Object?>(
      url,
      options: Options(headers: headers),
    );
    return _toHttpResponse(response);
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await dio.postUri<Object?>(
      url,
      data: body,
      options: Options(headers: headers),
    );
    return _toHttpResponse(response);
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await dio.putUri<Object?>(
      url,
      data: body,
      options: Options(headers: headers),
    );
    return _toHttpResponse(response);
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers}) async {
    final response = await dio.deleteUri<Object?>(
      url,
      options: Options(headers: headers),
    );
    return _toHttpResponse(response);
  }

  Future<void> _handleUnauthorized() async {
    await authStorage.clear();
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.popUntil((route) => route.isFirst);
  }

  http.Response _toHttpResponse(Response<Object?> response) {
    final body = switch (response.data) {
      null => '',
      String value => value,
      List<int> value => utf8.decode(value),
      Object value => jsonEncode(value),
    };

    return http.Response(
      body,
      response.statusCode ?? 0,
      reasonPhrase: response.statusMessage,
      headers: response.headers.map.map(
        (key, value) => MapEntry(key, value.join(',')),
      ),
      request: http.Request(response.requestOptions.method, response.realUri),
    );
  }

  void dispose() => dio.close();
}
