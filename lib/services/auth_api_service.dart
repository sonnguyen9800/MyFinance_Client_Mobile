import 'package:dio/dio.dart';
import '../models/api/auth_response.dart';
import '../models/user/user_model.dart';
import 'base_api_service.dart';
import 'dart:developer' as developer;

class AuthApiService extends BaseApiService {
  Future<AuthResponse> login(String email, String password) async {
    try {
      developer.log('Attempting login');
      final response = await dio
          .post('$baseUrl/login', data: {'email': email, 'password': password});

      final String token = response.data['token'];
      final User user = User.fromJson(response.data['user']);

      developer.log('Login successful, token: $token');
      await storage.write(key: 'token', value: token);

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
      await storage.write(key: 'token', value: token);

      return AuthResponse(token: token, user: user);
    } catch (e) {
      developer.log('Signup error: $e');
      throw Exception('Failed to signup: $e');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      developer.log('Getting current user');
      final response = await dio.post('$baseUrl/user');
      return User.fromJson(response.data);
    } catch (e) {
      developer.log('getCurrentUser error: $e');
      throw Exception('Failed to get current user: $e');
    }
  }
}
