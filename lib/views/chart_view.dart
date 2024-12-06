import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';

class ChartView extends StatefulWidget {
  const ChartView({super.key});

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  bool _showFanChart = false;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Charts'),
        actions: [
          IconButton(
            icon: Icon(_showFanChart ? Icons.show_chart : Icons.pie_chart),
            onPressed: () {
              setState(() {
                _showFanChart = !_showFanChart;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateRangeSelector(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _showFanChart ? _buildFanChart() : _buildLineChart(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(
                  start: _startDate,
                  end: _endDate,
                ),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = picked.end;
                });
              }
            },
            child: Text(
              '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('MMM d').format(_endDate)}',
            ),
          ),
          DropdownButton<int>(
            value: _endDate.difference(_startDate).inDays,
            items: const [
              DropdownMenuItem(value: 7, child: Text('Last 7 days')),
              DropdownMenuItem(value: 30, child: Text('Last 30 days')),
              DropdownMenuItem(value: 90, child: Text('Last 90 days')),
            ],
            onChanged: (int? days) {
              if (days != null) {
                setState(() {
                  _startDate = DateTime.now().subtract(Duration(days: days));
                  _endDate = DateTime.now();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return Obx(() {
      if (_expenseController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final expenses = _expenseController.expenses
          .where((e) => e.date.isAfter(_startDate) && e.date.isBefore(_endDate))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      if (expenses.isEmpty) {
        return const Center(child: Text('No expenses in selected date range'));
      }

      // Group expenses by date
      final Map<DateTime, double> dailyExpenses = {};
      for (var expense in expenses) {
        final date =
            DateTime(expense.date.year, expense.date.month, expense.date.day);
        dailyExpenses[date] = (dailyExpenses[date] ?? 0) + expense.amount;
      }

      final spots = dailyExpenses.entries.map((e) {
        return FlSpot(
          e.key.millisecondsSinceEpoch.toDouble(),
          e.value,
        );
      }).toList();

      return LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(DateFormat('MMM d').format(date)),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(NumberFormat.compact().format(value)),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFanChart() {
    return Obx(() {
      if (_expenseController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final expenses = _expenseController.expenses
          .where((e) => e.date.isAfter(_startDate) && e.date.isBefore(_endDate))
          .toList();

      if (expenses.isEmpty) {
        return const Center(child: Text('No expenses in selected date range'));
      }

      // Group expenses by category
      final Map<String, double> categoryExpenses = {};
      for (var expense in expenses) {
        var category = expense.categoryId ?? "";
        if (category.isEmpty) {
          continue;
        }

        categoryExpenses[category] =
            (categoryExpenses[expense.categoryId] ?? 0) + expense.amount;
      }

      final total = categoryExpenses.values.reduce((a, b) => a + b);

      final sections = categoryExpenses.entries.map((e) {
        final percentage = e.value / total;
        final color = Colors.primaries[
            categoryExpenses.keys.toList().indexOf(e.key) %
                Colors.primaries.length];

        return PieChartSectionData(
          color: color,
          value: e.value,
          title: '${e.key}\n${(percentage * 100).toStringAsFixed(1)}%',
          radius: 150,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList();

      return PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 0,
          sectionsSpace: 2,
        ),
      );
    });
  }
}
