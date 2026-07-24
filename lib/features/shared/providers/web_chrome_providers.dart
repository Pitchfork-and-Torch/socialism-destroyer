import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pinned web footer intelligence drawer — collapsed by default, dismissible.
class WebIntelligenceChromeState {
  const WebIntelligenceChromeState({
    this.expanded = false,
    this.dismissed = false,
  });

  final bool expanded;
  final bool dismissed;

  WebIntelligenceChromeState copyWith({
    bool? expanded,
    bool? dismissed,
  }) =>
      WebIntelligenceChromeState(
        expanded: expanded ?? this.expanded,
        dismissed: dismissed ?? this.dismissed,
      );
}

class WebIntelligenceChromeNotifier
    extends StateNotifier<WebIntelligenceChromeState> {
  WebIntelligenceChromeNotifier() : super(const WebIntelligenceChromeState());

  void toggleExpanded() =>
      state = state.copyWith(expanded: !state.expanded);

  void expand() => state = state.copyWith(dismissed: false, expanded: true);

  void collapse() => state = state.copyWith(expanded: false);

  void dismiss() => state = state.copyWith(dismissed: true, expanded: false);

  void restore() => state = state.copyWith(dismissed: false, expanded: false);
}

final webIntelligenceChromeProvider = StateNotifierProvider<
    WebIntelligenceChromeNotifier, WebIntelligenceChromeState>((ref) {
  return WebIntelligenceChromeNotifier();
});