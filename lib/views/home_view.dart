import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myfinance_client_flutter/config/theme/app_colors.dart';
import 'package:myfinance_client_flutter/config/theme/app_typography.dart';
import 'package:myfinance_client_flutter/controllers/category_controller.dart';
import 'package:myfinance_client_flutter/views/expense/expense_view_utils.dart';

import '../controllers/expense_controller.dart';
import 'expense/expense_card.dart';
import 'widget/app_shell.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final CategoryController _categoryController = Get.find<CategoryController>();

  Future<void> _initialLoad() async {
    await _categoryController.loadCategories();
    await _expenseController.loadExpenses();
    await _expenseController.loadLastExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialLoad(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return _buildHomeView(context);
        }
      },
    );
  }

  Widget _buildHomeView(BuildContext context) {
    return AppShell(
      appBarBuilder: (isPermanentNavigation) => AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        automaticallyImplyLeading: !isPermanentNavigation,
        title: Text(
          'MyFinance',
          style: AppTypography.textTheme.headlineMedium!
              .copyWith(color: AppColors.primaryDark),
        ),
      ),
      body: Obx(
        () => _expenseController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _expenseController.loadExpenses,
                child: ListView(
                  padding: const EdgeInsets.all(5.0),
                  children: [
                    _buildOverviewPanel(),
                    const SizedBox(height: 0),
                    _buildExpensesPanel(),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showExpenseUpdateDialog(_expenseController),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOverviewPanel() {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '?');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: AppTypography.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    'Last 30 Days',
                    currencyFormat.format(_expenseController.totalLast30Days),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewItem(
                    'Last 7 Days',
                    currencyFormat.format(_expenseController.totalLast7Days),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String title, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: AppTypography.textTheme.bodyLarge!.copyWith(
            color: Theme.of(Get.context!).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Expenses',
                style: AppTypography.textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => Get.toNamed('/expenses'),
                child: Text(
                  'View All',
                  style: AppTypography.textTheme.titleMedium!.copyWith(
                    color: Theme.of(Get.context!).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final recentExpenses = _expenseController.expenses.take(5).toList();
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentExpenses.length,
            itemBuilder: (context, index) {
              final expense = recentExpenses[index];
              return ExpenseCard(expense: expense);
            },
          );
        }),
      ],
    );
  }
}
