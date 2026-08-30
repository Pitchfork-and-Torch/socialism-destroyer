import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/debate_playlist.dart';
import '../../../models/debate_session.dart';
import '../../../models/library_passage.dart';
import '../../../providers/app_providers.dart';
import '../../../services/debate_playlist_service.dart';
import '../../crusher/providers/crusher_providers.dart';
import '../../library/services/library_passage_rag_service.dart';
import '../services/debate_session_store.dart';
import '../services/debate_simulator_service.dart';

final debateSessionStoreProvider = Provider<DebateSessionStore>((ref) {
  return DebateSessionStore(local: ref.watch(localStorageProvider));
});

final debateSimulatorServiceProvider = Provider<DebateSimulatorService>((ref) {
  return DebateSimulatorService(
    crusher: ref.watch(crusherServiceProvider),
    knowledge: ref.watch(knowledgeServiceProvider),
    store: ref.watch(debateSessionStoreProvider),
  );
});

final libraryPassageRagProvider = Provider<LibraryPassageRagService>((ref) {
  return LibraryPassageRagService(
    knowledge: ref.watch(knowledgeServiceProvider),
  );
});

final debatePlaylistServiceProvider = Provider<DebatePlaylistService>((ref) {
  return DebatePlaylistService();
});

final debatePlaylistsProvider = FutureProvider<List<DebatePlaylist>>((ref) {
  return ref.watch(debatePlaylistServiceProvider).getPlaylists();
});

/// Bump when sessions list should refresh.
final debateSessionsTickProvider = StateProvider<int>((ref) => 0);

final debateSessionsListProvider = Provider<List<DebateSession>>((ref) {
  ref.watch(debateSessionsTickProvider);
  return ref.watch(debateSessionStoreProvider).listRecent();
});

/// Active multi-turn session controller.
final activeDebateProvider =
    StateNotifierProvider<ActiveDebateNotifier, AsyncValue<DebateSession?>>(
  (ref) => ActiveDebateNotifier(ref),
);

/// Drill state (playlist timed practice).
class DebateDrillState {
  const DebateDrillState({
    this.playlist,
    this.promptIndex = 0,
    this.active = false,
  });

  final DebatePlaylist? playlist;
  final int promptIndex;
  final bool active;

  DebateDrillState copyWith({
    DebatePlaylist? playlist,
    int? promptIndex,
    bool? active,
  }) =>
      DebateDrillState(
        playlist: playlist ?? this.playlist,
        promptIndex: promptIndex ?? this.promptIndex,
        active: active ?? this.active,
      );
}

final debateDrillProvider =
    StateNotifierProvider<DebateDrillNotifier, DebateDrillState>(
  (ref) => DebateDrillNotifier(),
);

class DebateDrillNotifier extends StateNotifier<DebateDrillState> {
  DebateDrillNotifier() : super(const DebateDrillState());

  void start(DebatePlaylist playlist) {
    state = DebateDrillState(
      playlist: playlist,
      promptIndex: 0,
      active: true,
    );
  }

  void next() {
    final p = state.playlist;
    if (p == null) return;
    final next = state.promptIndex + 1;
    if (next >= p.prompts.length) {
      state = const DebateDrillState();
      return;
    }
    state = state.copyWith(promptIndex: next);
  }

  void exit() => state = const DebateDrillState();
}

/// Passage RAG for the active session (query = latest user or seed).
final debatePassagesProvider =
    FutureProvider.autoDispose<List<LibraryPassageHit>>((ref) async {
  final session = ref.watch(activeDebateProvider).valueOrNull;
  if (session == null) return const [];
  final rag = ref.watch(libraryPassageRagProvider);
  final queryParts = <String>[
    if (session.seedArgument != null) session.seedArgument!,
    ...session.turns
        .where((t) => t.role == DebateRole.user)
        .map((t) => t.text)
        .take(3),
    ...session.turns
        .where((t) => t.role == DebateRole.engine)
        .map((t) => t.crusherResult?.executiveSummary ?? '')
        .take(2),
  ];
  final query = queryParts.where((s) => s.trim().isNotEmpty).join(' ');
  if (query.trim().isEmpty) return const [];
  return rag.retrieve(
    query: query,
    claimIds: session.allMatchedClaimIds,
    limit: 6,
  );
});

class ActiveDebateNotifier extends StateNotifier<AsyncValue<DebateSession?>> {
  ActiveDebateNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  DebateSimulatorService get _service =>
      _ref.read(debateSimulatorServiceProvider);

  void _tick() {
    _ref.read(debateSessionsTickProvider.notifier).state++;
  }

  Future<void> start({
    required DebateMode mode,
    String? seedArgument,
    String? claimId,
    String? topicId,
    String? title,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = await _service.start(
        mode: mode,
        seedArgument: seedArgument,
        claimId: claimId,
        topicId: topicId,
        title: title,
      );
      _tick();
      return session;
    });
  }

  Future<void> load(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = _service.store.load(id);
      if (session == null) {
        throw StateError('Debate session not found');
      }
      return session;
    });
  }

  Future<void> send(String text, {bool requestScore = false}) async {
    final current = state.valueOrNull;
    if (current == null) return;
    // Keep previous session visible while loading next turn (smoother UX).
    final previous = current;
    state = AsyncValue.data(previous);
    try {
      final next = await _service.userTurn(
        current,
        text,
        requestScore: requestScore,
      );
      _tick();
      state = AsyncValue.data(next);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> scoreLast() async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final next = await _service.scoreLastUserTurn(current);
      _tick();
      state = AsyncValue.data(next);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> appendChallengeOpening({
    required String seedArgument,
    String? claimId,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final next = await _service.appendChallengeOpening(
        current,
        seedArgument: seedArgument,
        claimId: claimId,
      );
      _tick();
      state = AsyncValue.data(next);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }

  Future<void> delete(String id) async {
    await _service.store.delete(id);
    if (state.valueOrNull?.id == id) {
      state = const AsyncValue.data(null);
    }
    _tick();
  }
}
