import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:font_awesome_flutter/name_icon_mapping.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/category_model.dart';
import '../../controllers/category_controller.dart';
import '../utils/icon_helper.dart';

class CreateCategoryDialog extends StatefulWidget {
  final Category? category;
  final CategoryController categoryController;

  const CreateCategoryDialog({
    Key? key,
    this.category,
    required this.categoryController,
  }) : super(key: key);

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  late TextEditingController nameController;
  late Color pickedColor;
  IconData? selectedIcon;
  String iconName = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.category?.name);
    pickedColor = widget.category != null
        ? Color(int.parse(widget.category!.color.replaceAll('#', '0xFF')))
        : Colors.blue;
    if (widget.category != null) {
      iconName = widget.category!.iconName;
      selectedIcon = IconDataHelper.getIconData(iconName);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
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
      selectedIcon = icon.data;

      iconName = IconDataHelper.getIconName(icon.data);
    });
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (Color color) {
                setState(() => pickedColor = color);
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.category == null ? 'New Category' : 'Edit Category',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Icon'),
              leading: selectedIcon != null
                  ? FaIcon(selectedIcon)
                  : const Icon(Icons.category),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickIcon,
            ),
            ListTile(
              title: const Text('Color'),
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: pickedColor,
                  shape: BoxShape.circle,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showColorPicker,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                if (widget.category != null)
                  TextButton(
                    onPressed: () {
                      Get.back();
                      widget.categoryController
                          .deleteCategory(widget.category!.id!);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty || iconName.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please fill in all fields',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    final category = Category(
                      id: widget.category?.id,
                      name: nameController.text,
                      iconName: iconName,
                      color:
                          '#${pickedColor.value.toRadixString(16).substring(2)}',
                    );

                    if (widget.category == null) {
                      widget.categoryController.createCategory(category);
                    } else {
                      widget.categoryController.updateCategory(category);
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
