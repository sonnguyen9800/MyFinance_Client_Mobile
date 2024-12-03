import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/expense_model.dart';
import '../models/auth_response.dart';
import 'dart:developer' as developer;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        developer.log('Token in interceptor: $token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        developer.log('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  Future<User> getCurrentUser() async {
    try {
      developer.log('Getting current user');
      final response = await _dio.post('$baseUrl/user');
      return User.fromJson(response.data);
    } catch (e) {
      developer.log('getCurrentUser error: $e');
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      developer.log('Attempting login');
      final response = await _dio
          .post('$baseUrl/login', data: {'email': email, 'password': password});

      final String token = response.data['token'];
      final User user = User.fromJson(response.data['user']);

      developer.log('Login successful, token: $token');
      await _storage.write(key: 'token', value: token);

      return AuthResponse(token: token, user: user);
    } catch (e) {
      developer.log('Login error: $e');
      throw Exception('Failed to login: $e');
    }
  }

  Future<AuthResponse> signup(
      String name, String email, String password) async {
    try {
      developer.log('Attempting signup');
      final response = await _dio.post('$baseUrl/signup',
          data: {'name': name, 'email': email, 'password': password});

      final String token = response.data['token'];
      final User user = User.fromJson(response.data['user']);

      developer.log('Signup successful, token: $token');
      await _storage.write(key: 'token', value: token);

      return AuthResponse(token: token, user: user);
    } catch (e) {
      developer.log('Signup error: $e');
      throw Exception('Failed to signup: $e');
    }
  }

  Future<List<Expense>> getExpenses() async {
    try {
      developer.log('Getting expenses');
      final response = await _dio.get('$baseUrl/expenses');
      return (response.data as List)
          .map((json) => Expense.fromJson(json))
          .toList();
    } catch (e) {
      developer.log('getExpenses error: $e');
      throw Exception('Failed to get expenses');
    }
  }

  Future<Expense> createExpense(Expense expense) async {
    try {
      developer.log('Creating expense');
      final response =
          await _dio.post('$baseUrl/expenses', data: expense.toJson());
      return Expense.fromJson(response.data);
    } catch (e) {
      developer.log('createExpense error: $e');
      throw Exception('Failed to create expense $e');
    }
  }

  Future<Expense> updateExpense(String id, Expense expense) async {
    try {
      developer.log('Updating expense');
      final response =
          await _dio.put('$baseUrl/expenses/$id', data: expense.toJson());
      return Expense.fromJson(response.data);
    } catch (e) {
      developer.log('updateExpense error: $e');
      throw Exception('Failed to update expense');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      developer.log('Deleting expense');
      await _dio.delete('$baseUrl/expenses/$id');
    } catch (e) {
      developer.log('deleteExpense error: $e');
      throw Exception('Failed to delete expense');
    }
  }
}
