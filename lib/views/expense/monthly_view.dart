import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../controllers/expense_controller.dart';
import 'expense_card.dart';

class MonthlySection extends StatefulWidget {
  const MonthlySection({super.key});

  static PreferredSizeWidget appBar(
    BuildContext context,
    bool isPermanentNavigation,
  ) {
    final controller = Get.find<ExpenseController>();
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      automaticallyImplyLeading: !isPermanentNavigation,
      title: Obx(
        () => Text(
          _getMonthYearText(
            controller.currentMonth.value,
            controller.currentYear.value,
          ),
          style: AppTypography.textTheme.headlineMedium!
              .copyWith(color: AppColors.primaryDark),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => controller.loadMonthlyExpenses(forceRefresh: true),
        ),
      ],
    );
  }

  static String _getMonthYearText(int month, int year) {
    final date = DateTime(year, month);
    return DateFormat('MMMM yyyy').format(date);
  }

  @override
  State<MonthlySection> createState() => _MonthlySectionState();
}

class _MonthlySectionState extends State<MonthlySection> {
  final ExpenseController controller = Get.find<ExpenseController>();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = controller.loadMonthlyExpenses(
      callSnackBar: false,
      loadingControl: false,
    );
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
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
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
                        'Total: ${currencyFormat.format(controller.monthlyTotalAmount.value)}',
                        style: AppTypography.textTheme.headlineSmall!
                            .copyWith(color: AppColors.primary),
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
                      'No expenses for ${MonthlySection._getMonthYearText(
                        controller.currentMonth.value,
                        controller.currentYear.value,
                      )}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadMonthlyExpenses(
                    forceRefresh: true,
                  ),
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ExpenseCard(expense: expense);
                    },
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
