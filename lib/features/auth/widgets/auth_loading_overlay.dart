import 'package:flutter/material.dart';

import '../../../themes/app_colors.dart';

class AuthLoadingOverlay extends StatelessWidget {
  const AuthLoadingOverlay({super.key, this.message = 'Signing you in…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Container(
        color: AppColors.navy.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.gold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}