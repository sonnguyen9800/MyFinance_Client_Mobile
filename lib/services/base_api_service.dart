import 'package:dio/dio.dart';
import 'package:myfinance_client_flutter/services/storage/app_storage.dart';

class BaseApiService {
  BaseApiService({
    required this.baseUrl,
    required Dio dio,
    required AppStorage storage,
  })  : _dio = dio,
        _storage = storage;

  late String baseUrl;
  final Dio _dio;
  final AppStorage _storage;

  Dio get dio => _dio;
  AppStorage get storage => _storage;

  /// Updates the base URL used by this API service.
  ///
  /// Useful when switching environments (dev, staging, prod) at runtime.
  void updateBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
    _dio.options.baseUrl = baseUrl;
  }
}
