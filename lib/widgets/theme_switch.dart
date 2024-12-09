import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = ThemeController.to;
      final isDark = controller.isDarkMode;

      return ListTile(
        leading: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          'Dark Mode',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Switch(
          value: isDark,
          onChanged: (value) => controller.toggleTheme(),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      );
    });
  }
}
