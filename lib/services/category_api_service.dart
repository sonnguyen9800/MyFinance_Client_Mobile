import '../models/category/category_model.dart';
import '../models/category/api/category_api_model.dart';
import 'base_api_service.dart';
import 'dart:developer' as developer;

class CategoryApiService extends BaseApiService {
  CategoryApiService({required super.baseUrl});

  Future<List<Category>> getCategories() async {
    try {
      developer.log('Getting categories');
      final response = await dio.get('$baseUrl/categories');
      return (response.data as List)
          .map((category) => Category.fromJson(category))
          .toList();
    } catch (e) {
      developer.log('getCategories error: $e');
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<Category> createCategory(CategoryUpdateRequest category) async {
    try {
      final response = await dio.post(
        '$baseUrl/categories',
        data: category.toJson(),
      );
      return Category.fromJson(response.data);
    } catch (e) {
      developer.log('createCategory error: $e');
      throw Exception('Failed to create category: $e');
    }
  }

  Future<Category> updateCategory(
      String id, CategoryUpdateRequest category) async {
    try {
      final response = await dio.put(
        '$baseUrl/categories/$id',
        data: category.toJson(),
      );
      return Category.fromJson(response.data);
    } catch (e) {
      developer.log('updateCategory error: $e');
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await dio.delete('$baseUrl/categories/$id');
    } catch (e) {
      developer.log('deleteCategory error: $e');
      throw Exception('Failed to delete category: $e');
    }
  }
}
