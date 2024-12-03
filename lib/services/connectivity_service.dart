import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'dart:developer' as developer;

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final AuthController _authController = Get.find<AuthController>();
  RxBool isOnline = true.obs;

  Future<void> init() async {
    // Check initial connection status
    List<ConnectivityResult> results;

    try {
      results = await _connectivity.checkConnectivity();
      _handleConnectivityResult(results);
    } catch (e) {
      developer.log('Connectivity check failed: $e');
    }
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) =>
            _handleConnectivityResult(results));
  }

  void _handleConnectivityResult(List<ConnectivityResult> results) {
    bool wasOnline = isOnline.value;

    for (var connectivity in results) {
      if (connectivity == ConnectivityResult.wifi ||
          connectivity == ConnectivityResult.mobile ||
          connectivity == ConnectivityResult.ethernet) {
        isOnline.value = true;
        return;
      }
      if (connectivity == ConnectivityResult.none) {
        isOnline.value = false;
      }
    }

    if (wasOnline && !isOnline.value) {
      // Only show message and redirect if we transitioned from online to offline
      Get.snackbar(
        'No Internet Connection',
        'Please check your internet connection and try again.',
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      _authController.handleOffline();
    }
  }
}
