import 'package:get/get.dart';
import '../models/expense_model.dart';
import '../services/api_service.dart';

class ExpenseController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentOffset = 0.obs;
  final int limit = 10;
  bool _hasCache = false;

  Future<void> loadExpenses({bool loadMore = false, bool forceRefresh = false}) async {
    if (isLoading.value) return; // Prevent multiple simultaneous loads

    try {
      // Return cached data if available and not forcing refresh
      if (!loadMore && !forceRefresh && _hasCache) {
        return;
      }

      isLoading.value = true;
      if (!loadMore) {
        // Reset pagination when loading fresh
        currentOffset.value = 0;
        hasError.value = false;
        errorMessage.value = '';
        expenses.clear();
        _hasCache = false;
      }

      final loadedExpenses = await _apiService.getExpenses(
        offset: currentOffset.value,
        limit: limit,
      );

      if (loadedExpenses.isEmpty) {
        if (loadMore) {
          Get.snackbar('Info', 'No more records available');
        }
        return;
      }

      if (loadMore) {
        expenses.addAll(loadedExpenses);
      } else {
        expenses.value = loadedExpenses;
      }

      currentOffset.value += loadedExpenses.length;
      _hasCache = true;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      isLoading.value = true;
      await _apiService.createExpense(expense);
      // Add to cache and maintain order
      expenses.insert(0, expense);
      currentOffset.value += 1;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      isLoading.value = true;
      await _apiService.updateExpense(expense.id!, expense);
      // Update in cache
      final index = expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        expenses[index] = expense;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteExpense(id);
      // Remove from cache
      expenses.removeWhere((e) => e.id == id);
      currentOffset.value -= 1;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Call this when you need to force a refresh of the expenses
  void refreshExpenses() {
    loadExpenses(forceRefresh: true);
  }

  double get totalLast30Days {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return expenses
        .where((e) => e.date.isAfter(thirtyDaysAgo))
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get totalLast7Days {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return expenses
        .where((e) => e.date.isAfter(sevenDaysAgo))
        .fold(0, (sum, e) => sum + e.amount);
  }
}
