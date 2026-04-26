import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../auth/token_storage.dart';
import '../auth/auth_notifier.dart';
import '../security/security_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'X-App-Version': AppConfig.version,
      'X-Platform': AppConfig.platform,
    },
  ));

  _applyCertPinning(dio);
  dio.interceptors.add(SecurityInterceptor());
  dio.interceptors.add(_AuthInterceptor(dio, ref));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));
  }

  return dio;
});

void _applyCertPinning(Dio dio) {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    if (kDebugMode) {
      // Trust all certs in debug — avoids self-signed / chain issues on simulator
      client.badCertificateCallback = (_, __, ___) => true;
      return client;
    }
    if (!AppConfig.enableCertPinning || AppConfig.certSha256Fingerprint.isEmpty) {
      return client;
    }
    final expected = AppConfig.certSha256Fingerprint.toLowerCase().replaceAll(':', '');
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      final fingerprint = sha256.convert(cert.der).toString();
      return fingerprint == expected;
    };
    return client;
  };
}

final publicDioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: AppConfig.publicApiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'X-App-Version': AppConfig.version,
      'X-Platform': AppConfig.platform,
    },
  ));
});

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final Ref _ref;
  bool _isRefreshing = false;
  final _queue = <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  _AuthInterceptor(this._dio, this._ref);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _queue.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    try {
      final refresh = await TokenStorage.getRefreshToken();
      if (refresh == null) throw Exception('No refresh token');

      final response = await Dio().post(
        '${AppConfig.apiBaseUrl}/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final data = response.data['data'];
      await _ref.read(authNotifierProvider.notifier).setTokens(
            data['accessToken'] as String,
            data['refreshToken'] as String,
          );

      for (final item in _queue) {
        _retry(item.options, item.handler);
      }
      _queue.clear();
      _retry(err.requestOptions, handler);
    } catch (_) {
      await _ref.read(authNotifierProvider.notifier).signOut();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _retry(RequestOptions options, ErrorInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await _dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
