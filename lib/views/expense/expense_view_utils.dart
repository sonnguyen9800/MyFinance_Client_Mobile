// Helper function to show the dialog
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/controllers/expense_controller.dart';
import 'package:myfinance_client_flutter/models/expense/expense_model.dart';
import 'package:myfinance_client_flutter/views/expense/create_expense_dialog.dart';

void showExpenseDialog(ExpenseController expenseController,
    [Expense? expense]) {
  Get.dialog(
    CreateExpenseDialog(
      expense: expense,
      expenseController: expenseController,
    ),
  );
}
