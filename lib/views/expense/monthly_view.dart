import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myfinance_client_flutter/views/expense/expense_card.dart';
import '../../../controllers/expense_controller.dart';
import '../../../models/expense/expense_model.dart';

class MonthlyView extends StatelessWidget {
  final ExpenseController controller = Get.find<ExpenseController>();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  MonthlyView({Key? key}) : super(key: key);

  String _getMonthYearText(int month, int year) {
    final date = DateTime(year, month);
    return DateFormat('MMMM yyyy').format(date);
  }

  void _navigateMonth(int offset) {
    int newMonth = controller.currentMonth.value;
    int newYear = controller.currentYear.value;

    newMonth += offset;
    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    } else if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    controller.currentMonth.value = newMonth;
    controller.currentYear.value = newYear;
    controller.loadMonthlyExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              _getMonthYearText(
                controller.currentMonth.value,
                controller.currentYear.value,
              ),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadMonthlyExpenses(forceRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _navigateMonth(-1),
                ),
                Obx(() => Text(
                      currencyFormat
                          .format(controller.monthlyTotalAmount.value),
                      style: Theme.of(context).textTheme.headlineSmall,
                    )),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _navigateMonth(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final expenses = controller.getExpensesForMonth(
                controller.currentMonth.value,
                controller.currentYear.value,
              );

              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (expenses.isEmpty) {
                return Center(
                  child: Text(
                    'No expenses for ${_getMonthYearText(
                      controller.currentMonth.value,
                      controller.currentYear.value,
                    )}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    controller.loadMonthlyExpenses(forceRefresh: true),
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ExpenseCard(
                      expense: expense,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
