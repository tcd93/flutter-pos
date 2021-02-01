import 'dart:async';
import 'package:flutter/foundation.dart';

/// Throttle the input action
class Debouncer {
  final int milliseconds;
  Timer _timer;

  Debouncer({this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
