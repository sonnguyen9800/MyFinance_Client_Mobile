import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myfinance_client_flutter/config/theme/app_colors.dart';
import 'package:myfinance_client_flutter/config/theme/app_typography.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/category_controller.dart';
import 'expense_card.dart';
import 'expense_view_utils.dart';

class ExpensesView extends StatelessWidget {
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final CategoryController _categoryController = Get.find<CategoryController>();
  final String? categoryId;

  ExpensesView({super.key}) : categoryId = Get.parameters['categoryId'];

  @override
  Widget build(BuildContext context) {
    var title = 'All Expenses';
    if (categoryId != null) {
      title =
          'Expenses for ${_categoryController.findCategoryById(categoryId!)!.name}';
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          title,
          style: AppTypography.textTheme.headlineMedium!
              .copyWith(color: AppColors.primaryDark),
        ),
        actions: [
          if (categoryId != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Show All Expenses',
              onPressed: () => Get.offNamed('/expenses'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                _expenseController.loadExpenses(forceRefresh: true),
          ),
        ],
      ),
      body: Obx(() {
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

        final filteredExpenses = categoryId != null
            ? _expenseController.expenses
                .where((e) => e.categoryId == categoryId)
                .toList()
            : _expenseController.expenses;

        if (filteredExpenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(categoryId != null
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
            itemCount: filteredExpenses.length + 1,
            itemBuilder: (context, index) {
              if (index == filteredExpenses.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: _expenseController.isLoading.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () =>
                                _expenseController.loadExpenses(loadMore: true),
                            child: Text(
                              'Show more',
                            ),
                          ),
                  ),
                );
              }

              if (index > 0) {
                if (filteredExpenses[index - 1].date.month !=
                    filteredExpenses[index].date.month) {
                  return Column(
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          DateFormat('MMMM yyyy')
                              .format(filteredExpenses[index].date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }
              final expense = filteredExpenses[index];
              return ExpenseCard(
                expense: expense,
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showExpenseUpdateDialog(_expenseController),
        child: const Icon(Icons.add),
      ),
    );
  }
}
