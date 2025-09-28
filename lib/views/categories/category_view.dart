import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/navigation_controller.dart';
import 'category_card.dart';
import 'create_category_dialog.dart';

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  static PreferredSizeWidget appBar(
    BuildContext context,
    bool isPermanentNavigation,
  ) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      automaticallyImplyLeading: !isPermanentNavigation,
      title: Text(
        'Categories',
        style: AppTypography.textTheme.headlineMedium!
            .copyWith(color: AppColors.primaryDark),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () =>
              Get.find<CategoryController>().loadCategories(force: true),
        ),
      ],
    );
  }

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  final CategoryController _categoryController = Get.find<CategoryController>();
  final NavigationController _navigationController =
      Get.find<NavigationController>();

  @override
  void initState() {
    super.initState();
    _ensureData();
  }

  Future<void> _ensureData() async {
    if (_categoryController.categories.isEmpty) {
      await _categoryController.loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
                  CreateCategoryDialog(categoryController: _categoryController),
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
              isAllowControl: true,
              category: category,
              categoryController: _categoryController,
              onViewExpenses: () => _navigationController.setSection(
                NavigationSection.expenses,
                categoryId: category.id,
              ),
            );
          },
        ),
      );
    });
  }
}
