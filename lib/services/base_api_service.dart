import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BaseApiService {
  late String baseUrl;
  late final Dio _dio;
  late final FlutterSecureStorage _storage;

  BaseApiService({ required this.baseUrl, required Dio dio, required FlutterSecureStorage storage }) {
    _dio = dio;
    _storage = storage;
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
