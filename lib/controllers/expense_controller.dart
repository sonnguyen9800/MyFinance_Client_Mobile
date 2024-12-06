import 'package:get/get.dart';
import '../models/expense/expense_model.dart';
import '../services/api_service.dart';

class ExpenseController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxList<Expense> expenses = <Expense>[].obs;
  int last7DaysExpenses = 0;
  int last30DaysExpenses = 0;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentOffset = 0.obs;

  final RxInt currentMonth = DateTime.now().month.obs;
  final RxInt currentYear = DateTime.now().year.obs;
  final RxInt monthlyTotalAmount = 0.obs;

  final int limit = 10;
  bool _hasCache = false;
  final Map<String, bool> _cachedPeriods = {};

  String _getPeriodKey(int month, int year) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${monthNames[month - 1]}$year';
  }

  bool isPeriodCached(int month, int year) {
    return _cachedPeriods[_getPeriodKey(month, year)] ?? false;
  }

  // Helper method to get expenses for a specific month
  List<Expense> getExpensesForMonth(int month, int year) {
    return expenses.where((expense) {
      final expenseDate = expense.date;
      return expenseDate.month == month && expenseDate.year == year;
    }).toList();
  }

  // Calculate total amount for a list of expenses
  int calculateTotalAmount(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Future<void> loadExpenses(
      {bool loadMore = false, bool forceRefresh = false}) async {
    if (isLoading.value) return;

    try {
      if (!loadMore && !forceRefresh && _hasCache) {
        return;
      }

      isLoading.value = true;
      if (!loadMore) {
        currentOffset.value = 0;
        hasError.value = false;
        errorMessage.value = '';
        expenses.clear();
        _hasCache = false;
      }

      final loadedExpenses = await _apiService.getExpenses(
        page: currentOffset.value,
        limit: limit,
      );

      if (loadedExpenses.expenses.isEmpty) {
        if (loadMore) {
          Get.snackbar('Info', 'No more records available');
        }
        return;
      }

      if (loadMore) {
        expenses.addAll(loadedExpenses.expenses);
      } else {
        expenses.value = loadedExpenses.expenses;
      }

      currentOffset.value += loadedExpenses.expenses.length;
      _hasCache = true;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMonthlyExpenses({bool forceRefresh = false}) async {
    try {
      // Check if we have expenses for this month in cache
      final monthlyExpenses =
          getExpensesForMonth(currentMonth.value, currentYear.value);

      if (!forceRefresh &&
          monthlyExpenses.isNotEmpty &&
          isPeriodCached(currentMonth.value, currentYear.value)) {
        // Use cached data
        monthlyTotalAmount.value = calculateTotalAmount(monthlyExpenses);
        return;
      }

      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _apiService.getMontlyExpenses(
        currentMonth.value,
        currentYear.value,
      );

      // Add new expenses to the cache if they don't exist
      for (final expense in result.expenses) {
        if (!expenses.any((e) => e.id == expense.id)) {
          expenses.add(expense);
          currentOffset.value += 1;
        }
      }

      // Mark this period as cached
      _cachedPeriods[_getPeriodKey(currentMonth.value, currentYear.value)] =
          true;

      monthlyTotalAmount.value = calculateTotalAmount(monthlyExpenses);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load monthly expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void nextMonth() {
    if (currentMonth.value == 12) {
      currentMonth.value = 1;
      currentYear.value++;
    } else {
      currentMonth.value++;
    }
    loadMonthlyExpenses();
  }

  void previousMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value--;
    } else {
      currentMonth.value--;
    }
    loadMonthlyExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    try {
      isLoading.value = true;
      await _apiService.createExpense(expense);
      expenses.insert(0, expense);
      currentOffset.value += 1;
      await loadLastExpenses();

      // Update monthly total if the expense is for the current month
      final expenseDate = expense.date;
      if (expenseDate.month == currentMonth.value &&
          expenseDate.year == currentYear.value) {
        monthlyTotalAmount.value += expense.amount;
      }

      Get.snackbar('Success', 'Expense added successfully');
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

      final index = expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        final oldExpense = expenses[index];
        expenses[index] = expense;

        // Update monthly total if the expense is for the current month
        final expenseDate = expense.date;
        final oldExpenseDate = oldExpense.date;

        if (oldExpenseDate.month == currentMonth.value &&
            oldExpenseDate.year == currentYear.value) {
          monthlyTotalAmount.value -= oldExpense.amount;
        }

        if (expenseDate.month == currentMonth.value &&
            expenseDate.year == currentYear.value) {
          monthlyTotalAmount.value += expense.amount;
        }
      }

      await loadLastExpenses();
      Get.snackbar('Success', 'Expense updated successfully');
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

      final expense = expenses.firstWhere((e) => e.id == id);
      final expenseDate = expense.date;

      // Update monthly total if the expense is for the current month
      if (expenseDate.month == currentMonth.value &&
          expenseDate.year == currentYear.value) {
        monthlyTotalAmount.value -= expense.amount;
      }

      expenses.removeWhere((e) => e.id == id);
      currentOffset.value -= 1;
      await loadLastExpenses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLastExpenses() async {
    try {
      isLoading.value = true;
      final lastExpenses = await _apiService.getTotalSpendLastExpenses();
      last7DaysExpenses = lastExpenses.expensesLast7Days;
      last30DaysExpenses = lastExpenses.expensesLast30Days;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load last expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshExpenses() {
    loadExpenses(forceRefresh: true);
  }

  int get totalLast30Days => last30DaysExpenses;
  int get totalLast7Days => last7DaysExpenses;
}
