import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:myfinance_client_flutter/config/theme/app_colors.dart';
import 'package:myfinance_client_flutter/config/theme/app_typography.dart';

import '../../controllers/expense_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/navigation_controller.dart';
import 'expense_card.dart';
import 'expense_view_utils.dart';
import 'quick_expense_form.dart';

class ExpensesSection extends StatefulWidget {
  const ExpensesSection({super.key});

  static PreferredSizeWidget appBar(
    BuildContext context,
    bool isPermanentNavigation,
  ) {
    final navigationController = Get.find<NavigationController>();
    final filterCategoryId = navigationController.selectedCategoryId.value;
    final categoryController = Get.find<CategoryController>();
    final title = filterCategoryId != null
        ? 'Expenses for ${categoryController.findCategoryById(filterCategoryId)?.name ?? 'Unknown'}'
        : 'All Expenses';

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      automaticallyImplyLeading: !isPermanentNavigation,
      title: Text(
        title,
        style: AppTypography.textTheme.headlineMedium!
            .copyWith(color: AppColors.primaryDark),
      ),
      actions: [
        if (filterCategoryId != null)
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            tooltip: 'Show All Expenses',
            onPressed: () =>
                navigationController.setSection(NavigationSection.expenses),
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () =>
              Get.find<ExpenseController>().loadExpenses(forceRefresh: true),
        ),
      ],
    );
  }

  static Widget? buildFloatingActionButton() {
    if (kIsWeb) return null;
    final expenseController = Get.find<ExpenseController>();
    return FloatingActionButton(
      onPressed: () => showExpenseUpdateDialog(expenseController),
      child: const Icon(Icons.add),
    );
  }

  @override
  State<ExpensesSection> createState() => _ExpensesSectionState();
}

class _ExpensesSectionState extends State<ExpensesSection> {
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final NavigationController _navigationController =
      Get.find<NavigationController>();

  @override
  void initState() {
    super.initState();
    _ensureData();
  }

  Future<void> _ensureData() async {
    if (_expenseController.expenses.isEmpty) {
      await _expenseController.loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filterCategoryId = _navigationController.selectedCategoryId.value;

      if (_expenseController.isLoading.value &&
          _expenseController.expenses.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_expenseController.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_expenseController.errorMessage.value),
              ElevatedButton(
                onPressed: () => _expenseController.loadExpenses(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final filteredExpenses = filterCategoryId != null
          ? _expenseController.expenses
              .where((e) => e.categoryId == filterCategoryId)
              .toList()
          : _expenseController.expenses;

      if (filteredExpenses.isEmpty && !kIsWeb) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(filterCategoryId != null
                  ? 'No expenses found for this category'
                  : 'No expenses found'),
              ElevatedButton(
                onPressed: () => showExpenseUpdateDialog(_expenseController),
                child: const Text('Add Expense'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _expenseController.loadExpenses(forceRefresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: filteredExpenses.length + 1 + (kIsWeb ? 1 : 0),
          itemBuilder: (context, index) {
            if (kIsWeb && index == 0) {
              return const QuickExpenseForm();
            }

            final adjustedIndex = index - (kIsWeb ? 1 : 0);

            if (adjustedIndex == filteredExpenses.length) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: _expenseController.isLoading.value
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () =>
                              _expenseController.loadExpenses(loadMore: true),
                          child: const Text('Show more'),
                        ),
                ),
              );
            }

            if (adjustedIndex > 0 &&
                filteredExpenses[adjustedIndex - 1].date.month !=
                    filteredExpenses[adjustedIndex].date.month) {
              return Column(
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      DateFormat('MMMM yyyy')
                          .format(filteredExpenses[adjustedIndex].date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }

            final expense = filteredExpenses[adjustedIndex];
            return ExpenseCard(expense: expense);
          },
        ),
      );
    });
  }
}
