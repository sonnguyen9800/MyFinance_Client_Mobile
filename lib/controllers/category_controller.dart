import 'package:get/get.dart';
import 'package:myfinance_client_flutter/models/category/api/category_api_model.dart';
import '../models/category/category_model.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

class CategoryController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> loadCategories({bool force = false}) async {
    if (isLoading.value || _isInitialized && !force) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final loadedCategories = await _apiService.getCategories();
      categories.value = loadedCategories;
      _isInitialized = true;
      developer.log('Categories loaded successfully: ${categories.length}');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load categories: $e');
      developer.log('Error loading categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory(
      CategoryUpdateRequest categoryUpdateRequest) async {
    try {
      isLoading.value = true;

      // Create a temporary category for optimistic update
      final tempCategory = Category(
        id: DateTime.now().toString(), // Temporary ID
        name: categoryUpdateRequest.name,
        color: categoryUpdateRequest.color,
        iconName: categoryUpdateRequest.iconName,
      );

      // Optimistic update
      categories.add(tempCategory);
      Get.back();
      Get.snackbar('Success', 'Category created successfully');

      // API call
      final newCategory =
          await _apiService.createCategory(categoryUpdateRequest);

      // Update the local cache with the real category
      final index = categories.indexWhere((c) => c.id == tempCategory.id);
      if (index != -1) {
        categories[index] = newCategory;
      }

      developer.log('Category created successfully with ID: ${newCategory.id}');
    } catch (e) {
      // Rollback optimistic update
      categories.removeWhere((c) => c.id == DateTime.now().toString());
      Get.snackbar('Error', 'Failed to create category: $e');
      developer.log('Error creating category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(String id, CategoryUpdateRequest request) async {
    try {
      isLoading.value = true;

      // Store the original category for rollback
      final originalCategory = categories.firstWhere((c) => c.id == id);
      final originalIndex = categories.indexOf(originalCategory);

      // Optimistic update
      final tempCategory = Category(
        id: id,
        name: request.name,
        color: request.color,
        iconName: request.iconName,
      );
      categories[originalIndex] = tempCategory;
      Get.back();
      Get.snackbar('Success', 'Category updated successfully');

      // API call
      final updatedCategory = await _apiService.updateCategory(id, request);

      // Update with the real response
      categories[originalIndex] = updatedCategory;

      developer.log('Category updated successfully: $id');
    } catch (e) {
      // Rollback optimistic update
      final originalCategory = categories.firstWhere((c) => c.id == id);
      final index = categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        categories[index] = originalCategory;
      }
      Get.snackbar('Error', 'Failed to update category: $e');
      developer.log('Error updating category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    Category? deletedCategory;
    int? deletedIndex;

    try {
      isLoading.value = true;

      // Store category before deletion for potential rollback
      deletedCategory = categories.firstWhere((c) => c.id == id);
      deletedIndex = categories.indexOf(deletedCategory);

      // Optimistic update
      categories.removeWhere((c) => c.id == id);
      Get.back();
      Get.snackbar('Success', 'Category deleted successfully');

      // API call
      await _apiService.deleteCategory(id);
      developer.log('Category deleted successfully: $id');
    } catch (e) {
      // Rollback optimistic update if we have the deleted category
      if (deletedCategory != null && deletedIndex != null) {
        categories.insert(deletedIndex, deletedCategory);
        developer.log('Rolling back delete for category: $id');
      }
      Get.snackbar('Error', 'Failed to delete category: $e');
      developer.log('Error deleting category: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Category? findCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      developer.log('Category not found: $id');
      return null;
    }
  }

  void clearCache() {
    _isInitialized = false;
    categories.clear();
  }
}
