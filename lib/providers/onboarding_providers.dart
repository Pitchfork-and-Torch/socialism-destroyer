import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifies [GoRouter] when onboarding completion changes at runtime.
class OnboardingRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final onboardingRefreshNotifierProvider = Provider<OnboardingRefreshNotifier>((ref) {
  final notifier = OnboardingRefreshNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});