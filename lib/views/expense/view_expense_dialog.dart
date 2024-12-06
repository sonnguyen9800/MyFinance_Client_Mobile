import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/category_controller.dart';
import '../../models/expense/expense_model.dart';
import '../../models/category/category_model.dart';
import '../utils/color_helper.dart';
import '../utils/icon_helper.dart';

class ViewExpenseDialog extends StatelessWidget {
  final Expense expense;
  final CategoryController _categoryController = Get.find<CategoryController>();

  ViewExpenseDialog({
    Key? key,
    required this.expense,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableText(String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 100),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = _getCategory();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final categoryColor = ColorHelper.getColor(category.color) ?? Colors.grey;
    final IconData? iconData = IconDataHelper.getIconData(category.iconName);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: categoryColor,
                  child: Icon(
                    iconData ?? Icons.question_mark,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Expense Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildScrollableText('Name', expense.name),
            _buildScrollableText('Description', expense.description),
            _buildInfoRow('Category', category.name),
            _buildInfoRow(
              'Amount',
              currencyFormat.format(expense.amount),
            ),
            _buildInfoRow(
              'Date',
              DateFormat('MMMM d, y').format(expense.date),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
