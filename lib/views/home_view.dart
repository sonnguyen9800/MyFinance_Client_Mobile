import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/config/theme/app_colors.dart';
import 'package:myfinance_client_flutter/config/theme/app_typography.dart';
import 'package:myfinance_client_flutter/controllers/category_controller.dart';
import 'package:myfinance_client_flutter/views/expense/expense_view_utils.dart';
import '../controllers/auth_controller.dart';
import '../controllers/expense_controller.dart';
import '../models/expense/expense_model.dart';
import 'package:intl/intl.dart';

import 'expense/expense_card.dart';
import '../widgets/theme_switch.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final CategoryController _categoryController = Get.find<CategoryController>();

  Future<void> fetchData() async {
    //category loaded first
    await _categoryController.loadCategories();
    await _expenseController.loadExpenses();
    await _expenseController.loadLastExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return _buildHomeView(context);
          }
        });
  }

  Widget _buildHomeView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text('MyFinance',
            style: AppTypography.textTheme.headlineMedium!
                .copyWith(color: AppColors.primaryDark)),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.person),
          //   onPressed: () => Get.toNamed('/profile'),
          // ),
        ],
      ),
      drawer: _buildDrawer(context),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Row(
              children: [
                Text(
                  'MyFinance',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(
              'Home',
              style: AppTypography.textTheme.titleMedium,
            ),
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: Text(
              'Expenses',
              style: AppTypography.textTheme.titleMedium,
            ),
            onTap: () {
              Get.back();
              Get.toNamed('/expenses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(
              'Montly Expenses',
              style: AppTypography.textTheme.titleMedium,
            ),
            onTap: () {
              Get.back();
              Get.toNamed('/monthly');
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.pie_chart),
          //   title: const Text('Charts'),
          //   onTap: () {
          //     Get.back();
          //     Get.toNamed('/chart');
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.grade),
            title: Text(
              'Categories',
              style: AppTypography.textTheme.titleMedium,
            ),
            onTap: () {
              Get.back();
              Get.toNamed('/categories');
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.settings),
          //   title: const Text('Settings'),
          //   onTap: () {
          //     Get.back();
          //     Get.toNamed('/settings');
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(
              'About',
              style: AppTypography.textTheme.titleMedium,
            ),
            onTap: () {
              Get.back();
              Get.toNamed('/about');
            },
          ),
          // const ThemeSwitch(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.close),
            title: Text(
              'Logout',
              style: AppTypography.textTheme.titleMedium,
            ),
            onTap: () {
              Get.back();
              final AuthController authController = Get.find<AuthController>();
              authController.logout();
            },
          )
        ],
      ),
    );
  }

  Widget _buildOverviewPanel() {
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
              return _buildExpenseItem(expense);
            },
          );
        }),
      ],
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return ExpenseCard(
      expense: expense,
    );
  }
}
