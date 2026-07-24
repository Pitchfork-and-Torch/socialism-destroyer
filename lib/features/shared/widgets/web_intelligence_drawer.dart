import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/knowledge_sync.dart';
import '../../../themes/themes.dart';
import '../../home/widgets/recent_updates_strip.dart';
import '../../sync/providers/knowledge_sync_providers.dart';
import '../../sync/widgets/sync_intelligence_panel.dart';
import '../providers/web_chrome_providers.dart';

/// Collapsible, dismissible intelligence block for the pinned web footer.
class WebIntelligenceDrawer extends ConsumerWidget {
  const WebIntelligenceDrawer({super.key, this.syncPanelKey});

  final GlobalKey? syncPanelKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chrome = ref.watch(webIntelligenceChromeProvider);
    if (chrome.dismissed) return const SizedBox.shrink();

    final syncAsync = ref.watch(knowledgeSyncStateProvider);
    final updateAvailable = syncAsync.maybeWhen(
      data: (s) =>
          s.remoteKbVersion != null &&
          KnowledgeVersion.isNewer(s.remoteKbVersion!, s.effectiveKbVersion),
      orElse: () => false,
    );

    final notifier = ref.read(webIntelligenceChromeProvider.notifier);

    return SdCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: notifier.toggleExpanded,
                      splashFactory: NoSplash.splashFactory,
                      splashColor: Colors.transparent,
                      hoverColor: context.sd.accentGold.withValues(alpha: 0.08),
                      highlightColor:
                          context.sd.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_sync_outlined,
                              size: 18,
                              color: context.sd.accentGold,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'Intelligence updates',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            if (updateAvailable)
                              Container(
                                margin:
                                    const EdgeInsets.only(right: AppSpacing.xs),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.sd.accentGold
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.sd.accentGold
                                        .withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Text(
                                  'Update',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: context.sd.accentGold,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _DrawerIconButton(
                  tooltip: chrome.expanded ? 'Collapse' : 'Expand',
                  icon: chrome.expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppColors.textSecondary,
                  onPressed: notifier.toggleExpanded,
                ),
                _DrawerIconButton(
                  tooltip: 'Dismiss',
                  icon: Icons.close_rounded,
                  iconSize: 18,
                  color: AppColors.textMuted,
                  onPressed: notifier.dismiss,
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: AppMotion.standard,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: chrome.expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const RecentUpdatesStrip(),
                        const SizedBox(height: 10),
                        KeyedSubtree(
                          key: syncPanelKey,
                          child: const SyncIntelligencePanel(compact: true),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Footer icon control — GestureDetector avoids web IconButton hit-test gaps.
class _DrawerIconButton extends StatefulWidget {
  const _DrawerIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.iconSize = 24,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double iconSize;

  @override
  State<_DrawerIconButton> createState() => _DrawerIconButtonState();
}

class _DrawerIconButtonState extends State<_DrawerIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverFill = context.sd.accentGold.withValues(alpha: 0.1);

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: AppMotion.quick,
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _hovered ? hoverFill : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}