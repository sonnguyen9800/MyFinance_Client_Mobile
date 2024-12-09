import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';
import 'dialog/create_expense_dialog.dart';

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView>
    with AutomaticKeepAliveClientMixin {
  final ExpenseController _expenseController = Get.find<ExpenseController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _expenseController.loadExpenses();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _expenseController.loadExpenses(),
          ),
        ],
      ),
      body: Obx(() {
        if (_expenseController.isLoading.value &&
            _expenseController.expenses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_expenseController.hasError.value &&
            _expenseController.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${_expenseController.errorMessage.value}'),
                ElevatedButton(
                  onPressed: () => _expenseController.loadExpenses(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _expenseController.expenses.length +
                    1, // +1 for the Show More button
                itemBuilder: (context, index) {
                  if (index == _expenseController.expenses.length) {
                    // Show More button at the last index
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: _expenseController.isLoading.value
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () => _expenseController
                                    .loadExpenses(loadMore: true),
                                child: Text(
                                  'Show more',
                                ),
                              ),
                      ),
                    );
                  }

                  final expense = _expenseController.expenses[index];
                  return _buildExpenseCard(expense);
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showExpenseDialog(_expenseController),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    var category = expense.category ?? "No Category";
    var paymentMethod = expense.paymentMethod ?? "No Payment Method";
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(category),
        ),
        title: Text(expense.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM d, y').format(expense.date)),
            if (expense.description != null && expense.description!.isNotEmpty)
              Text(
                expense.description!,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              paymentMethod,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () => showExpenseDialog(_expenseController, expense),
      ),
    );
  }
}
