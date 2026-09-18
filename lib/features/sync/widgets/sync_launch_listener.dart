import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../providers/knowledge_sync_providers.dart';

/// Runs a non-blocking intelligence check after first frame when enabled.
class SyncLaunchListener extends ConsumerStatefulWidget {
  const SyncLaunchListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncLaunchListener> createState() => _SyncLaunchListenerState();
}

class _SyncLaunchListenerState extends ConsumerState<SyncLaunchListener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoCheck());
  }

  Future<void> _autoCheck() async {
    if (!ref.read(autoSyncOnLaunchProvider)) return;
    await ref.read(knowledgeSyncServiceProvider).autoCheckOnLaunch();
    if (mounted) {
      ref.invalidate(knowledgeSyncStateProvider);
      ref.invalidate(changelogProvider);
      ref.invalidate(claimsProvider);
      ref.invalidate(topicsProvider);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}