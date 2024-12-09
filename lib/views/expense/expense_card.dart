import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myfinance_client_flutter/config/theme/app_colors.dart';
import 'package:myfinance_client_flutter/controllers/expense_controller.dart';
import 'package:myfinance_client_flutter/views/expense/expense_view_utils.dart';
import 'package:myfinance_client_flutter/views/utils/color_helper.dart';
import '../../controllers/category_controller.dart';
import '../../models/expense/expense_model.dart';
import '../../models/category/category_model.dart';
import '../utils/icon_helper.dart';
import 'view_expense_dialog.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final CategoryController _categoryController = Get.find<CategoryController>();

  ExpenseCard({
    super.key,
    required this.expense,
  });

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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final category = _getCategory();
      final cardColor = _getCategoryColor(category);
      final currencyFormat =
          NumberFormat.currency(locale: 'vi_VN', symbol: ' ');

      return Card(
        color: cardColor.withOpacity(0.4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: cardColor,
            child: _buildCategoryIcon(context, category),
          ),
          title: Text(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
          onTap: () => {showDropDownMenu(context)},
        ),
      );
    });
  }

  Widget _buildCategoryIcon(BuildContext context, Category category) {
    final IconData? iconData = IconDataHelper.getIconData(category.iconName);
    return Container(
      width: double.infinity,
      height: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.6,
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData ?? Icons.question_mark,
        color: AppColors.primary,
        size: 25,
      ),
    );
  }

  showDropDownMenu(BuildContext context) {
    final button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem<String>(
          value: 'View',
          child: const Text('View'),
          onTap: () => Get.dialog(ViewExpenseDialog(expense: expense)),
        ),
        PopupMenuItem<String>(
          value: 'Edit',
          child: Text('Edit'),
          onTap: () => showExpenseUpdateDialog(
            Get.find<ExpenseController>(),
            expense,
          ),
        ),
      ],
    );
  }
}
