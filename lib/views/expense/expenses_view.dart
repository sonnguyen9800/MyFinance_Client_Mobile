import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/views/expense/expense_view_utils.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/category_controller.dart';
import 'create_expense_dialog.dart';
import 'expense_card.dart';

class ExpensesView extends StatefulWidget {
  const ExpensesView({Key? key}) : super(key: key);

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final CategoryController _categoryController = Get.find<CategoryController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupScrollListener();
  }

  Future<void> _initializeData() async {
    await _categoryController.loadCategories();
    await _expenseController.loadExpenses();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _expenseController.loadExpenses();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _categoryController.loadCategories(force: true);
    await _expenseController.loadExpenses(
        forceRefresh: true); // Add this line();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
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
                  onPressed: _refreshData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_expenseController.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No expenses found'),
                ElevatedButton(
                  onPressed: () => showExpenseDialog(_expenseController),
                  child: const Text('Add Expense'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: _expenseController.expenses.length +
                (_expenseController.isLoading.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _expenseController.expenses.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final expense = _expenseController.expenses[index];
              return ExpenseCard(
                expense: expense,
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showExpenseDialog(_expenseController),
        child: const Icon(Icons.add),
      ),
    );
  }
}
