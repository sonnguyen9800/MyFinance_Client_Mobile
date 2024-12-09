import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/controllers/category_controller.dart';
import 'package:myfinance_client_flutter/models/category/category_model.dart';
import 'package:myfinance_client_flutter/views/utils/color_helper.dart';
import '../utils/icon_helper.dart';
import 'create_category_dialog.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final CategoryController categoryController;
  final bool isAllowControl;
  const CategoryCard({
    super.key,
    required this.category,
    required this.categoryController,
    required this.isAllowControl,
  });

  void _showOptionsMenu(BuildContext context) {
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
          value: 'View Expenses',
          child: const Text('View Expenses'),
          onTap: () {
            // Need to use Future.delayed because onTap is called before the menu is closed
            Future.delayed(
              Duration.zero,
              () => Get.toNamed(
                '/expenses',
                parameters: {'categoryId': category.id},
              ),
            );
          },
        ),
        PopupMenuItem<String>(
          value: 'Edit',
          child: const Text('Edit'),
          onTap: () => Get.dialog(
            CreateCategoryDialog(
              categoryController: categoryController,
              category: category,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Delete',
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () => _showDeleteConfirmation(context),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Get.back();
              categoryController.deleteCategory(category.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void onViewExpenseTap() {
    Get.back();
    Get.toNamed('/expense', parameters: {'categoryId': category.id});
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = ColorHelper.getColor(category.color) ?? Colors.grey;
    final IconData? iconData = IconDataHelper.getIconData(category.iconName);

    return Card(
      color: categoryColor.withOpacity(0.4),
      child: InkWell(
        onTap: (isAllowControl) ? () => _showOptionsMenu(context) : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: categoryColor,
            child: Icon(
              iconData ?? Icons.question_mark,
              color: Colors.white,
            ),
          ),
          title: Text(
            category.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: (isAllowControl) ? const Icon(Icons.more_vert) : null,
        ),
      ),
    );
  }
}
