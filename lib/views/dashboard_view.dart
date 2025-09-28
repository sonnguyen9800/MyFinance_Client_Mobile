import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_typography.dart';
import '../controllers/navigation_controller.dart';
import 'about_view.dart';
import 'categories/category_view.dart';
import 'chart_view.dart';
import 'expense/expenses_view.dart';
import 'expense/monthly_view.dart';
import 'home_view.dart';
import 'profile_view.dart';
import 'settings_view.dart';
import 'widget/app_shell.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({
    super.key,
    required this.initialSection,
    this.initialCategoryId,
  });

  final NavigationSection initialSection;
  final String? initialCategoryId;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final NavigationController _navigationController;
  late final List<NavigationSection> _sectionOrder;
  late final Map<NavigationSection, Widget> _sectionBodies;

  @override
  void initState() {
    super.initState();
    _navigationController = Get.find<NavigationController>();
    _sectionOrder = NavigationController.sections
        .map((data) => data.section)
        .toList(growable: false);
    _sectionBodies = {
      NavigationSection.home: HomeSection(),
      NavigationSection.expenses: ExpensesSection(),
      NavigationSection.monthly: MonthlySection(),
      NavigationSection.chart: const ChartSection(),
      NavigationSection.categories: CategorySection(),
      NavigationSection.profile: ProfileSection(),
      NavigationSection.settings: SettingsSection(),
      NavigationSection.about: const AboutSection(),
    };

    _navigationController.setSection(
      widget.initialSection,
      categoryId: widget.initialCategoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final section = _navigationController.currentSection.value;
      return AppShell(
        appBarBuilder: (isPermanentNavigation) =>
            _buildAppBar(context, section, isPermanentNavigation),
        body: IndexedStack(
          index: _sectionOrder.indexOf(section),
          children: _sectionOrder
              .map((section) => _sectionBodies[section]!)
              .toList(growable: false),
        ),
        floatingActionButton: _buildFloatingActionButton(section),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    NavigationSection section,
    bool isPermanentNavigation,
  ) {
    switch (section) {
      case NavigationSection.home:
        return AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          automaticallyImplyLeading: !isPermanentNavigation,
          title: Text(
            'MyFinance',
            style: AppTypography.textTheme.headlineMedium!
                .copyWith(color: AppColors.primaryDark),
          ),
        );
      case NavigationSection.expenses:
        return ExpensesSection.appBar(context, isPermanentNavigation);
      case NavigationSection.monthly:
        return MonthlySection.appBar(context, isPermanentNavigation);
      case NavigationSection.chart:
        return ChartSection.appBar(context, isPermanentNavigation);
      case NavigationSection.categories:
        return CategorySection.appBar(context, isPermanentNavigation);
      case NavigationSection.profile:
        return AppBar(
          automaticallyImplyLeading: !isPermanentNavigation,
          title: const Text('Profile'),
        );
      case NavigationSection.settings:
        return AppBar(
          automaticallyImplyLeading: !isPermanentNavigation,
          title: const Text('Settings'),
        );
      case NavigationSection.about:
        return AboutSection.appBar(context, isPermanentNavigation);
    }
  }

  Widget? _buildFloatingActionButton(NavigationSection section) {
    switch (section) {
      case NavigationSection.home:
        return HomeSection.buildFloatingActionButton();
      case NavigationSection.expenses:
        return ExpensesSection.buildFloatingActionButton();
      default:
        return null;
    }
  }
}
