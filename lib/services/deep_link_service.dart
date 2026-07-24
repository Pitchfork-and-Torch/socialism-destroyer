import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';

/// Listens for OAuth / magic-link deep links on mobile and desktop.
class DeepLinkService {
  DeepLinkService({AuthService? auth}) : _auth = auth ?? AuthService();

  final AuthService _auth;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> init() async {
    if (kIsWeb) return;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) await _handle(initial);

      _subscription = _appLinks.uriLinkStream.listen(_handle);
    } catch (_) {}
  }

  Future<void> _handle(Uri uri) async {
    if (uri.scheme != AuthService.redirectScheme) return;
    try {
      await _auth.handleAuthCallback(uri);
    } catch (_) {}
  }

  void dispose() => _subscription?.cancel();
}