import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../controllers/category_controller.dart';
import '../../models/category/category_model.dart';
import '../dialog/create_category_dialog.dart';
import '../utils/icon_helper.dart';

class CategoryView extends StatelessWidget {
  CategoryView({super.key});

  final CategoryController _categoryController = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _categoryController.loadCategories,
          ),
        ],
      ),
      body: Obx(() {
        if (_categoryController.isLoading.value &&
            _categoryController.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_categoryController.hasError.value &&
            _categoryController.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${_categoryController.errorMessage.value}'),
                ElevatedButton(
                  onPressed: _categoryController.loadCategories,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_categoryController.categories.isEmpty) {
          return const Center(
            child: Text('No categories found'),
          );
        }

        return ListView.builder(
          itemCount: _categoryController.categories.length,
          itemBuilder: (context, index) {
            final category = _categoryController.categories[index];
            return _buildCategoryCard(category);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCategoryDialog(_categoryController),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    IconData? iconData = IconDataHelper.getIconData(category.iconName);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Color(int.parse(category.color.replaceAll('#', '0xFF'))),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 206, 179, 179),
          child: iconData != null
              ? FaIcon(iconData,
                  color:
                      Color(int.parse(category.color.replaceAll('#', '0xFF'))))
              : Icon(Icons.category,
                  color:
                      Color(int.parse(category.color.replaceAll('#', '0xFF')))),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => showCategoryDialog(_categoryController, category),
      ),
    );
  }
}
