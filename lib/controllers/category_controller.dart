import 'package:get/get.dart';
import '../models/category/category_model.dart';
import '../services/api_service.dart';

class CategoryController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final loadedCategories = await _apiService.getCategories();
      categories.value = loadedCategories;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory(Category category) async {
    try {
      isLoading.value = true;
      final newCategory = await _apiService.createCategory(category);
      categories.add(newCategory);
      Get.back();
      Get.snackbar('Success', 'Category created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      isLoading.value = true;
      final updatedCategory = await _apiService.updateCategory(category.id!, category);
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        categories[index] = updatedCategory;
      }
      Get.back();
      Get.snackbar('Success', 'Category updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      Get.back();
      Get.snackbar('Success', 'Category deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
