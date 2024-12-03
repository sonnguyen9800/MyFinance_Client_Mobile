import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';

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
        if (_expenseController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_expenseController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${_expenseController.errorMessage.value}'),
                ElevatedButton(
                  onPressed: _expenseController.loadExpenses,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_expenseController.expenses.isEmpty) {
          return const Center(
            child: Text('No expenses found'),
          );
        }

        return ListView.builder(
          itemCount: _expenseController.expenses.length,
          itemBuilder: (context, index) {
            final expense = _expenseController.expenses[index];
            return _buildExpenseCard(expense);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExpenseDialog(),
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
        onTap: () => _showExpenseDialog(expense),
      ),
    );
  }

  void _showExpenseDialog([Expense? expense]) {
    final nameController = TextEditingController(text: expense?.name);
    final descriptionController =
        TextEditingController(text: expense?.description);
    final amountController =
        TextEditingController(text: expense?.amount.toString() ?? '');
    final paymentMethodController =
        TextEditingController(text: expense?.paymentMethod);
    final categoryController = TextEditingController(text: expense?.category);
    DateTime selectedDate = expense?.date ?? DateTime.now();

    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                expense == null ? 'New Expense' : 'Edit Expense',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: paymentMethodController,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  if (expense != null)
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _expenseController.deleteExpense(expense.id!);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      final newExpense = Expense(
                        id: expense?.id,
                        userId: expense?.userId,
                        name: nameController.text,
                        description: descriptionController.text,
                        amount: double.parse(amountController.text),
                        date: selectedDate,
                        paymentMethod: paymentMethodController.text,
                        category: categoryController.text,
                      );

                      if (expense == null) {
                        _expenseController.addExpense(newExpense);
                      } else {
                        _expenseController.updateExpense(newExpense);
                      }
                      Get.back();
                    },
                    child: Text(expense == null ? 'Create' : 'Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
