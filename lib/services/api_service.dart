import 'package:myfinance_client_flutter/models/api/auth_response.dart';
import 'package:myfinance_client_flutter/models/expense/api/expense_api_model.dart';
import 'package:myfinance_client_flutter/models/user/user_model.dart';
import '../models/expense/expense_model.dart';
import '../models/category/category_model.dart';
import '../models/category/api/category_api_model.dart';
import 'auth_api_service.dart';
import 'category_api_service.dart';
import 'expense_api_service.dart';

/// ApiService acts as a facade for all API services
class ApiService {
  late final AuthApiService _authService;
  late final CategoryApiService _categoryService;
  late final ExpenseApiService _expenseService;

  ApiService() {
    _authService = AuthApiService();
    _categoryService = CategoryApiService();
    _expenseService = ExpenseApiService();
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
