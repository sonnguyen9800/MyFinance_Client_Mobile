import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/config/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  late AnimationController _logoController;
  late Animation<double> _logoOpacity;
  late AnimationController _fadeController;
  late Animation<double> _fadeToBlack;
  bool _isRouting = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeToBlack = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Step 1: Fade in the logo
    await _logoController.forward();

    // Step 2: Check auth status
    try {
      await authController.checkAuthStatus();
      _navigateTo('/home');
    } catch (e) {
      _navigateTo('/login');
    }
  }

  void _navigateTo(String route) async {
    if (_isRouting) return; // Prevent multiple routing
    _isRouting = true;

    // Step 3: Fade out the logo and black out the screen
    await _fadeController.forward();

    // Step 4: Perform navigation
    Get.offAllNamed(route);

    // Step 5: Fade in the new page (handled by the next page's animation)
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accent,
      body: Stack(
        children: [
          // Background color (initially blank screen)
          AnimatedBuilder(
            animation: _fadeToBlack,
            builder: (context, child) => Container(
              color: AppColors.accent.withOpacity(_fadeToBlack.value),
            ),
          ),

          // Logo
          Center(
            child: FadeTransition(
              opacity: _logoOpacity,
              child: SvgPicture.asset(
                'assets/logo.svg',
                width: 120,
                height: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
