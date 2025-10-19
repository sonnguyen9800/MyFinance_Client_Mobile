import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/config/environment_config.dart';
import 'package:myfinance_client_flutter/models/api/auth_response.dart';
import 'package:myfinance_client_flutter/models/category/api/category_api_model.dart';
import 'package:myfinance_client_flutter/models/category/category_model.dart';
import 'package:myfinance_client_flutter/models/expense/api/expense_api_model.dart';
import 'package:myfinance_client_flutter/models/expense/expense_model.dart';
import 'package:myfinance_client_flutter/models/portfolio/asset_class_model.dart';
import 'package:myfinance_client_flutter/models/portfolio/asset_model.dart';
import 'package:myfinance_client_flutter/models/portfolio/cash_flow_model.dart';
import 'package:myfinance_client_flutter/models/portfolio/portfolio_requests.dart';
import 'package:myfinance_client_flutter/models/portfolio/portfolio_summary_model.dart';
import 'package:myfinance_client_flutter/models/portfolio/position_lot_model.dart';
import 'package:myfinance_client_flutter/models/portfolio/valuation_snapshot_model.dart';
import 'package:myfinance_client_flutter/models/user/user_model.dart';

import '../models/api/ping_model.dart';
import 'auth_api_service.dart';
import 'category_api_service.dart';
import 'expense_api_service.dart';
import 'portfolio_api_service.dart';
import 'storage/app_storage.dart';

