import 'dart:math';

/// Artificial network delay utility (200-600ms)
/// Ensures skeleton loaders and async feedback are visible during development.
class MockDelay {
  static final Random _random = Random();

  static Future<void> wait([int? milliseconds]) async {
    final ms = milliseconds ?? (200 + _random.nextInt(400));
    await Future.delayed(Duration(milliseconds: ms));
  }
}
