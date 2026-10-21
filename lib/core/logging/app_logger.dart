import 'package:flutter/foundation.dart';

/// Application logger. Never log tokens, passwords, or customer data.
abstract final class AppLog {
  static void info(String message) {
    debugPrint('[DukanOS] INFO: $message');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint(
      '[DukanOS] ERROR: $message${error != null ? ' error=$error' : ''}',
    );
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
