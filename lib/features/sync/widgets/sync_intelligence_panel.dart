import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/knowledge_sync.dart';
import '../../../themes/themes.dart';
import '../providers/knowledge_sync_providers.dart';
import 'changelog_sheet.dart';

/// Sync status, manual update, changelog, and auto-check toggle.
class SyncIntelligencePanel extends ConsumerWidget {
  const SyncIntelligencePanel({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(knowledgeSyncStateProvider);
    final phase = ref.watch(knowledgeSyncControllerProvider);
    final autoSync = ref.watch(autoSyncOnLaunchProvider);
    final isBusy = phase.maybeWhen(
      data: (p) =>
          p == SyncPhase.checking ||
          p == SyncPhase.downloading ||
          p == SyncPhase.applying,
      orElse: () => phase.isLoading,
    );

    return statusAsync.when(
      data: (status) {
        final updateAvailable = status.remoteKbVersion != null &&
            KnowledgeVersion.isNewer(
              status.remoteKbVersion!,
              status.effectiveKbVersion,
            );

        return SdCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (updateAvailable)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: context.sd.accentGold.withValues(alpha: 0.12),
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: context.sd.accentGold.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.system_update_alt,
                        size: 18,
                        color: context.sd.accentGold,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'New curated intelligence available',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: context.sd.accentGold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Icon(Icons.cloud_sync_outlined, color: context.sd.accentGold),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Sync Latest Intelligence',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (updateAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: context.sd.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.sd.accentGold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        'Update',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: context.sd.accentGold,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.xs),
                  TextButton(
                    onPressed: () => ChangelogSheet.show(context),
                    child: const Text('Changelog'),
                  ),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Curated claims, charts, and library texts — updated without an app store release.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sd.textLow,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              _StatusRow(
                label: 'Installed',
                value: 'v${status.effectiveKbVersion}',
                icon: Icons.inventory_2_outlined,
              ),
              if (status.remoteKbVersion != null &&
                  status.remoteKbVersion != status.effectiveKbVersion)
                _StatusRow(
                  label: 'Remote',
                  value: 'v${status.remoteKbVersion}',
                  icon: Icons.cloud_outlined,
                  highlight: updateAvailable,
                ),
              if (status.lastSyncedAt != null)
                _StatusRow(
                  label: 'Last synced',
                  value: _formatTimestamp(status.lastSyncedAt!),
                  icon: Icons.history,
                ),
              if (status.lastCheckedAt != null && status.lastSyncedAt == null)
                _StatusRow(
                  label: 'Last checked',
                  value: _formatTimestamp(status.lastCheckedAt!),
                  icon: Icons.schedule,
                ),
              if (status.lastError != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  status.lastError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sd.accentRed,
                      ),
                  maxLines: compact ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-check on launch'),
                  subtitle: Text(
                    compact
                        ? 'Quietly sync when updates are available'
                        : 'Quietly check for curated updates when the app opens',
                  ),
                  value: autoSync,
                  onChanged: isBusy
                      ? null
                      : (v) => ref
                          .read(knowledgeSyncControllerProvider.notifier)
                          .setAutoSyncOnLaunch(v),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SdButton(
                label: _buttonLabel(isBusy, phase, updateAvailable, compact),
                icon: Icons.sync,
                isLoading: isBusy,
                expand: true,
                onPressed: isBusy ? null : () => _runSync(context, ref),
              ),
              if (!compact)
                Text(
                  'Offline? Bundled intelligence remains fully available.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.sd.textLow,
                      ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
      },
      loading: () => SdCard(
        child: SizedBox(
          height: compact ? 56 : 80,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.sd.accentGold,
              ),
            ),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  String _buttonLabel(
    bool isBusy,
    AsyncValue<SyncPhase> phase,
    bool updateAvailable,
    bool compact,
  ) {
    if (isBusy) {
      return phase.maybeWhen(
        data: (p) => switch (p) {
          SyncPhase.checking => 'Checking…',
          SyncPhase.downloading => 'Downloading…',
          SyncPhase.applying => 'Applying…',
          _ => 'Syncing…',
        },
        orElse: () => 'Syncing…',
      );
    }
    if (compact && !updateAvailable) return 'Sync Intelligence';
    return 'Sync Latest Intelligence';
  }

  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat.yMMMd().add_jm().format(dt);
    } catch (_) {
      return iso;
    }
  }

  Future<void> _runSync(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(knowledgeSyncControllerProvider.notifier);
    final check = await controller.checkForUpdates();

    if (!context.mounted) return;

    if (check.availability == UpdateAvailability.upToDate) {
      _showSnack(context, check.message ?? 'Intelligence is current.');
      return;
    }

    if (check.availability == UpdateAvailability.notConfigured) {
      _showSnack(
        context,
        check.message ?? 'CDN not configured — bundled content is active.',
      );
      return;
    }

    if (check.availability == UpdateAvailability.offline) {
      _showSnack(
        context,
        check.message ?? 'Offline — bundled knowledge base is ready.',
      );
      return;
    }

    final result = await controller.syncLatest();
    if (!context.mounted) return;
    _showSnack(
      context,
      result.message ?? (result.success ? 'Sync complete.' : 'Sync failed.'),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.sd.textLow),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: highlight ? context.sd.accentGold : null,
                  fontWeight: highlight ? FontWeight.w600 : null,
                ),
          ),
        ],
      ),
    );
  }
}