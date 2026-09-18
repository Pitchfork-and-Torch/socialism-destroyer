import 'package:supabase_flutter/supabase_flutter.dart';

/// Test user fixture for auth unit tests (native-only, not used in web journeys).
User testAppleUser() => User(
      id: 'test-apple-user-001',
      appMetadata: const {},
      userMetadata: const {'full_name': 'Liberty iPhone User'},
      aud: 'authenticated',
      createdAt: DateTime.utc(2026, 1, 1).toIso8601String(),
      email: 'iphone.user@liberty.test',
    );