import 'package:flutter/material.dart';

import '../../../themes/app_colors.dart';
import '../../../utils/responsive_layout.dart';
import 'support_footer.dart';

/// Web-only global footer: support links (intelligence lives on Home).
class WebBottomSection extends StatelessWidget {
  const WebBottomSection({
    super.key,
    required this.currentPath,
  });

  final String currentPath;

  bool get _isLibraryReader => currentPath.startsWith('/library/read/');

  @override
  Widget build(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);

    // Maximize reading area on phones — no site footer in the book reader.
    if (compact && _isLibraryReader) {
      return const SizedBox.shrink();
    }

    return Material(
      color: AppColors.navyDark,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12,
            compact ? 4 : 12,
            12,
            0,
          ),
          child: SupportFooter(minimized: compact),
        ),
      ),
    );
  }
}