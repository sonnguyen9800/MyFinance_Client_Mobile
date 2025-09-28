import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/theme/app_typography.dart';
import '../controllers/category_controller.dart';
import '../controllers/expense_controller.dart';
import '../controllers/navigation_controller.dart';
import 'expense/expense_card.dart';
import 'expense/expense_view_utils.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  static Widget buildFloatingActionButton() {
    final expenseController = Get.find<ExpenseController>();
    return FloatingActionButton(
      onPressed: () => showExpenseUpdateDialog(expenseController),
      child: const Icon(Icons.add),
    );
  }

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final CategoryController _categoryController = Get.find<CategoryController>();
  final NavigationController _navigationController =
      Get.find<NavigationController>();
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _initialLoad();
  }

  Future<void> _initialLoad() async {
    await _categoryController.loadCategories();
    await _expenseController.loadExpenses();
    await _expenseController.loadLastExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Obx(
      () => _expenseController.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _expenseController.loadExpenses,
              child: ListView(
                padding: const EdgeInsets.all(5.0),
                children: [
                  _buildOverviewPanel(context),
                  const SizedBox(height: 8),
                  _buildExpensesPanel(context),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewPanel(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
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
                    context,
                    'Last 30 Days',
                    currencyFormat.format(_expenseController.totalLast30Days),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewItem(
                    context,
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

  Widget _buildOverviewItem(
    BuildContext context,
    String title,
    String amount,
  ) {
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
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Expenses',
                style: AppTypography.textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => _navigationController
                    .setSection(NavigationSection.expenses),
                child: Text(
                  'View All',
                  style: AppTypography.textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final recentExpenses = _expenseController.expenses.take(5).toList();
          if (recentExpenses.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No expenses recorded yet'),
            );
          }
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
