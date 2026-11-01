import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';
import '../../shared/router/app_router.dart';
import 'support_footer.dart';

/// Slim bottom chrome for phones — icon-only tabs plus optional support strip.
class CompactBottomChrome extends StatelessWidget {
  const CompactBottomChrome({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.includeSupport = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool includeSupport;

  static const _destinations = [
    _NavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
      route: AppRoutes.home,
    ),
    _NavDestination(
      icon: Icons.account_tree_outlined,
      selectedIcon: Icons.account_tree_rounded,
      label: 'Topics',
      route: AppRoutes.tree,
    ),
    _NavDestination(
      icon: Icons.bolt_outlined,
      selectedIcon: Icons.bolt_rounded,
      label: 'Crusher',
      route: AppRoutes.crusher,
    ),
    _NavDestination(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Library',
      route: AppRoutes.library,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navy,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              container: true,
              label: 'Main navigation',
              child: SizedBox(
                height: kIsWeb ? 48 : 52,
                child: Row(
                  children: [
                    for (var i = 0; i < _destinations.length; i++)
                      Expanded(
                        child: _CompactNavItem(
                          destination: _destinations[i],
                          selected: selectedIndex == i,
                          onTap: () => onSelect(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (includeSupport)
              const Divider(height: 1, thickness: 1),
            if (includeSupport) const SupportFooter(minimized: true, embedded: true),
          ],
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
}

class _CompactNavItem extends StatelessWidget {
  const _CompactNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.goldLight : AppColors.textMuted;

    return Tooltip(
      message: destination.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Semantics(
            button: true,
            selected: selected,
            label: destination.label,
            child: SizedBox(
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.gold.withValues(alpha: 0.16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      selected ? destination.selectedIcon : destination.icon,
                      size: 22,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}