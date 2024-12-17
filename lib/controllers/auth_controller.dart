import 'package:get/get.dart';
import '../models/user/user_model.dart';
import '../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  // Initialize storage with Android-specific encryption
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Ensure we're using the most secure settings
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      sharedPreferencesName: 'myfinance_secure_prefs',
    ),
  );

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString serverAddress = ''.obs;
  @override
  void onInit() {
    super.onInit();
    developer.log('AuthController initialized');
    // Remove automatic checkAuthStatus call since it will be triggered from splash screen
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
      final token = await _storage.read(key: 'token');
      final storedServerAddress = await _storage.read(key: 'server_address');
      if (storedServerAddress != null && storedServerAddress.isNotEmpty) {
        final canConnect = await _apiService.ping(storedServerAddress);
        if (!canConnect) {
          Get.snackbar("Error", "Can't connect to server");
          return;
        }
        serverAddress.value = storedServerAddress;
        _apiService.updateBaseUrl(serverAddress.value);
      }

      if (token != null && token.isNotEmpty) {
        try {
          final User currentUser = await _apiService.getCurrentUser();
          developer.log('Current user retrieved successfully');
          user.value = currentUser;
        } catch (e) {
          developer.log('Failed to get current user: $e');
          await _storage.delete(key: 'token');
        }
      } else {
        developer.log('No valid token found, redirecting to login');
      }
    } catch (e) {
      developer.log('Error in checkAuthStatus: $e');
      await _storage.delete(key: 'token');
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

      // Verify token exists
      if (authResponse.token.isEmpty) {
        throw Exception('Received empty token from server');
      }
      // Store token
      await _storage.write(key: 'token', value: authResponse.token);

      // Verify token was stored
      final storedToken = await _storage.read(key: 'token');
      developer.log('Token stored successfully: ${storedToken != null}');

      user.value = authResponse.user;
      Get.offAllNamed('/home');
    } catch (e) {
      developer.log('Login error: $e');
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        duration: Duration(seconds: 3),
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

      // Store token
      await _storage.write(key: 'token', value: authResponse.token);

      // Verify token was stored
      final storedToken = await _storage.read(key: 'token');
      developer.log('Token stored successfully: ${storedToken != null}');

      user.value = authResponse.user;
      Get.offAllNamed('/home');
    } catch (e) {
      developer.log('Signup error: $e');
      Get.snackbar(
        'Error',
        'Signup failed: ${e.toString()}',
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      developer.log('Logging out...');
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'server_address');

      // Verify token was deleted
      final storedToken = await _storage.read(key: 'token');
      developer.log('Token deleted successfully: ${storedToken == null}');
      // Verify address was deleted
      final storedAddress = await _storage.read(key: 'server_address');
      developer.log('Address deleted successfully: ${storedAddress == null}');

      user.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      developer.log('Logout error: $e');
      Get.snackbar(
        'Error',
        'Logout failed: ${e.toString()}',
        duration: Duration(seconds: 3),
      );
    }
  }

  setServerAddress(String text) {
    _apiService.updateBaseUrl(serverAddress.value);
  }

  void toggleServerSelection() {}

  Future<bool> connect(String address) async {
    bool canConnect = await _apiService.ping(address);
    if (canConnect) {
      serverAddress.value = address;
      _apiService.updateBaseUrl(serverAddress.value);
      await _storage.write(key: 'server_address', value: address);

      return true;
    } else {
      Get.snackbar("Error", "Can't connect to server");
      return false;
    }
  }
}
