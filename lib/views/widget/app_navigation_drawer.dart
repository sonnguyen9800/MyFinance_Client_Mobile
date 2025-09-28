import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/navigation_controller.dart';

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({super.key, this.closeOnNavigate = false});

  final bool closeOnNavigate;

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  final AuthController _authController = Get.find<AuthController>();
  final NavigationController _navigationController =
      Get.find<NavigationController>();
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
      // Package info retrieval can fail on some platforms (e.g., web). Ignore.
    }
  }

  void _onSectionTap(NavigationSection section) {
    if (widget.closeOnNavigate && Get.isOverlaysOpen) {
      Get.back();
    }
    _navigationController.setSection(section);
  }

  @override
  Widget build(BuildContext context) {
    final versionLabel = _packageInfo?.version ?? '';

    return Obx(() {
      final currentSection = _navigationController.currentSection.value;
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
                Expanded(child: SvgPicture.asset('assets/logo.svg')),
              ],
            ),
          ),
          for (final data in NavigationController.sections)
            _buildNavItem(
              data: data,
              selected: currentSection == data.section,
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.close),
            title: Text(
              'Logout',
              style: AppTypography.textTheme.titleMedium,
            ),
            onTap: () {
              if (widget.closeOnNavigate && Get.isOverlaysOpen) {
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
    });
  }

  ListTile _buildNavItem({
    required NavigationSectionData data,
    required bool selected,
  }) {
    return ListTile(
      leading: Icon(data.icon),
      title: Text(
        data.label,
        style: AppTypography.textTheme.titleMedium,
      ),
      selected: selected,
      selectedTileColor: AppColors.accent.withOpacity(0.2),
      onTap: () => _onSectionTap(data.section),
    );
  }
}
