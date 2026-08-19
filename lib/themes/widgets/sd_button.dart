import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';

enum SdButtonVariant { primary, secondary, ghost, danger }

/// Design-system button with consistent sizing and WCAG touch targets.
class SdButton extends StatelessWidget {
  const SdButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SdButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SdButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    final button = switch (variant) {
      SdButtonVariant.primary => FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      SdButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      SdButtonVariant.ghost => TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      SdButtonVariant.danger => FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.white,
          ),
          child: child,
        ),
    };

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}