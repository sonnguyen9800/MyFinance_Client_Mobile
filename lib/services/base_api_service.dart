import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

class BaseApiService {
  final String baseUrl = 'http://10.0.2.2:8080/api';
  final Dio _dio;
  final FlutterSecureStorage _storage;

  BaseApiService()
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
}
