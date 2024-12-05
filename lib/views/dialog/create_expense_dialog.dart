import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/expense/expense_model.dart';
import '../../controllers/expense_controller.dart';

class CreateExpenseDialog extends StatelessWidget {
  final Expense? expense;
  final ExpenseController expenseController;

  const CreateExpenseDialog({
    Key? key,
    this.expense,
    required this.expenseController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: expense?.name);
    final descriptionController =
        TextEditingController(text: expense?.description);
    final amountController =
        TextEditingController(text: expense?.amount.toString() ?? '');
    final paymentMethodController =
        TextEditingController(text: expense?.paymentMethod);
    final categoryController = TextEditingController(text: expense?.category);
    final selectedDate = expense?.date ?? DateTime.now();

    return Dialog(
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
                      expenseController.deleteExpense(expense!.id!);
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
                      expenseController.addExpense(newExpense);
                    } else {
                      expenseController.updateExpense(newExpense);
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
    );
  }
}

// Helper function to show the dialog
void showExpenseDialog(ExpenseController expenseController,
    [Expense? expense]) {
  Get.dialog(
    CreateExpenseDialog(
      expense: expense,
      expenseController: expenseController,
    ),
  );
}
