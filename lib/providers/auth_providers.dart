import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';

/// Notifies GoRouter when Supabase auth state changes.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier() {
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((_) {
        notifyListeners();
      });
    } catch (_) {}
  }
}

final authRefreshNotifierProvider = Provider<AuthRefreshNotifier>((ref) {
  final notifier = AuthRefreshNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final userProfileServiceProvider =
    Provider<UserProfileService>((ref) => UserProfileService());

final authStateProvider = StreamProvider<AuthState>((ref) {
  try {
    return Supabase.instance.client.auth.onAuthStateChange;
  } catch (_) {
    return const Stream.empty();
  }
});

final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  try {
    return Supabase.instance.client.auth.currentUser;
  } catch (_) {
    return null;
  }
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(userProfileServiceProvider).fetchProfile(user.id);
});

enum AuthUiStatus { idle, loading, success, error }

class AuthControllerState {
  const AuthControllerState({
    this.status = AuthUiStatus.idle,
    this.error,
    this.infoMessage,
  });

  final AuthUiStatus status;
  final String? error;
  final String? infoMessage;

  bool get isLoading => status == AuthUiStatus.loading;

  AuthControllerState copyWith({
    AuthUiStatus? status,
    String? error,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) =>
      AuthControllerState(
        status: status ?? this.status,
        error: clearError ? null : (error ?? this.error),
        infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      );
}

class AuthController extends StateNotifier<AuthControllerState> {
  AuthController(this._auth) : super(const AuthControllerState());

  final AuthService _auth;

  Future<bool> signInWithGoogle() => _run(() => _auth.signInWithGoogle());

  Future<bool> signInWithApple() => _run(() => _auth.signInWithApple());

  Future<bool> sendMagicLink(String email) async {
    state = state.copyWith(status: AuthUiStatus.loading, clearError: true);
    try {
      await _auth.signInWithMagicLink(email);
      return false;
    } on AuthFlowException catch (e) {
      if (e.kind == AuthFailureKind.magicLinkSent) {
        state = AuthControllerState(
          status: AuthUiStatus.success,
          infoMessage: e.message,
        );
        return false;
      }
      state = AuthControllerState(
        status: AuthUiStatus.error,
        error: _friendlyMessage(e),
      );
      return false;
    } catch (e) {
      state = AuthControllerState(
        status: AuthUiStatus.error,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signOut() => _run(() => _auth.signOut());

  Future<bool> _run(Future<void> Function() action) async {
    state = state.copyWith(status: AuthUiStatus.loading, clearError: true, clearInfo: true);
    try {
      await action();
      state = const AuthControllerState(status: AuthUiStatus.success);
      return true;
    } on AuthFlowException catch (e) {
      if (e.kind == AuthFailureKind.cancelled) {
        state = const AuthControllerState(status: AuthUiStatus.idle);
        return false;
      }
      state = AuthControllerState(
        status: AuthUiStatus.error,
        error: _friendlyMessage(e),
      );
      return false;
    } catch (e) {
      state = AuthControllerState(
        status: AuthUiStatus.error,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const AuthControllerState();

  String _friendlyMessage(AuthFlowException e) => switch (e.kind) {
        AuthFailureKind.notConfigured =>
          'Cloud sign-in is not configured yet. Use email magic link or continue as guest.',
        AuthFailureKind.permissionDenied =>
          'Permission denied. Try the email magic link instead.',
        AuthFailureKind.network =>
          'Network error. Check your connection and try again.',
        AuthFailureKind.invalidEmail => 'Enter a valid email address.',
        _ => e.message ?? 'Sign-in failed. Please try again.',
      };
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthControllerState>(
  (ref) => AuthController(ref.watch(authServiceProvider)),
);