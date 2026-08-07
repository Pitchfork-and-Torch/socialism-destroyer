import 'package:flutter/material.dart';

import '../../../models/claim_suggestion.dart';
import '../../../themes/app_colors.dart';

class SuggestionStatusChip extends StatelessWidget {
  const SuggestionStatusChip({super.key, required this.status});

  final SuggestionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      SuggestionStatus.pending => (
          'Pending review',
          AppColors.gold,
          Icons.hourglass_top_rounded,
        ),
      SuggestionStatus.approved => (
          'Approved',
          Colors.green.shade700,
          Icons.verified_outlined,
        ),
      SuggestionStatus.rejected => (
          'Not accepted',
          AppColors.danger,
          Icons.block_outlined,
        ),
    };

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.compact,
    );
  }
}