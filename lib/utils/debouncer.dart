import 'dart:async';
import 'dart:ui';

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  /// Run the given action after a delay of [milliseconds].
  void run(VoidCallback action) {
    // Cancel previous timer if it exists
    _timer?.cancel();
    // Start a new timer
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Dispose the timer when not needed
  void dispose() {
    _timer?.cancel();
  }
}
