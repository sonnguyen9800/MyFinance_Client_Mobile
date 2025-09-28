import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

import '../models/user/user_model.dart';
import '../services/api_service.dart';
import '../services/storage/app_storage.dart';

class AuthController extends GetxController {
  AuthController(this._apiService, this._storage) {
    developer.log('AuthController constructor called');
  }

  final ApiService _apiService;
  final AppStorage _storage;

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString serverAddress = ''.obs;

  @override
  void onInit() {
    super.onInit();
    developer.log('AuthController initialized');
  }

  void handleOffline() {
    developer.log('Handling offline state');
    user.value = null;
    Get.offAllNamed('/login');
  }

  Future<void> checkAuthStatus() async {
    developer.log('Checking auth status...');
    isLoading.value = true;

    try {
      final token = await _storage.read('token');
      final storedServerAddress = await _storage.read('server_address');
      if (storedServerAddress != null && storedServerAddress.isNotEmpty) {
        if (!kIsWeb) {
          final canConnect = await _apiService.ping(storedServerAddress);
          if (!canConnect) {
            Get.snackbar('Error', "Can't connect to server");
            return;
          }
        }
        serverAddress.value = storedServerAddress;
        _apiService.updateBaseUrl(serverAddress.value);
      }

      if (token != null && token.isNotEmpty) {
        try {
          final currentUser = await _apiService.getCurrentUser();
          developer.log('Current user retrieved successfully');
          user.value = currentUser;
        } catch (e) {
          developer.log('Failed to get current user: $e');
          await _storage.delete('token');
        }
      } else {
        developer.log('No valid token found, redirecting to login');
      }
    } catch (e) {
      developer.log('Error in checkAuthStatus: $e');
      await _storage.delete('token');
    } finally {
      isLoading.value = false;
      isInitialized.value = true;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      developer.log('Attempting login...');

      final authResponse = await _apiService
          .login(email, password)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out');
      });

      if (authResponse.token.isEmpty) {
        throw Exception('Received empty token from server');
      }
      await _storage.write('token', authResponse.token);

      final storedToken = await _storage.read('token');
      developer.log('Token stored successfully: ${storedToken != null}');

      user.value = authResponse.user;
      Get.offAllNamed('/home');
    } catch (e) {
      developer.log('Login error: $e');
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      isLoading.value = true;
      developer.log('Attempting signup...');

      final authResponse = await _apiService.signup(name, email, password);

      await _storage.write('token', authResponse.token);

      final storedToken = await _storage.read('token');
      developer.log('Token stored successfully: ${storedToken != null}');

      user.value = authResponse.user;
      Get.offAllNamed('/home');
    } catch (e) {
      developer.log('Signup error: $e');
      Get.snackbar(
        'Error',
        'Signup failed: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      developer.log('Logging out...');
      await _storage.deleteAll(['token', 'server_address']);

      final storedToken = await _storage.read('token');
      developer.log('Token deleted successfully: ${storedToken == null}');
      final storedAddress = await _storage.read('server_address');
      developer.log('Address deleted successfully: ${storedAddress == null}');

      user.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      developer.log('Logout error: $e');
      Get.snackbar(
        'Error',
        'Logout failed: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> setServerAddress(String address) async {
    serverAddress.value = address;
    _apiService.updateBaseUrl(address);
    await _storage.write('server_address', address);
  }

  void toggleServerSelection() {}

  Future<bool> connect(String address) async {
    final canConnect = await _apiService.ping(address);
    if (canConnect) {
      await setServerAddress(address);
      return true;
    } else {
      Get.snackbar('Error', "Can't connect to server");
      return false;
    }


  }

        Future<bool> ping(String address) async {
    final canConnect = await _apiService.ping(address);
    if (canConnect) {
      Get.snackbar("Success","Server is online");
      return true;
    } else {
      Get.snackbar('Error', "Can't connect to server");
      return false;
    }
  }
}
