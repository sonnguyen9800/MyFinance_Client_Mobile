import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/auth_controller.dart';

class SplashView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    authController.checkAuthStatus();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/logo.svg',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            Text(
              'MyFinance',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 32),
            Obx(() {
              if (!authController.isLoading.value) {
                Future.delayed(const Duration(milliseconds: 5000), () {
                  Get.offAllNamed('/home');
                });
              }
              return SizedBox(
                width: 48,
                height: 48,
                child: authController.isLoading.value
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        strokeWidth: 3,
                      )
                    : const SizedBox(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
