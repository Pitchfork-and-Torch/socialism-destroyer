import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../themes/themes.dart';
import '../../shared/providers/web_chrome_providers.dart';
import '../../shared/widgets/web_intelligence_drawer.dart';

/// Home-only intelligence updates — collapsed drawer pinned above the footer.
class HomeIntelligenceSection extends ConsumerWidget {
  const HomeIntelligenceSection({super.key, this.syncPanelKey});

  final GlobalKey? syncPanelKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chrome = ref.watch(webIntelligenceChromeProvider);

    return Material(
      color: AppColors.navyDark,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!chrome.dismissed)
              WebIntelligenceDrawer(syncPanelKey: syncPanelKey)
            else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () =>
                      ref.read(webIntelligenceChromeProvider.notifier).restore(),
                  icon: const Icon(Icons.cloud_sync_outlined, size: 16),
                  label: const Text('Show intelligence updates'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}