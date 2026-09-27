import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../design_system.dart';
import 'sd_card.dart';
import 'sd_section_header.dart';

/// Gold-accented executive summary panel for claim detail screens.
class ExecutiveSummaryBox extends StatelessWidget {
  const ExecutiveSummaryBox({
    super.key,
    required this.summary,
    this.title = 'Executive Summary',
    this.prominent = false,
  });

  final String summary;
  final String title;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;

    return SdCard(
      accentColor: sd.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SdSectionHeader(
            title: title,
            accentColor: sd.accentGold,
            icon: Icons.summarize_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: sd.isDark
                  ? AppColors.navyLight.withValues(alpha: 0.5)
                  : AppColors.offWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: sd.accentGold.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              summary,
              style: prominent
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.55,
                        fontWeight: FontWeight.w700,
                        color: sd.textHigh,
                      )
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.65,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}