/// ApiService acts as a facade for auth, category, and expense API clients.
class ApiService extends GetxService {
  ApiService(this._storage) : _dio = Dio() {
    baseUrl = _resolveInitialBaseUrl();
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            developer.log('Token expired or invalid');
            await _storage.delete('token');
          }
          return handler.next(error);
        },
      ),
    );

    _authService =
        AuthApiService(baseUrl: baseUrl, dio: _dio, storage: _storage);
    _categoryService =
        CategoryApiService(baseUrl: baseUrl, dio: _dio, storage: _storage);
    _expenseService =
        ExpenseApiService(baseUrl: baseUrl, dio: _dio, storage: _storage);
    _portfolioService =
        PortfolioApiService(baseUrl: baseUrl, dio: _dio, storage: _storage);
  }

  late final AuthApiService _authService;
  late final CategoryApiService _categoryService;
  late final ExpenseApiService _expenseService;
  late final PortfolioApiService _portfolioService;
  late String baseUrl;
  final Dio _dio;
  final AppStorage _storage;

  String _resolveInitialBaseUrl() {
    const mobileDefault = 'http://myfinance.sonnguyen9800.com/';
    const webDefault = String.fromEnvironment(
      'WEB_API_BASE_URL',
      defaultValue: 'http://localhost:8080/api',
    );

    return kIsWeb ? webDefault : mobileDefault;
  }

  Future<bool> _ping(String address) async {
    try {
      final dio = Dio()..options.connectTimeout = const Duration(seconds: 5);

      address = address.trim();
      final response = await dio.get('$address/ping');

      final pingResponse = PingResponse.fromJson(response.data);

      if (response.statusCode != 200) {
        return false;
      }
      final serverCodeResponse = pingResponse.serverCode;
      final serverCode = EnvironmentConfig.serverCode;
      if (serverCode != serverCodeResponse) {
        Get.snackbar('Error', 'Server code does not match');
        return false;
      }
      Get.snackbar('Success', 'Server is online $address');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to ping server: $e');
    }
    return false;
  }

  Future<bool> ping(String address) async {
    return await _ping(address);
  }

  void updateBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
    _authService.updateBaseUrl(newBaseUrl);
    _categoryService.updateBaseUrl(newBaseUrl);
    _expenseService.updateBaseUrl(newBaseUrl);
    _portfolioService.updateBaseUrl(newBaseUrl);
  }

  // Auth methods
  Future<AuthResponse> login(String email, String password) =>
      _authService.login(email, password);

  Future<AuthResponse> signup(String name, String email, String password) =>
      _authService.signup(name, email, password);

  Future<User> getCurrentUser() => _authService.getCurrentUser();

  // Category methods
  Future<List<Category>> getCategories() => _categoryService.getCategories();

  Future<Category> createCategory(CategoryUpdateRequest category) =>
      _categoryService.createCategory(category);

  Future<Category> updateCategory(String id, CategoryUpdateRequest category) =>
      _categoryService.updateCategory(id, category);

  Future<void> deleteCategory(String id) => _categoryService.deleteCategory(id);

  // Expense methods
  Future<ExpensesResponse> getExpenses({
    required int offset,
    required int limit,
    String? search,
    String? sortBy,
    bool? ascending,
  }) =>
      _expenseService.getExpenses(
        offset: offset,
        limit: limit,
        search: search,
        sortBy: sortBy,
        ascending: ascending,
      );

  Future<Expense> createExpense(Expense expense) =>
      _expenseService.createExpense(expense);

  Future<Expense> updateExpense(String id, Expense expense) =>
      _expenseService.updateExpense(id, expense);

  Future<void> deleteExpense(String id) => _expenseService.deleteExpense(id);

  Future<List<Expense>> getExpensesByDateRange(
          DateTime startDate, DateTime endDate) =>
      _expenseService.getExpensesByDateRange(startDate, endDate);

  Future<LastExpensesModel> getTotalSpendLastExpenses() async {
    return await _expenseService.getTotalSpendLastExpenses();
  }

  Future<MontlyExpensesModel> getMontlyExpenses(int month, int year) async {
    return await _expenseService.getMontlyExpenses(month, year);
  }

  // Portfolio methods
  Future<List<AssetClassModel>> getAssetClasses() =>
      _portfolioService.getAssetClasses();

  Future<List<AssetModel>> getAssets({bool includeInactive = false}) =>
      _portfolioService.getAssets(includeInactive: includeInactive);

  Future<AssetModel> getAsset(String id) => _portfolioService.getAsset(id);

  Future<AssetModel> createAsset(AssetUpsertRequest request) =>
      _portfolioService.createAsset(request);

  Future<AssetModel> updateAsset(String id, AssetUpsertRequest request) =>
      _portfolioService.updateAsset(id, request);

  Future<void> deleteAsset(String id) => _portfolioService.deleteAsset(id);

  Future<List<PositionLotModel>> getPositionLots(String assetId) =>
      _portfolioService.getPositionLots(assetId);

  Future<PositionLotModel> createPositionLot(
    String assetId,
    PositionLotRequest request,
  ) =>
      _portfolioService.createPositionLot(assetId, request);

  Future<PositionLotModel> updatePositionLot(
    String assetId,
    String lotId,
    PositionLotRequest request,
  ) =>
      _portfolioService.updatePositionLot(assetId, lotId, request);

  Future<void> deletePositionLot(String assetId, String lotId) =>
      _portfolioService.deletePositionLot(assetId, lotId);

  Future<List<CashFlowModel>> getCashFlows(String assetId) =>
      _portfolioService.getCashFlows(assetId);

  Future<CashFlowModel> createCashFlow(
    String assetId,
    CashFlowRequest request,
  ) =>
      _portfolioService.createCashFlow(assetId, request);

  Future<void> deleteCashFlow(String assetId, String cashFlowId) =>
      _portfolioService.deleteCashFlow(assetId, cashFlowId);

  Future<List<ValuationSnapshotModel>> getValuations(
    String assetId, {
    int limit = 50,
  }) =>
      _portfolioService.getValuations(assetId, limit: limit);

  Future<ValuationSnapshotModel> createValuation(
    String assetId,
    ValuationSnapshotRequest request,
  ) =>
      _portfolioService.createValuation(assetId, request);

  Future<void> deleteValuation(String assetId, String valuationId) =>
      _portfolioService.deleteValuation(assetId, valuationId);

  Future<PortfolioSummaryModel> getPortfolioSummary({String? baseCurrency}) =>
      _portfolioService.getPortfolioSummary(baseCurrency: baseCurrency);
}
