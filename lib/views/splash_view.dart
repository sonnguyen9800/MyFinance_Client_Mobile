import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SplashView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: FutureBuilder<void>(
        future:
            authController.checkAuthStatus(), // Ensure this returns a Future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            Future.delayed(const Duration(seconds: 5), () {
              Get.offAllNamed('/login'); // Navigate to home after loading
            });
          } else {
            // After checking auth status, navigate to the appropriate screen
            Future.delayed(const Duration(seconds: 5), () {
              Get.offAllNamed('/home'); // Navigate to home after loading
            });
          }

          return Center(
            child: SvgPicture.asset(
              'assets/logo.svg',
              width: 120,
              height: 120,
            ),
          );
        },
      ),
    );
  }
}
