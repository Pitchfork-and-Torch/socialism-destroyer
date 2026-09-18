import 'package:flutter/material.dart';

/// Breakpoints aligned with Material adaptive layout guidance.
enum AppBreakpoint { compact, medium, expanded }

abstract final class ResponsiveLayout {
  static const double mediumMin = 600;
  static const double expandedMin = 1200;
  static const double maxContentWidth = 1400;

  static AppBreakpoint breakpointOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= expandedMin) return AppBreakpoint.expanded;
    if (width >= mediumMin) return AppBreakpoint.medium;
    return AppBreakpoint.compact;
  }

  static bool isCompact(BuildContext context) =>
      breakpointOf(context) == AppBreakpoint.compact;

  static bool isTablet(BuildContext context) =>
      breakpointOf(context) == AppBreakpoint.medium;

  static bool isDesktop(BuildContext context) =>
      breakpointOf(context) == AppBreakpoint.expanded;

  static bool useSplitPane(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mediumMin;

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width.clamp(0, maxContentWidth);
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return switch (breakpointOf(context)) {
      AppBreakpoint.compact => const EdgeInsets.fromLTRB(12, 12, 12, 8),
      AppBreakpoint.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      AppBreakpoint.expanded => const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
    };
  }

  /// Slightly shorter app bars on phones.
  static double appBarHeight(BuildContext context) =>
      isCompact(context) ? 52 : kToolbarHeight;

  static int gridCrossAxisCount(BuildContext context) => switch (breakpointOf(context)) {
        AppBreakpoint.compact => 1,
        AppBreakpoint.medium => 2,
        AppBreakpoint.expanded => 3,
      };
}

/// Centers content with max width on large screens.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({super.key, required this.child, this.alignment});

  final Widget child;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment ?? Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ResponsiveLayout.maxContentWidth),
        child: child,
      ),
    );
  }
}

/// Adaptive two-pane shell: sidebar + main on tablet/desktop.
class AdaptiveSplitLayout extends StatelessWidget {
  const AdaptiveSplitLayout({
    super.key,
    required this.sidebar,
    required this.body,
    this.sidebarWidth = 320,
  });

  final Widget sidebar;
  final Widget body;
  final double sidebarWidth;

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveLayout.useSplitPane(context)) {
      return body;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: sidebarWidth, child: sidebar),
        const VerticalDivider(width: 1),
        Expanded(child: body),
      ],
    );
  }
}