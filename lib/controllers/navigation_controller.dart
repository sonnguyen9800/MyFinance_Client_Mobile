import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum NavigationSection {
  home,
  expenses,
  monthly,
  chart,
  categories,
  profile,
  settings,
  about,
}

class NavigationSectionData {
  const NavigationSectionData({
    required this.section,
    required this.label,
    required this.icon,
  });

  final NavigationSection section;
  final String label;
  final IconData icon;
}

class NavigationController extends GetxController {
  NavigationController();

  final Rx<NavigationSection> currentSection = NavigationSection.home.obs;
  final RxnString selectedCategoryId = RxnString();

  static const List<NavigationSectionData> sections = [
    NavigationSectionData(
      section: NavigationSection.home,
      label: 'Home',
      icon: Icons.home,
    ),
    NavigationSectionData(
      section: NavigationSection.expenses,
      label: 'Expenses',
      icon: Icons.list,
    ),
    NavigationSectionData(
      section: NavigationSection.monthly,
      label: 'Monthly',
      icon: Icons.calendar_month,
    ),
    // NavigationSectionData(
    //   section: NavigationSection.chart,
    //   label: 'Charts',
    //   icon: Icons.pie_chart,
    // ),
    NavigationSectionData(
      section: NavigationSection.categories,
      label: 'Categories',
      icon: Icons.category,
    ),
    // NavigationSectionData(
    //   section: NavigationSection.profile,
    //   label: 'Profile',
    //   icon: Icons.person,
    // ),
    // NavigationSectionData(
    //   section: NavigationSection.settings,
    //   label: 'Settings',
    //   icon: Icons.settings,
    // ),
    NavigationSectionData(
      section: NavigationSection.about,
      label: 'About',
      icon: Icons.info,
    ),
  ];

  void setSection(NavigationSection section, {String? categoryId}) {
    if (currentSection.value == section) {
      currentSection.refresh();
    } else {
      currentSection.value = section;
    }
    selectedCategoryId.value = categoryId;
  }

  NavigationSection sectionFromRoute(String route) {
    switch (route) {
      case '/expenses':
        return NavigationSection.expenses;
      case '/monthly':
        return NavigationSection.monthly;
      case '/chart':
        return NavigationSection.chart;
      case '/categories':
        return NavigationSection.categories;
      case '/profile':
        return NavigationSection.profile;
      case '/settings':
        return NavigationSection.settings;
      case '/about':
        return NavigationSection.about;
      case '/home':
      default:
        return NavigationSection.home;
    }
  }
}
