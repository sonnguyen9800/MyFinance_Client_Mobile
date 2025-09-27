import 'dart:developer' as developer;

import '../models/api/auth_response.dart';
import '../models/user/user_model.dart';
import 'base_api_service.dart';

class AuthApiService extends BaseApiService {
  AuthApiService(
      {required super.baseUrl, required super.dio, required super.storage});

  Future<AuthResponse> login(String email, String password) async {
    try {
      developer.log('Attempting login');
      final response = await dio
          .post('$baseUrl/login', data: {'email': email, 'password': password});

      final String token = response.data['token'];
      final User user = User.fromJson(response.data['user']);

      developer.log('Login successful, token: $token');
      await storage.write('token', token);

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
      final response = await dio.post('$baseUrl/signup',
          data: {'name': name, 'email': email, 'password': password});

      final String token = response.data['token'];
      final User user = User.fromJson(response.data['user']);

      developer.log('Signup successful, token: $token');
      await storage.write('token', token);

      return AuthResponse(token: token, user: user);
    } catch (e) {
      developer.log('Signup error: $e');
      throw Exception('Failed to signup: $e');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      developer.log('Interceptors: ${dio.interceptors}');
      final token = await storage.read('token');
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      developer.log('Getting current user');
      final response = await dio.post('$baseUrl/user');
      return User.fromJson(response.data);
    } catch (e) {
      developer.log('getCurrentUser error: $e');
      throw Exception('Failed to get current user: $e');
    }
  }
}
