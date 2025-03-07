import 'dart:async';

import '../enum/callback_controller_state.dart';

FutureOr<void> defaultCallback() {}

/// Limits the frequency with which a callback is called to one call per
/// [duration].
///
/// To run the callback as soon as possible use [CallbackController.limiter].
/// To delay the execution by [duration] use [CallbackController.delayer].
abstract class CallbackController {
  CallbackController({required this.duration})
    : current = CallbackControllerState.ready.stamp,
      _controller =
          StreamController<CallbackControllerState>()
            ..add(CallbackControllerState.ready);

  /// Runs a callback as soon as possible and limits the calling frequency
  /// to one call per [duration].
  ///
  /// Use case: Preventing a user from making numerous expensive requests
  /// (e.g. by pressing a button widget repeatedly withing a short timespan).
  factory CallbackController.limiter({required Duration duration}) =>
      CallbackLimiter(duration: duration);

  /// Waits for [duration] before running a callback.
  ///
  /// Use case: Collecting and aggregating input from a Futter `TextField`
  /// while the user is typing and only processing the input after [duration].
  factory CallbackController.delayer({required Duration duration}) =>
      CallbackDelayer(duration: duration);

  /// After the event [delaying] is added the stream
  /// will wait for at least [duration] before the event
  /// [CallbackControllerState.ready] is added.
  final Duration duration;

  /// Stream controller providing [stream].
  final StreamController<CallbackControllerState> _controller;

  /// Delay timer
  Timer? _timer;

  /// The current state.
  ///
  /// Note: [current].state is the last event added to [stream].
  TimeStampedCallbackControllerState current;

  /// Returns `true` if the last state added to [stream] was
  /// [delaying] and [DateTime.now] is after
  /// [current].dateTimeStamp plus [duration].
  bool get hasTimedOut {
    return (current.state.isDelaying) &&
        DateTime.now().isAfter(current.dateTimeStamp.add(duration));
  }

  /// Runs and awaits [callback] and adds events to [stream].
  Future<void> runAsync(FutureOr<void> Function() callback);

  /// Runs [callback] and adds events to [stream].
  void run(FutureOr<void> Function() callback);

  /// Closes the controller such that no further events will be added to
  /// [stream].
  /// Any unfinished timers will be cancelled.
  ///
  /// This method should be called in the `onDispose()` method of a
  /// Flutter widget.
  Future close() {
    _timer?.cancel();
    return _controller.close();
  }

  /// A stream with events of type [CallbackControllerState].
  Stream<CallbackControllerState> get stream => _controller.stream;

  void _add(CallbackControllerState controllerState) {
    if (!_controller.isClosed) {
      current = controllerState.stamp;
      _controller.add(current.state);
    }
  }
}

/// Runs the callback as soon as possible and limits the calling frequency
/// to one call per [duration].
///
/// Use case: Preventing a user from making numerous expensive requests (e.g. by
/// pressing a button repeatedly withing a short timespan).
class CallbackLimiter extends CallbackController {
  CallbackLimiter({required super.duration});

  /// Runs [callback] and adds events to [stream] using the following sequence:
  ///
  /// * [busy], [delaying],[ready].
  @override
  Future<void> runAsync(FutureOr<void> Function() callback) async {
    if (current.state.isReady) {
      try {
        _add(busy);
        await callback();
        _add(delaying);
      } catch (error, stacktrace) {
        _controller.addError(error, stacktrace);
      } finally {
        _timer = Timer(duration, () {
          _add(ready);
        });
      }
    }
  }

  @override
  void run(FutureOr<void> Function() callback) {
    if (current.state.isReady) {
      try {
        _add(busy);
        callback();
        _add(delaying);
      } catch (error, stacktrace) {
        _controller.addError(error, stacktrace);
      } finally {
        _timer = Timer(duration, () {
          _add(ready);
        });
      }
    }
  }
}

/// Waits for [duration] before running a callback.
///
/// Use case: Collecting and aggregating input from a Futter `TextField`
/// while the user is typing and only processing the input after [duration].
class CallbackDelayer extends CallbackController {
  CallbackDelayer({required super.duration});

  late FutureOr<void> Function() _callback = defaultCallback;

  /// Delays the runnign of [callback] and emits events in the following sequence:
  ///
  /// * [delaying], [busy], [ready].
  /// * Calling the [runAsync] repeatedly during the state [delaying] will cause
  /// [callback] to be replace with the latest version of [callback].
  @override
  Future<void> runAsync(FutureOr<void> Function() callback) async {
    // Update callback to make sure the latest version is called.
    _callback = callback;

    if (current.state.isReady) {
      _add(delaying);
      _timer = Timer(duration, () async {
        try {
          _add(busy);
          await _callback();
        } catch (error, stacktrace) {
          _controller.addError(error, stacktrace);
        } finally {
          _add(ready);
        }
      });
    }

  }

  /// Delays running [callback].
  /// * emits events in the following sequence: [ready], [delaying],[busy].
  /// * If another [callback] is run during the delay period the
  /// latest [callback] will replace the earlier [callback].
  @override
  FutureOr<void> run(FutureOr<void> Function() callback) {
    // Update callback to make sure the latest version is called.
    _callback = callback;

    if (current.state.isReady) {
      _add(delaying);
      _timer = Timer(duration, () {
        try {
          _add(busy);
          _callback();
        } catch (error, stacktrace) {
          _controller.addError(error, stacktrace);
        } finally {
          _add(ready);
        }
      });
    }
  }

  @override
  void _add(CallbackControllerState controllerState) {
    if (!_controller.isClosed) {
      current = controllerState.stamp;
      _controller.add(current.state);
    }
  }
}
