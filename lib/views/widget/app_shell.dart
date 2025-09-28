import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'app_navigation_drawer.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.body,
    this.appBarBuilder,
    this.floatingActionButton,
  });

  final Widget body;
  final PreferredSizeWidget? Function(bool isPermanentNavigation)?
      appBarBuilder;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isPermanentNavigation = kIsWeb;
        final navigation = AppNavigationDrawer(
          closeOnNavigate: !isPermanentNavigation,
        );

        final scaffold = Scaffold(
          appBar: appBarBuilder?.call(isPermanentNavigation),
          drawer: isPermanentNavigation ? null : Drawer(child: navigation),
          body: isPermanentNavigation
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: SafeArea(child: navigation),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: SafeArea(child: body)),
                  ],
                )
              : SafeArea(child: body),
          floatingActionButton: floatingActionButton,
        );

        return scaffold;
      },
    );
  }
}
