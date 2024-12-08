import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/config/theme/app_colors.dart';
import 'package:myfinance_client_flutter/config/theme/app_typography.dart';
import '../../controllers/category_controller.dart';
import 'create_category_dialog.dart';
import 'category_card.dart';

class CategoryView extends StatelessWidget {
  final CategoryController _categoryController = Get.find<CategoryController>();

  CategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
          style: AppTypography.textTheme.titleLarge!.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _categoryController.loadCategories(force: true),
          ),
        ],
      ),
      body: Obx(() {
        if (_categoryController.isLoading.value &&
            _categoryController.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_categoryController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_categoryController.errorMessage.value),
                ElevatedButton(
                  onPressed: () => _categoryController.loadCategories(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_categoryController.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No categories found'),
                ElevatedButton(
                  onPressed: () => Get.dialog(
                    CreateCategoryDialog(
                        categoryController: _categoryController),
                  ),
                  child: const Text('Add Category'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _categoryController.loadCategories(force: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _categoryController.categories.length,
            itemBuilder: (context, index) {
              final category = _categoryController.categories[index];
              return CategoryCard(
                category: category,
                categoryController: _categoryController,
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Get.dialog(
          //     CreateCategoryDialog(categoryController: _categoryController));
          Get.toNamed('/expenses');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
