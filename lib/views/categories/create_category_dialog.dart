import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:myfinance_client_flutter/config/theme/app_colors.dart';
import 'package:myfinance_client_flutter/models/category/api/category_api_model.dart';
import '../../models/category/category_model.dart';
import '../../controllers/category_controller.dart';
import '../utils/icon_helper.dart';
import 'category_card.dart';

class CreateCategoryDialog extends StatefulWidget {
  final CategoryController categoryController;
  final Category? category;

  const CreateCategoryDialog({
    Key? key,
    required this.categoryController,
    this.category,
  }) : super(key: key);

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final TextEditingController nameController = TextEditingController();
  String iconName = 'question_mark';
  Color pickerColor = const Color(0xff443a49);

  bool get isDefaultCategory =>
      widget.category?.name == 'Default' || nameController.text == 'Default';

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      nameController.text = widget.category!.name;
      iconName = widget.category!.iconName;
      pickerColor =
          Color(int.parse(widget.category!.color.replaceAll('#', '0xff')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                setState(() {
                  pickerColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickIcon() async {
    IconPickerIcon? icon = await showIconPicker(
      context,
      configuration: SinglePickerConfiguration(
        iconPackModes: [IconPack.fontAwesomeIcons],
      ),
    );

    if (icon == null) {
      Get.snackbar("Error", "No Icon Picked");
      return;
    }
    setState(() {
      iconName = IconDataHelper.getIconName(icon.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create a preview category with current values
    final previewCategory = Category(
      id: 'preview',
      name: nameController.text.isEmpty ? 'Preview' : nameController.text,
      iconName: iconName,
      color: '#${pickerColor.value.toRadixString(16).substring(2)}',
    );

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.category == null ? 'Create Category' : 'Edit Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              enabled: !isDefaultCategory || widget.category == null,
              onChanged: (value) =>
                  setState(() {}), // Trigger rebuild for preview
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: isDefaultCategory
                    ? 'Cannot modify Default category name'
                    : 'Enter category name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickIcon,
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(AppColors.accentLight),
                    ),
                    child: Text(
                      'Pick Icon',
                      style: TextStyle(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showColorPicker,
                    style: ButtonStyle(),
                    child: const Text(
                      'Pick Color',
                      style: TextStyle(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Preview Card
            Container(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  CategoryCard(
                    category: previewCategory,
                    categoryController: widget.categoryController,
                    isAllowControl: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Category name cannot be empty',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    // Check if trying to create a new "Default" category
                    if (widget.category == null &&
                        nameController.text.trim() == 'Default') {
                      Get.snackbar(
                        'Error',
                        'Cannot create a new category named "Default"',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    final categoryUpdateRequest = CategoryUpdateRequest(
                      name: nameController.text.trim(),
                      iconName: iconName,
                      color:
                          '#${pickerColor.value.toRadixString(16).substring(2)}',
                    );

                    if (widget.category == null) {
                      widget.categoryController
                          .createCategory(categoryUpdateRequest);
                    } else {
                      widget.categoryController.updateCategory(
                          widget.category!.id!, categoryUpdateRequest);
                    }
                  },
                  child: Text(widget.category == null ? 'Create' : 'Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the dialog
void showCategoryDialog(CategoryController categoryController,
    [Category? category]) {
  Get.dialog(
    CreateCategoryDialog(
      category: category,
      categoryController: categoryController,
    ),
  );
}
