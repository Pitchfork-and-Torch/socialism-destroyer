import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/auth_redirect.dart';
import 'user_profile_service.dart';

enum AuthFailureKind {
  notConfigured,
  cancelled,
  permissionDenied,
  network,
  invalidEmail,
  magicLinkSent,
  unknown,
}

class AuthFlowException implements Exception {
  const AuthFlowException(this.kind, [this.message]);

  final AuthFailureKind kind;
  final String? message;

  @override
  String toString() => message ?? kind.name;
}

/// One-tap Google / Apple / magic-link authentication via Supabase Auth.
/// Desktop uses system browser OAuth; mobile uses native SDKs.
class AuthService {
  AuthService({UserProfileService? profiles})
      : _profiles = profiles ?? UserProfileService();

  final UserProfileService _profiles;

  static const String redirectScheme = 'com.libertyengine.socialismdestroyer';
  static const String redirectPath = 'login-callback';

  bool get isConfigured {
    try {
      final _ = Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser {
    try {
      return _client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  String get _redirectUrl => AuthRedirect.resolve();

  String? get _googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'];

  bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  bool get _supportsNativeApple =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// Google Sign-In — native on mobile, system browser on desktop/web.
  Future<void> signInWithGoogle() async {
    _ensureConfigured();

    if (_isDesktop || kIsWeb) {
      await _oauthBrowser(OAuthProvider.google);
      return;
    }

    final googleSignIn = GoogleSignIn(
      serverClientId: _googleWebClientId,
      scopes: const ['email', 'profile'],
    );

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        throw const AuthFlowException(AuthFailureKind.cancelled);
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw const AuthFlowException(
          AuthFailureKind.permissionDenied,
          'Google did not return an ID token. Check OAuth client configuration.',
        );
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: auth.accessToken,
      );
      await _finalizeSession();
    } on AuthFlowException {
      rethrow;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel') || msg.contains('12501')) {
        throw const AuthFlowException(AuthFailureKind.cancelled);
      }
      if (msg.contains('permission') || msg.contains('denied')) {
        throw const AuthFlowException(AuthFailureKind.permissionDenied);
      }
      throw AuthFlowException(AuthFailureKind.unknown, e.toString());
    }
  }

  /// Apple Sign-In — native on iOS/macOS; browser OAuth elsewhere.
  Future<void> signInWithApple() async {
    _ensureConfigured();

    if (!_supportsNativeApple) {
      await _oauthBrowser(OAuthProvider.apple);
      return;
    }

    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthFlowException(
          AuthFailureKind.permissionDenied,
          'Apple Sign-In did not return an identity token.',
        );
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      await _finalizeSession();
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthFlowException(AuthFailureKind.cancelled);
      }
      throw AuthFlowException(AuthFailureKind.permissionDenied, e.message);
    } on AuthFlowException {
      rethrow;
    } catch (e) {
      throw AuthFlowException(AuthFailureKind.unknown, e.toString());
    }
  }

  /// Magic-link email — graceful fallback when OAuth unavailable.
  Future<void> signInWithMagicLink(String email) async {
    _ensureConfigured();

    final trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      throw const AuthFlowException(AuthFailureKind.invalidEmail);
    }

    try {
      await _client.auth.signInWithOtp(
        email: trimmed,
        emailRedirectTo: _redirectUrl,
        shouldCreateUser: true,
      );
      throw const AuthFlowException(
        AuthFailureKind.magicLinkSent,
        'Check your email for a secure sign-in link.',
      );
    } on AuthFlowException {
      rethrow;
    } catch (e) {
      throw AuthFlowException(AuthFailureKind.unknown, e.toString());
    }
  }

  /// Handles OAuth / magic-link deep link return (desktop browser, mobile URI).
  Future<void> handleAuthCallback(Uri uri) async {
    _ensureConfigured();
    if (_client.auth.currentSession == null) {
      await _client.auth.getSessionFromUrl(uri);
    }
    await _finalizeSession();
  }

  Future<void> signOut() async {
    _ensureConfigured();
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        await GoogleSignIn().signOut();
      }
    } catch (_) {}
    await _client.auth.signOut();
  }

  Future<void> _oauthBrowser(OAuthProvider provider) async {
    await _client.auth.signInWithOAuth(
      provider,
      redirectTo: _redirectUrl,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  Future<void> _finalizeSession() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      await _profiles.upsertFromAuthUser(user);
    }
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw const AuthFlowException(
        AuthFailureKind.notConfigured,
        'Supabase is not configured. Add credentials to .env',
      );
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
}