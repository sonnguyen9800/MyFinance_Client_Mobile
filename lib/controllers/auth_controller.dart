import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';
import '../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        isLoading.value = true;
        user.value = await _apiService.getCurrentUser();
        Get.offAllNamed('/home');
      }
    } catch (e) {
      await _storage.delete(key: 'token');
    } finally {
      isLoading.value = false;
      isInitialized.value = true;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final authResponse = await _apiService
          .login(email, password)
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out');
      });

      user.value = authResponse.user;
      await _storage.write(key: 'token', value: authResponse.token);
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      isLoading.value = true;
      final authResponse = await _apiService.signup(name, email, password);
      user.value = authResponse.user;
      await _storage.write(key: 'token', value: authResponse.token);
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    user.value = null;
    Get.offAllNamed('/login');
  }
}
