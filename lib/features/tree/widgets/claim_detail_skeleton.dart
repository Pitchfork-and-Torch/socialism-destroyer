import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../themes/themes.dart';
import '../../../utils/responsive_layout.dart';

/// Shimmer loading placeholder for claim detail screens.
class ClaimDetailSkeleton extends StatelessWidget {
  const ClaimDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final base = sd.surfaceRaised;
    final highlight = sd.borderSubtle.withValues(alpha: 0.6);

    Widget block({double height = 16, double width = double.infinity}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView(
        padding: ResponsiveLayout.pagePadding(context),
        children: [
          block(height: 28, width: 280),
          const SizedBox(height: AppSpacing.md),
          block(height: 120),
          const SizedBox(height: AppSpacing.lg),
          block(height: 20, width: 160),
          const SizedBox(height: AppSpacing.sm),
          block(height: 80),
          const SizedBox(height: AppSpacing.lg),
          block(height: 20, width: 140),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < 4; i++) ...[
            block(height: 14),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.lg),
          block(height: 180),
        ],
      ),
    );
  }
}