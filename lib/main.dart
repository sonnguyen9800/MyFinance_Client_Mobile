import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/expense_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';
import 'services/storage/app_storage.dart';
import 'controllers/navigation_controller.dart';
import 'views/dashboard_view.dart';
import 'views/login_view.dart';
import 'views/signup_view.dart';
import 'views/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storage = await createAppStorage(sharedPreferences: prefs);

  Get.put<SharedPreferences>(prefs, permanent: true);
  Get.put<AppStorage>(storage, permanent: true);

  final apiService = Get.put(ApiService(storage), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(apiService, storage), permanent: true);
  Get.put(ExpenseController(apiService), permanent: true);
  Get.put(CategoryController(apiService), permanent: true);
  Get.put(NavigationController(), permanent: true);

  final connectivityService = Get.put(ConnectivityService(), permanent: true);
  await connectivityService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyFinance',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeController.to.themeMode,
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
          page: () => DashboardView(
            initialSection: NavigationSection.home,
          ),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/expenses',
          page: () => DashboardView(
            initialSection: NavigationSection.expenses,
            initialCategoryId: Get.parameters['categoryId'],
          ),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/monthly',
          page: () => DashboardView(
            initialSection: NavigationSection.monthly,
          ),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/chart',
          page: () => DashboardView(
            initialSection: NavigationSection.chart,
          ),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/categories',
          page: () => DashboardView(
            initialSection: NavigationSection.categories,
          ),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/profile',
          page: () => DashboardView(
            initialSection: NavigationSection.profile,
          ),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/settings',
          page: () => DashboardView(
            initialSection: NavigationSection.settings,
          ),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/about',
          page: () => DashboardView(
            initialSection: NavigationSection.about,
          ),
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
    return authController.user.value == null
        ? const RouteSettings(name: '/login')
        : null;
  }
}
