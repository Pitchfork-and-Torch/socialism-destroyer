import 'package:socialism_destroyer/providers/auth_providers.dart';
import 'package:socialism_destroyer/services/auth_service.dart';

/// Controllable auth controller for widget / integration journeys.
class StubAuthController extends AuthController {
  StubAuthController({
    this.appleSucceeds = true,
    this.googlePermissionDenied = false,
  }) : super(AuthService());

  bool appleSucceeds;
  bool googlePermissionDenied;

  @override
  Future<bool> signInWithApple() async {
    state = state.copyWith(status: AuthUiStatus.loading, clearError: true);
    await Future<void>.delayed(Duration.zero);
    if (appleSucceeds) {
      state = const AuthControllerState(status: AuthUiStatus.success);
      return true;
    }
    state = const AuthControllerState(
      status: AuthUiStatus.error,
      error: 'Apple sign-in failed in test.',
    );
    return false;
  }

  @override
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthUiStatus.loading, clearError: true);
    await Future<void>.delayed(Duration.zero);
    if (googlePermissionDenied) {
      state = const AuthControllerState(
        status: AuthUiStatus.error,
        error: 'Permission denied. Try the email magic link instead.',
      );
      return false;
    }
    state = const AuthControllerState(status: AuthUiStatus.success);
    return true;
  }

  @override
  Future<bool> sendMagicLink(String email) async {
    state = state.copyWith(status: AuthUiStatus.loading, clearError: true);
    await Future<void>.delayed(Duration.zero);
    if (!email.contains('@')) {
      state = const AuthControllerState(
        status: AuthUiStatus.error,
        error: 'Enter a valid email address.',
      );
      return false;
    }
    state = const AuthControllerState(
      status: AuthUiStatus.success,
      infoMessage: 'Check your email for the magic link.',
    );
    return false;
  }

  @override
  Future<bool> signOut() async {
    state = const AuthControllerState(status: AuthUiStatus.idle);
    return true;
  }
}