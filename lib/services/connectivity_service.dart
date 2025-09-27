import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final AuthController _authController = Get.find<AuthController>();
  RxBool isOnline = true.obs;

  Future<void> init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityResult(results);
    } catch (e) {
      developer.log('Connectivity check failed: $e');
    }

    _connectivity.onConnectivityChanged.listen(_handleConnectivityResult);
  }

  void _handleConnectivityResult(List<ConnectivityResult> results) {
    final wasOnline = isOnline.value;

    for (final connectivity in results) {
      if (connectivity == ConnectivityResult.wifi ||
          connectivity == ConnectivityResult.mobile ||
          connectivity == ConnectivityResult.ethernet ||
          connectivity == ConnectivityResult.other) {
        isOnline.value = true;
        return;
      }
      if (connectivity == ConnectivityResult.none) {
        isOnline.value = false;
      }
    }

    if (wasOnline && !isOnline.value) {
      Get.snackbar(
        'No Internet Connection',
        'Please check your internet connection and try again.',
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      if (!kIsWeb) {
        _authController.handleOffline();
      }
    }
  }
}
