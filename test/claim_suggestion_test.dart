import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/models/claim_suggestion.dart';
import 'package:socialism_destroyer/services/claim_suggestion_service.dart';

void main() {
  group('ClaimSuggestion', () {
    test('fromJson parses status and sources', () {
      final s = ClaimSuggestion.fromJson({
        'id': 'abc',
        'user_id': 'user-1',
        'topic_id': 'wealth-inequality-mobility',
        'title': 'Test Counter Title Here',
        'socialist_claim': 'A long enough socialist claim for testing.',
        'counter_summary':
            'A counter summary with enough characters to pass validation rules easily.',
        'sources': [
          {'title': 'Census', 'url': 'https://www.census.gov'},
          {'title': 'BLS', 'url': 'https://www.bls.gov'},
        ],
        'status': 'pending',
        'created_at': '2026-07-04T12:00:00Z',
        'updated_at': '2026-07-04T12:00:00Z',
      });

      expect(s.status, SuggestionStatus.pending);
      expect(s.sources, hasLength(2));
      expect(s.statusLabel, 'Pending review');
    });

    test('draft round-trips JSON', () {
      final draft = ClaimSuggestionDraft(
        topicId: 'profit-exploitation',
        title: 'Profit Is Not Theft Counter',
        socialistClaim: 'Profit is stolen labor value from workers every day.',
        counterSummary:
            'Voluntary exchange and risk-bearing justify profit as a coordination signal.',
        sources: const [
          SuggestionSource(title: 'Smith', url: 'https://example.com/smith'),
          SuggestionSource(title: 'Bastiat', url: 'https://example.com/bastiat'),
        ],
        savedAt: DateTime.utc(2026, 7, 4),
      );

      final restored = ClaimSuggestionDraft.fromJson(draft.toJson());
      expect(restored.title, draft.title);
      expect(restored.sources, hasLength(2));
    });
  });

  group('ClaimSuggestionService validation', () {
    final service = ClaimSuggestionService();

    test('rejects fewer than two sources', () {
      expect(
        () => service.submit(
          topicId: 'wealth-inequality-mobility',
          title: 'Valid Title Here',
          socialistClaim: 'Socialist claim with enough characters here.',
          counterSummary:
              'Counter summary with enough characters to satisfy the minimum length.',
          sources: const [
            SuggestionSource(title: 'One', url: 'https://example.com'),
          ],
        ),
        throwsA(isA<ClaimSuggestionException>()),
      );
    });
  });
}