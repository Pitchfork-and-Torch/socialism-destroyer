import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../themes/app_colors.dart';

class OnboardingFeatureCard extends StatelessWidget {
  const OnboardingFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.delay = Duration.zero,
  });

  final IconData icon;
  final String title;
  final String description;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
              ),
              child: Icon(icon, color: AppColors.gold, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 450.ms, curve: Curves.easeOut)
        .slideX(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }
}