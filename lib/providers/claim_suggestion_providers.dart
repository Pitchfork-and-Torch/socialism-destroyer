import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/claim_suggestion.dart';
import '../services/claim_suggestion_service.dart';

final claimSuggestionServiceProvider =
    Provider<ClaimSuggestionService>((ref) => ClaimSuggestionService());

final myClaimSuggestionsProvider =
    FutureProvider<List<ClaimSuggestion>>((ref) async {
  final service = ref.watch(claimSuggestionServiceProvider);
  return service.fetchLocalSuggestions();
});

final claimSuggestionDraftProvider =
    FutureProvider<ClaimSuggestionDraft?>((ref) async {
  return ref.watch(claimSuggestionServiceProvider).loadDraft();
});

enum SuggestionUiStatus { idle, submitting, success, error }

class SuggestionFormState {
  const SuggestionFormState({
    this.status = SuggestionUiStatus.idle,
    this.error,
    this.lastSubmitted,
  });

  final SuggestionUiStatus status;
  final String? error;
  final ClaimSuggestion? lastSubmitted;

  bool get isSubmitting => status == SuggestionUiStatus.submitting;
}

class SuggestionFormController extends StateNotifier<SuggestionFormState> {
  SuggestionFormController(this._ref) : super(const SuggestionFormState());

  final Ref _ref;

  Future<bool> submit({
    required String topicId,
    required String title,
    required String socialistClaim,
    required String counterSummary,
    required List<SuggestionSource> sources,
    String? notes,
  }) async {
    state = const SuggestionFormState(status: SuggestionUiStatus.submitting);
    try {
      final service = _ref.read(claimSuggestionServiceProvider);
      final result = await service.submit(
        topicId: topicId,
        title: title,
        socialistClaim: socialistClaim,
        counterSummary: counterSummary,
        sources: sources,
        notes: notes,
      );
      state = SuggestionFormState(
        status: SuggestionUiStatus.success,
        lastSubmitted: result,
      );
      _ref.invalidate(myClaimSuggestionsProvider);
      _ref.invalidate(claimSuggestionDraftProvider);
      return true;
    } on ClaimSuggestionException catch (e) {
      state = SuggestionFormState(
        status: SuggestionUiStatus.error,
        error: e.message,
      );
      _ref.invalidate(claimSuggestionDraftProvider);
      return false;
    } catch (e) {
      state = SuggestionFormState(
        status: SuggestionUiStatus.error,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const SuggestionFormState();
}

final suggestionFormControllerProvider =
    StateNotifierProvider<SuggestionFormController, SuggestionFormState>(
  (ref) => SuggestionFormController(ref),
);