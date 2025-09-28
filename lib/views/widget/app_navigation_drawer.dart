import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../controllers/auth_controller.dart';

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({super.key, this.closeOnNavigate = false});

  final bool closeOnNavigate;

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  final AuthController _authController = Get.find<AuthController>();
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _packageInfo = info);
      }
    } catch (_) {
      // Package info is optional; ignore failures (e.g., on web).
    }
  }

  void _navigate(String route) {
    if (widget.closeOnNavigate) {
      Get.back();
    }

    if (Get.currentRoute != route) {
      Get.offNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final versionLabel = _packageInfo?.version ?? '';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Row(
            children: [
              Text(
                'MyFinance',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SvgPicture.asset('assets/logo.svg'),
              ),
            ],
          ),
        ),
        _buildNavItem(
          icon: Icons.home,
          label: 'Home',
          route: '/home',
        ),
        _buildNavItem(
          icon: Icons.list,
          label: 'Expenses',
          route: '/expenses',
        ),
        _buildNavItem(
          icon: Icons.calendar_month,
          label: 'Monthly',
          route: '/monthly',
        ),
        // _buildNavItem(
        //   icon: Icons.pie_chart,
        //   label: 'Charts',
        //   route: '/chart',
        // ),
        _buildNavItem(
          icon: Icons.category,
          label: 'Categories',
          route: '/categories',
        ),
        // _buildNavItem(
        //   icon: Icons.person,
        //   label: 'Profile',
        //   route: '/profile',
        // ),
        // _buildNavItem(
        //   icon: Icons.settings,
        //   label: 'Settings',
        //   route: '/settings',
        // ),
        _buildNavItem(
          icon: Icons.info,
          label: 'About',
          route: '/about',
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.close),
          title: Text(
            'Logout',
            style: AppTypography.textTheme.titleMedium,
          ),
          onTap: () {
            if (widget.closeOnNavigate) {
              Get.back();
            }
            _authController.logout();
          },
        ),
        if (versionLabel.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(
              'Version: $versionLabel',
              style: AppTypography.textTheme.titleMedium,
            ),
          ),
      ],
    );
  }

  ListTile _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
  }) {
    final bool isSelected = Get.currentRoute == route;
    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: AppTypography.textTheme.titleMedium,
      ),
      selected: isSelected,
      selectedTileColor: AppColors.accent.withOpacity(0.2),
      onTap: () => _navigate(route),
    );
  }
}
