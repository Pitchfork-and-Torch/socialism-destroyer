import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../themes/themes.dart';
import '../../../utils/responsive_layout.dart';
import '../../shared/router/app_router.dart';
import 'compact_bottom_chrome.dart';
import 'desktop_shortcuts.dart';

/// Persistent navigation shell for main app tabs.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  final Widget child;
  final String currentPath;

  int get _selectedIndex {
    if (currentPath == AppRoutes.home || currentPath == '/') return 0;
    if (currentPath == AppRoutes.tree) return 1;
    if (currentPath == AppRoutes.crusher) return 2;
    if (currentPath == AppRoutes.library ||
        currentPath.startsWith('${AppRoutes.library}/')) {
      return 3;
    }
    return 0;
  }

  void _onSelect(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.tree);
      case 2:
        context.go(AppRoutes.crusher);
      case 3:
        context.go(AppRoutes.library);
    }
  }

  @override
  Widget build(BuildContext context) {
    final useRail = ResponsiveLayout.isDesktop(context);
    final shell = useRail ? _buildRail(context) : _buildBottomNav(context);

    return DesktopShortcuts(
      currentPath: currentPath,
      child: shell,
    );
  }

  Widget _buildRail(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Semantics(
            container: true,
            label: 'Main navigation',
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => _onSelect(context, i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: context.sd.surfaceBase,
              indicatorColor: context.sd.accentGold.withValues(alpha: 0.2),
              selectedIconTheme: IconThemeData(color: context.sd.accentGold),
              selectedLabelTextStyle: TextStyle(color: context.sd.accentGold),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_tree_outlined),
                  selectedIcon: Icon(Icons.account_tree_rounded),
                  label: Text('Topics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bolt_outlined),
                  selectedIcon: Icon(Icons.bolt_rounded),
                  label: Text('Crusher'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: Text('Library'),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  bool _hideBottomChrome(BuildContext context, String path) =>
      ResponsiveLayout.isCompact(context) &&
      kIsWeb &&
      path.startsWith('${AppRoutes.library}/read/');

  Widget _buildBottomNav(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);
    final hideChrome = _hideBottomChrome(context, currentPath);

    Widget? bottomBar;
    if (!hideChrome) {
      if (compact) {
        bottomBar = CompactBottomChrome(
          selectedIndex: _selectedIndex,
          onSelect: (i) => _onSelect(context, i),
          includeSupport: kIsWeb,
        );
      } else {
        bottomBar = Semantics(
          container: true,
          label: 'Main navigation',
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => _onSelect(context, i),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_tree_outlined),
                selectedIcon: Icon(Icons.account_tree_rounded),
                label: 'Topics',
              ),
              NavigationDestination(
                icon: Icon(Icons.bolt_outlined),
                selectedIcon: Icon(Icons.bolt_rounded),
                label: 'Crusher',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Library',
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: bottomBar,
    );
  }
}