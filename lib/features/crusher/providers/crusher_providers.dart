import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/crusher_result.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_providers.dart';
import '../services/claim_retrieval_backend.dart';
import '../services/crusher_service.dart';
import '../services/debate_history_service.dart';

final ftsRetrievalProvider = Provider<FtsClaimRetrievalBackend>((ref) {
  return FtsClaimRetrievalBackend(ref.watch(searchServiceProvider));
});

final embeddingRetrievalProvider =
    Provider<EmbeddingOverlapRetrievalBackend>((ref) {
  return EmbeddingOverlapRetrievalBackend(ref.watch(knowledgeServiceProvider));
});

final vectorRetrievalProvider = Provider<VectorClaimRetrievalBackend>((ref) {
  // Offline hashed bag-of-words vectors — enabled for hybrid retrieval (v2.1).
  return VectorClaimRetrievalBackend(
    knowledge: ref.watch(knowledgeServiceProvider),
    enabled: true,
  );
});

final claimRetrievalProvider = Provider<ClaimRetrievalBackend>((ref) {
  return HybridClaimRetrievalBackend(
    fts: ref.watch(ftsRetrievalProvider),
    embedding: ref.watch(embeddingRetrievalProvider),
    vector: ref.watch(vectorRetrievalProvider),
  );
});

final crusherServiceProvider = Provider<CrusherService>((ref) {
  return CrusherService(
    knowledge: ref.watch(knowledgeServiceProvider),
    retrieval: ref.watch(claimRetrievalProvider),
  );
});

final debateHistoryServiceProvider = Provider<DebateHistoryService>((ref) {
  return DebateHistoryService(local: ref.watch(localStorageProvider));
});

final debateHistoryProvider = Provider<List<DebateHistoryMeta>>((ref) {
  ref.watch(crusherSessionProvider);
  final service = ref.watch(debateHistoryServiceProvider);
  return service.listRecentMeta();
});

/// Latest crusher session — bump to refresh history.
final crusherSessionProvider = StateProvider<int>((ref) => 0);

final crusherActionsProvider = Provider<CrusherActions>((ref) => CrusherActions(ref));

class CrusherActions {
  CrusherActions(this._ref);

  final Ref _ref;

  Future<CrusherResult> crush(String input) async {
    final service = _ref.read(crusherServiceProvider);
    final history = _ref.read(debateHistoryServiceProvider);
    final result = await service.crush(input);
    await history.save(result);
    final user = _ref.read(currentUserProvider);
    if (user != null) {
      await history.syncToProfile(user.id);
    }
    _ref.read(crusherSessionProvider.notifier).state++;
    return result;
  }
}

/// In-flight crusher operation.
final crusherResultProvider =
    AutoDisposeFutureProvider.family<CrusherResult, String>((ref, input) async {
  return ref.read(crusherActionsProvider).crush(input);
});