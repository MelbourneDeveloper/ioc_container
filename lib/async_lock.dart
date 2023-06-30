import 'dart:async';

/// A lock that ensures that only one async function executes at a time.
class AsyncLock<T> {
  /// Creates a new [AsyncLock].
  AsyncLock(this.function, {this.retainFutureErrors = false});

  /// The function to execute.
  final Future<T> Function() function;

  Completer<T>? _completer;

  /// Whether to retain errors or allow reentrancy until the Future completes
  /// successfully.
  final bool retainFutureErrors;

  /// Executes the given [function] and returns the value, but ensures that
  /// only one async function executes at a time.
  Future<T> execute() async {
    try {
      if (_completer != null) {
        return _completer!.future;
      } else {
        _completer = Completer<T>();
      }
      final result = await function();
      _completer!.complete(result);
      return result;
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      if (retainFutureErrors) {
        _completer!.completeError(error, stackTrace);
      } else {
        _completer = null;
      }
      rethrow;
    }
  }
}
