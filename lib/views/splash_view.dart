import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SplashView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    authController.checkAuthStatus();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your app logo here
            const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'MyFinance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => authController.isLoading.value
                ? const CircularProgressIndicator()
                : const SizedBox()),
          ],
        ),
      ),
    );
  }
}
