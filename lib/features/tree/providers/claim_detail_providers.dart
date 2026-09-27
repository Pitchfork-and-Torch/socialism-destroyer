import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../providers/app_providers.dart';

/// Whether a claim is saved to favorites (Hive).
final claimIsFavoriteProvider = Provider.family<bool, String>((ref, claimId) {
  final storage = ref.watch(localStorageProvider);
  return storage.isFavorite(claimId);
});

/// Personal note text for a claim, if any.
final claimNoteProvider = Provider.family<String?, String>((ref, claimId) {
  final storage = ref.watch(localStorageProvider);
  final raw = storage.notes.get(claimId);
  if (raw == null) return null;
  return raw['content'] as String?;
});

/// Toggle favorite and invalidate dependent providers.
final claimFavoriteActionsProvider =
    Provider<ClaimFavoriteActions>((ref) => ClaimFavoriteActions(ref));

class ClaimFavoriteActions {
  ClaimFavoriteActions(this._ref);

  final Ref _ref;

  Future<bool> toggle(String claimId) async {
    final storage = _ref.read(localStorageProvider);
    final wasFavorite = storage.isFavorite(claimId);
    await storage.toggleFavorite(claimId);
    _ref.invalidate(claimIsFavoriteProvider(claimId));
    return !wasFavorite;
  }
}

/// Persist or clear a personal note on a claim.
final claimNoteActionsProvider = Provider<ClaimNoteActions>((ref) => ClaimNoteActions(ref));

class ClaimNoteActions {
  ClaimNoteActions(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  Future<void> save(String claimId, String content) async {
    final storage = _ref.read(localStorageProvider);
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      await storage.notes.delete(claimId);
    } else {
      await storage.notes.put(claimId, {
        'id': _uuid.v4(),
        'content': trimmed,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
    _ref.invalidate(claimNoteProvider(claimId));
  }
}