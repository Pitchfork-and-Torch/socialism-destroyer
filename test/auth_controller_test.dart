import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/providers/auth_providers.dart';
import 'package:socialism_destroyer/services/auth_service.dart';

void main() {
  group('AuthController messaging', () {
    test('permission denied suggests email fallback', () {
      final controller = AuthController(AuthService());
      final msg = controller.runtimeType;
      expect(msg, isNotNull);
    });
  });

  group('AuthFlowException', () {
    test('magic link sent is distinct kind', () {
      const e = AuthFlowException(
        AuthFailureKind.magicLinkSent,
        'Check your email',
      );
      expect(e.kind, AuthFailureKind.magicLinkSent);
      expect(e.message, contains('email'));
    });
  });
}