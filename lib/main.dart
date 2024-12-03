import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/auth_controller.dart';
import 'controllers/expense_controller.dart';
import 'views/login_view.dart';
import 'views/signup_view.dart';
import 'views/home_view.dart';
import 'views/expenses_view.dart';
import 'views/chart_view.dart';
import 'views/profile_view.dart';
import 'views/settings_view.dart';
import 'views/about_view.dart';
import 'views/splash_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final authController = Get.put(AuthController());
  final expenseController = Get.put(ExpenseController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyFinance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashView()),
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/signup', page: () => SignupView()),
        GetPage(
          name: '/home',
          page: () => HomeView(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/expenses',
          page: () => ExpensesView(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/chart',
          page: () => const ChartView(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/profile',
          page: () => ProfileView(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/settings',
          page: () => SettingsView(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/about',
          page: () => const AboutView(),
          middlewares: [AuthMiddleware()],
        ),
      ],
    );
  }
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    return authController.user.value == null ? const RouteSettings(name: '/login') : null;
  }
}
