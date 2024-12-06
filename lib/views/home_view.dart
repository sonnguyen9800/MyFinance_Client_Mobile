import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/controllers/category_controller.dart';
import 'package:myfinance_client_flutter/views/expense/expense_view_utils.dart';
import '../controllers/expense_controller.dart';
import '../models/expense/expense_model.dart';
import 'package:intl/intl.dart';

import 'expense/expense_card.dart';

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
            return _buildHomeView();
          }
        });
  }

  Widget _buildHomeView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyFinance'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.person),
          //   onPressed: () => Get.toNamed('/profile'),
          // ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'MyFinance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Expenses'),
              onTap: () {
                Get.back();
                Get.toNamed('/expenses');
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
              title: const Text('Categories'),
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
              title: const Text('About'),
              onTap: () {
                Get.back();
                Get.toNamed('/about');
              },
            ),
          ],
        ),
      ),
      body: Obx(
        () => _expenseController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _expenseController.loadExpenses,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildOverviewPanel(),
                    const SizedBox(height: 16),
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
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesPanel() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/expenses'),
                  child: const Text('View All'),
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
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return ExpenseCard(
      expense: expense,
    );
  }
}
