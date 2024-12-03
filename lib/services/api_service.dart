import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/expense_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post('$baseUrl/login',
          data: {'email': email, 'password': password});
      await _storage.write(key: 'token', value: response.data['token']);
      return User.fromJson(response.data['user']);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<User> signup(String name, String email, String password) async {
    try {
      final response = await _dio.post('$baseUrl/signup',
          data: {'name': name, 'email': email, 'password': password});
      await _storage.write(key: 'token', value: response.data['token']);
      return User.fromJson(response.data['user']);
    } catch (e) {
      throw Exception('Failed to signup $e');
    }
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final response = await _dio.get('$baseUrl/expenses');
      return (response.data as List)
          .map((json) => Expense.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses');
    }
  }

  Future<Expense> createExpense(Expense expense) async {
    try {
      final response = await _dio.post('$baseUrl/expenses',
          data: expense.toJson());
      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create expense');
    }
  }

  Future<Expense> updateExpense(String id, Expense expense) async {
    try {
      final response = await _dio.put('$baseUrl/expenses/$id',
          data: expense.toJson());
      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update expense');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _dio.delete('$baseUrl/expenses/$id');
    } catch (e) {
      throw Exception('Failed to delete expense');
    }
  }
}
