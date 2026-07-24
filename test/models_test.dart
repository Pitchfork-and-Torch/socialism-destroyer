import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/models/claim.dart';
import 'package:socialism_destroyer/models/topic.dart';
import 'package:socialism_destroyer/models/user_interaction.dart';

void main() {
  group('Topic v2 flat hierarchy', () {
    test('buildTree reconstructs nested children from parentId', () {
      final flat = [
        const Topic(
          id: 'root',
          title: 'Root',
          description: '',
          icon: 'folder',
          order: 1,
          parentId: null,
          path: '/root',
          depth: 0,
        ),
        const Topic(
          id: 'child',
          title: 'Child',
          description: '',
          icon: 'folder',
          order: 1,
          parentId: 'root',
          path: '/root/child',
          depth: 1,
        ),
      ];

      final tree = Topic.buildTree(flat);
      expect(tree.length, 1);
      expect(tree.first.id, 'root');
      expect(tree.first.children.length, 1);
      expect(tree.first.children.first.id, 'child');
    });

    test('fromJson supports legacy nested children', () {
      final topic = Topic.fromJson({
        'id': 'parent',
        'title': 'Parent',
        'description': 'd',
        'icon': 'folder',
        'order': 1,
        'children': [
          {'id': 'kid', 'title': 'Kid', 'order': 1},
        ],
      });
      expect(topic.children.length, 1);
      expect(topic.children.first.id, 'kid');
    });
  });

  group('Claim v2 fields', () {
    test('fromJson reads socialistClaimText and legacy socialistClaim', () {
      final fromV2 = Claim.fromJson({
        'id': 'c1',
        'topicId': 't1',
        'title': 'T',
        'socialistClaimText': 'v2 text',
        'executiveSummary': 'summary',
        'evidenceBullets': ['e1'],
        'fallacies': ['f1'],
        'sources': [
          {'title': 'S', 'url': 'https://example.com', 'type': 'government'},
        ],
        'whyItMatters': 'why',
        'tags': ['tag'],
        'updatedAt': '2026-07-04',
        'searchText': 'search',
      });
      expect(fromV2.socialistClaimText, 'v2 text');
      expect(fromV2.socialistClaim, 'v2 text');

      final fromV1 = Claim.fromJson({
        'id': 'c2',
        'topicId': 't1',
        'title': 'T',
        'socialistClaim': 'v1 text',
        'executiveSummary': 'summary',
        'evidenceBullets': ['e1'],
        'fallacies': ['f1'],
        'sources': [
          {'title': 'S', 'url': 'https://example.com', 'type': 'government'},
        ],
        'whyItMatters': 'why',
        'tags': ['tag'],
        'updatedAt': '2026-07-04',
        'searchText': 'search',
      });
      expect(fromV1.socialistClaimText, 'v1 text');
    });

    test('ragText falls back when embeddingText absent', () {
      final claim = Claim.fromJson({
        'id': 'c1',
        'topicId': 't1',
        'title': 'Title',
        'socialistClaimText': 'claim',
        'executiveSummary': 'summary',
        'evidenceBullets': ['bullet'],
        'fallacies': ['fallacy'],
        'sources': [
          {'title': 'S', 'url': 'https://example.com', 'type': 'academic'},
        ],
        'whyItMatters': 'matters',
        'tags': ['tag'],
        'updatedAt': '2026-07-04',
        'searchText': 'search',
      });
      expect(claim.ragText, contains('Title'));
      expect(claim.ragText, contains('claim'));
    });
  });

  group('UserInteraction envelope', () {
    test('round-trips note via envelope', () {
      final note = UserNote(
        id: 'n1',
        claimId: 'c1',
        content: 'my note',
        createdAt: DateTime.utc(2026, 7, 4),
      );
      final interaction = UserInteraction.note(note);
      final restored = interaction.toNote();
      expect(restored?.content, 'my note');
      expect(restored?.claimId, 'c1');
    });
  });
}