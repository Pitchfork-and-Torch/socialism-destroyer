import 'dart:async';

import 'app_constants.dart';

/// Coalesces rapid text input (search fields) into a single callback.
class Debouncer {
  Debouncer({Duration? delay}) : _delay = delay ?? AppConstants.searchDebounce;

  final Duration _delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(_delay, action);
  }

  void dispose() => _timer?.cancel();
}