import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/config/theme/app_colors.dart';
import '../config/theme/app_typography.dart';
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
  late AnimationController _blackoutController;
  late Animation<double> _blackoutOpacity;
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

    _blackoutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _blackoutOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _blackoutController,
        curve: Curves.easeOut,
      ),
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
    _logoController.reverse();
    // Step 3: Fade to black
    await _blackoutController.forward();

    // Step 4: Perform navigation
    Future.delayed(Duration.zero, () {
      Get.offAllNamed(route);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _blackoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accent,
      body: Stack(
        children: [
          // Background color (default is AppColors.accent)
          Container(color: AppColors.accent),

          // Blackout layer to hide the transition
          AnimatedBuilder(
            animation: _blackoutOpacity,
            builder: (context, child) => Container(
              color: Colors.black.withOpacity(_blackoutOpacity.value),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MyFinance',
                      style: AppTypography.textTheme.headlineMedium!.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: SvgPicture.asset(
                        'assets/logo.svg',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Logo
        ],
      ),
    );
  }
}
