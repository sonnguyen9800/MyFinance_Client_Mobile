import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/config/environment_config.dart';
import 'package:myfinance_client_flutter/models/api/auth_response.dart';
import 'package:myfinance_client_flutter/models/expense/api/expense_api_model.dart';
import 'package:myfinance_client_flutter/models/user/user_model.dart';
import '../models/api/ping_model.dart';
import '../models/expense/expense_model.dart';
import '../models/category/category_model.dart';
import '../models/category/api/category_api_model.dart';
import 'auth_api_service.dart';
import 'category_api_service.dart';
import 'expense_api_service.dart';

/// ApiService acts as a facade for all API services
class ApiService extends GetxService {
  late final AuthApiService _authService;
  late final CategoryApiService _categoryService;
  late final ExpenseApiService _expenseService;
  late String baseUrl;

  ApiService() {
    baseUrl = 'http://10.0.2.2:8080/api';
    _authService = AuthApiService(baseUrl: baseUrl);
    _categoryService = CategoryApiService(baseUrl: baseUrl);
    _expenseService = ExpenseApiService(baseUrl: baseUrl);
  }

  Future<bool> _ping(String address) async {
    try {
      final dio = Dio()..options.connectTimeout = Duration(seconds: 5);

      address = address.trim();
      final response = await dio.get('$address/ping');

      PingResponse pingResponse = PingResponse.fromJson(response.data);

      if (response.statusCode != 200) {
        return false;
      }
      final serverCodeResponse = pingResponse.serverCode;
      final serverCode = EnvironmentConfig.serverCode;
      if (serverCode != serverCodeResponse) {
        Get.snackbar('Error', 'Server code does not match');
        return false;
      }
      Get.snackbar('Success', 'Server is online');
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
}
