import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../design_system.dart';
import 'sd_card.dart';
import 'sd_section_header.dart';

/// Prominent counter-argument panel — shown after the steelmanned opponent claim.
class CounterArgumentHero extends StatelessWidget {
  const CounterArgumentHero({
    super.key,
    required this.counterText,
    this.headline,
    this.subtitle = 'Counter-Argument',
  });

  final String counterText;
  final String? headline;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    return SdCard(
      accentColor: sd.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SdSectionHeader(
            title: subtitle,
            accentColor: sd.accentGold,
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (headline != null && headline!.trim().isNotEmpty) ...[
            Text(
              headline!,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: sd.accentGold,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  sd.accentGold.withValues(alpha: 0.14),
                  AppColors.navyLight.withValues(alpha: sd.isDark ? 0.55 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: sd.accentGold.withValues(alpha: 0.45),
                width: 1.5,
              ),
            ),
            child: Text(
              counterText,
              style: theme.textTheme.titleMedium?.copyWith(
                height: 1.55,
                fontWeight: FontWeight.w600,
                color: sd.textHigh,
              ),
            ),
          ),
        ],
      ),
    );
  }
}