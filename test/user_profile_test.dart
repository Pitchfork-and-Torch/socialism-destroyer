import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/models/user_profile.dart';

void main() {
  test('UserProfile fromJson parses Supabase row', () {
    final restored = UserProfile.fromJson({
      'uid': 'abc-123',
      'email': 'user@example.com',
      'display_name': 'Liberty User',
      'photo_url': 'https://example.com/photo.jpg',
      'created_at': '2026-01-01T00:00:00.000Z',
      'last_login': '2026-07-04T12:00:00.000Z',
      'favorites': ['wealth-inequality-broken'],
      'personal_notes': {'claim-1': {'content': 'note'}},
      'reading_progress': {'the-law': {'offset': 100}},
      'debate_history': [{'input': 'test'}],
    });

    expect(restored.uid, 'abc-123');
    expect(restored.favorites, ['wealth-inequality-broken']);
    expect(restored.personalNotes['claim-1'], isNotNull);
  });
}