import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cross-screen signals from the app shell (keyboard shortcuts, etc.).
class ShellUiState {
  const ShellUiState({this.searchFocusTick = 0});

  final int searchFocusTick;

  ShellUiState copyWith({int? searchFocusTick}) => ShellUiState(
        searchFocusTick: searchFocusTick ?? this.searchFocusTick,
      );
}

class ShellUiNotifier extends StateNotifier<ShellUiState> {
  ShellUiNotifier() : super(const ShellUiState());

  void requestSearchFocus() =>
      state = state.copyWith(searchFocusTick: state.searchFocusTick + 1);
}

final shellUiProvider =
    StateNotifierProvider<ShellUiNotifier, ShellUiState>((ref) {
  return ShellUiNotifier();
});