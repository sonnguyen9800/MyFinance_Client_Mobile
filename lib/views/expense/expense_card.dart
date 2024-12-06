import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myfinance_client_flutter/views/utils/color_helper.dart';
import '../../controllers/category_controller.dart';
import '../../models/expense/expense_model.dart';
import '../../models/category/category_model.dart';
import '../utils/icon_helper.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final CategoryController _categoryController = Get.find<CategoryController>();

  ExpenseCard({
    Key? key,
    required this.expense,
    this.onTap,
  }) : super(key: key);

  Category _getCategory() {
    if (expense.categoryId == null || expense.categoryId!.isEmpty) {
      return _getDefaultCategory();
    }

    final category = _categoryController.findCategoryById(expense.categoryId!);
    return category ?? _getDefaultCategory();
  }

  Category _getDefaultCategory() {
    return _categoryController.categories.firstWhere(
      (category) => category.name == "Default",
      orElse: () => Category(
        id: "default",
        name: "Default",
        color: "#FF5733",
        iconName: "question_mark",
      ),
    );
  }

  Color _getCategoryColor(Category category) {
    return ColorHelper.getColor(category.color) ?? Colors.grey;
  }

  Widget _buildCategoryIcon(Category category) {
    final IconData? iconData = IconDataHelper.getIconData(category.iconName);
    if (iconData == null) {
      return const Icon(
        Icons.question_mark,
        color: Colors.white,
        size: 24,
      );
    }

    return Icon(
      iconData,
      color: Colors.white,
      size: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = _getCategory();
    final cardColor = _getCategoryColor(category);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      color: cardColor.withOpacity(0.2),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cardColor,
          child: _buildCategoryIcon(category),
        ),
        title: Text(
          expense.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM d, y').format(expense.date),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        trailing: Text(
          currencyFormat.format(expense.amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
