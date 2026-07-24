import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../services/auth_service.dart';

/// Resolves OAuth / magic-link redirect targets per platform.
abstract final class AuthRedirect {
  static const String webProduction =
      'https://destroyer.jonbailey.xyz/auth/callback/';

  static String resolve() {
    final fromEnv = dotenv.env['AUTH_REDIRECT_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty && !_isPlaceholder(fromEnv)) {
      return _withTrailingSlash(fromEnv);
    }

    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty && origin != 'null') {
        return _withTrailingSlash('$origin/auth/callback');
      }
      return webProduction;
    }

    return '${AuthService.redirectScheme}://${AuthService.redirectPath}/';
  }

  static bool isAuthCallbackUri(Uri uri) {
    final path = uri.path;
    return path == '/auth/callback' || path.startsWith('/auth/callback/');
  }

  static bool hasAuthCallbackParams(Uri uri) {
    if (uri.queryParameters.containsKey('code')) return true;
    if (uri.queryParameters.containsKey('access_token')) return true;
    if (uri.fragment.contains('access_token')) return true;
    if (uri.fragment.contains('code=')) return true;
    return false;
  }

  static bool _isPlaceholder(String value) =>
      value.contains('your-project') ||
      value.contains('your-anon') ||
      value.contains('your-google');

  static String _withTrailingSlash(String url) =>
      url.endsWith('/') ? url : '$url/';
}