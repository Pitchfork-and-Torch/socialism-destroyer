import 'package:flutter/material.dart';

import '../../../themes/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 48, this.showSubtitle = false});

  static const String assetPath = 'assets/images/branding/app_icon_preview.png';

  final double size;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            semanticLabel: 'Socialism Destroyer app icon',
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 12),
          Text(
            'Socialism Destroyer',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'The Pro-America Liberty Argument Engine',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}