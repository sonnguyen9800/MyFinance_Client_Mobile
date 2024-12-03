import 'package:get/get.dart';
import '../models/expense_model.dart';
import '../services/api_service.dart';

class ExpenseController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't load expenses automatically on init
  }

  Future<void> loadExpenses() async {
    if (isLoading.value) return; // Prevent multiple simultaneous loads

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final loadedExpenses = await _apiService.getExpenses();
      expenses.value = loadedExpenses;
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
      await loadExpenses(); // Reload the list after adding
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
      await loadExpenses(); // Reload the list after updating
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
      await loadExpenses(); // Reload the list after deleting
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete expense: $e');
    } finally {
      isLoading.value = false;
    }
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
