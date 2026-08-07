import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/changelog.dart';
import '../../../models/knowledge_sync.dart';
import '../../../providers/app_providers.dart';
import '../../../services/knowledge_sync_service.dart';

final knowledgeSyncServiceProvider = Provider<KnowledgeSyncService>((ref) {
  final service = KnowledgeSyncService(
    overlayStore: ref.watch(knowledgeOverlayStoreProvider),
    knowledgeService: ref.watch(knowledgeServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final knowledgeSyncStateProvider =
    FutureProvider<KnowledgeSyncState>((ref) async {
  return ref.watch(knowledgeSyncServiceProvider).getLocalStatus();
});

final changelogProvider = FutureProvider<ChangelogDocument>((ref) async {
  return ref.watch(knowledgeSyncServiceProvider).getChangelog();
});

final autoSyncOnLaunchProvider =
    StateProvider<bool>((ref) => ref.watch(knowledgeSyncServiceProvider).autoSyncOnLaunch);

class KnowledgeSyncController extends StateNotifier<AsyncValue<SyncPhase>> {
  KnowledgeSyncController(this._ref) : super(const AsyncValue.data(SyncPhase.idle));

  final Ref _ref;

  KnowledgeSyncService get _sync => _ref.read(knowledgeSyncServiceProvider);

  Future<SyncCheckResult> checkForUpdates() async {
    state = const AsyncValue.data(SyncPhase.checking);
    try {
      final result = await _sync.checkForUpdates();
      state = const AsyncValue.data(SyncPhase.idle);
      _invalidate();
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return SyncCheckResult(
        availability: UpdateAvailability.offline,
        message: e.toString(),
      );
    }
  }

  Future<SyncResult> syncLatest({bool force = false}) async {
    state = const AsyncValue.data(SyncPhase.downloading);
    try {
      final result = await _sync.syncLatest(force: force);
      state = AsyncValue.data(
        result.success ? SyncPhase.complete : SyncPhase.error,
      );
      _invalidate();
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return SyncResult(success: false, message: e.toString());
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        state = const AsyncValue.data(SyncPhase.idle);
      });
    }
  }

  Future<void> setAutoSyncOnLaunch(bool value) async {
    await _sync.setAutoSyncOnLaunch(value);
    _ref.read(autoSyncOnLaunchProvider.notifier).state = value;
  }

  void _invalidate() {
    _ref.invalidate(knowledgeSyncStateProvider);
    _ref.invalidate(changelogProvider);
    _ref.invalidate(topicsProvider);
    _ref.invalidate(claimsProvider);
  }
}

final knowledgeSyncControllerProvider =
    StateNotifierProvider<KnowledgeSyncController, AsyncValue<SyncPhase>>(
  (ref) => KnowledgeSyncController(ref),
);