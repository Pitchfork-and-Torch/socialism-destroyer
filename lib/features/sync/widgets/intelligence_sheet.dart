import 'package:flutter/material.dart';

import '../../../themes/themes.dart';
import '../../home/widgets/recent_updates_strip.dart';
import 'sync_intelligence_panel.dart';

/// Full intelligence panel for mobile — opened from the app bar sync action.
Future<void> showIntelligenceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.navyDark,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
          return ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md + bottomInset,
            ),
            children: const [
              Text(
                'Intelligence updates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldLight,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              RecentUpdatesStrip(),
              SizedBox(height: AppSpacing.md),
              SyncIntelligencePanel(compact: true),
            ],
          );
        },
      );
    },
  );
}