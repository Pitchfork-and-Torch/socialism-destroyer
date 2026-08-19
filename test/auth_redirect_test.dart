import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/utils/auth_redirect.dart';

void main() {
  test('isAuthCallbackUri matches callback paths', () {
    expect(
      AuthRedirect.isAuthCallbackUri(Uri.parse('https://x.dev/auth/callback')),
      isTrue,
    );
    expect(
      AuthRedirect.isAuthCallbackUri(Uri.parse('https://x.dev/auth/callback/')),
      isTrue,
    );
    expect(
      AuthRedirect.isAuthCallbackUri(Uri.parse('https://x.dev/home')),
      isFalse,
    );
  });

  test('root path with code is not a callback path but has auth params', () {
    final uri = Uri.parse('http://localhost:3000/?code=abc');
    expect(AuthRedirect.isAuthCallbackUri(uri), isFalse);
    expect(AuthRedirect.hasAuthCallbackParams(uri), isTrue);
  });

  test('hasAuthCallbackParams detects code and tokens', () {
    expect(
      AuthRedirect.hasAuthCallbackParams(
        Uri.parse('https://x.dev/auth/callback?code=abc'),
      ),
      isTrue,
    );
    expect(
      AuthRedirect.hasAuthCallbackParams(
        Uri.parse('https://x.dev/auth/callback#access_token=xyz'),
      ),
      isTrue,
    );
    expect(
      AuthRedirect.hasAuthCallbackParams(
        Uri.parse('https://x.dev/auth/callback'),
      ),
      isFalse,
    );
  });
}