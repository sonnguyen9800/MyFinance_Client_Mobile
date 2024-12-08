import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

class BaseApiService {
  late String baseUrl;
  final Dio _dio;
  final FlutterSecureStorage _storage;

  BaseApiService({required this.baseUrl})
      : _dio = Dio(),
        _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            developer.log('Token expired or invalid');
            await _storage.delete(key: 'token');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
  FlutterSecureStorage get storage => _storage;

  /// Updates the base URL used by this API service.
  ///
  /// This can be useful if you have multiple environments (e.g. development, staging, production)
  /// and you need to switch between them.
  void updateBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
    _dio.options.baseUrl = baseUrl;
  }
}
