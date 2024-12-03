import 'package:get/get.dart';
import '../models/expense_model.dart';
import '../services/api_service.dart';

class ExpenseController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    try {
      isLoading.value = true;
      expenses.value = await _apiService.getExpenses();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createExpense(Expense expense) async {
    try {
      isLoading.value = true;
      final newExpense = await _apiService.createExpense(expense);
      expenses.add(newExpense);
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExpense(String id, Expense expense) async {
    try {
      isLoading.value = true;
      final updatedExpense = await _apiService.updateExpense(id, expense);
      final index = expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        expenses[index] = updatedExpense;
      }
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteExpense(id);
      expenses.removeWhere((e) => e.id == id);
    } catch (e) {
      Get.snackbar('Error', e.toString());
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
