import 'dart:async';

import '../enum/callback_controller_state.dart';

FutureOr<void> defaultCallback() {}

/// Limits the frequency with which a callback is called to one call per
/// [duration].
///
/// To run the callback as soon as possible use [CallbackController.limiter].
/// To delay the execution of run use [CallbackController.delayer].
abstract class CallbackController {
  CallbackController({required this.duration})
      : currentState = CallbackControllerState.ready.stamp,
        _controller = StreamController<CallbackControllerState>()
          ..add(CallbackControllerState.ready);

  /// Runs a callback as soon as possible and limits the calling frequency
  /// to one call per [duration].
  ///
  /// Use case: Preventing a user from making numerous expensive requests
  /// (e.g. by pressing a button widget repeatedly withing a short timespan).
  factory CallbackController.limiter({
    Duration duration = const Duration(seconds: 1),
  }) =>
      CallbackLimiter(duration: duration);

  /// Waits for [duration] before running a callback.
  ///
  /// Use case: Collecting and aggregating input from a Futter `TextField`
  /// while the user is typing and only processing the input after [duration].
  factory CallbackController.delayer({
    Duration duration = const Duration(seconds: 1),
  }) =>
      CallbackDelayer(duration: duration);

  /// After the event [CallbackControllerState.delaying] is added the stream
  /// will wait for at least [duration] before the event
  /// [CallbackControllerState.ready] is added.
  final Duration duration;

  final StreamController<CallbackControllerState> _controller;

  /// The current state.
  ///
  /// Note: [currentState].state is last event added to [stream].
  TimeStampedCallbackControllerState currentState;

  /// Returns `true` if the last state added to [stream] was
  /// [CallbackControllerState.delaying] and [DateTime.now] is after
  /// [currentState.dateTime] plus [duration].
  bool get hasTimedOut {
    return (currentState.isBusy || currentState.isDelaying) &&
        DateTime.now().isAfter(currentState.dateTimeStamp.add(duration));
  }

  /// Runs and awaits [callback] and adds events to [stream].
  Future<void> runAsync(FutureOr<void> Function() callback);

  /// Runs [callback] and adds events to [stream].
  void run(FutureOr<void> Function() callback);

  /// Closes [stream], such that no further events can be added to it.
  ///
  /// Should be called in the `onDispose()` method of a widget using
  /// [CallbackController].
  Future close() {
    return _controller.close();
  }

  /// A stream with events of type [CallbackControllerState].
  Stream<CallbackControllerState> get stream => _controller.stream;

  void _add(CallbackControllerState controllerState) {
    if (!_controller.isClosed) {
      currentState = controllerState.stamp;
      _controller.add(currentState.state);
    }
  }
}

/// Runs the callback as soon as possible and limits the calling frequency
/// to one call per [duration].
///
/// Use case: Preventing a user from making numerous expensive requests (e.g. by
/// pressing a button repeatedly withing a short timespan).
class CallbackLimiter extends CallbackController {
  CallbackLimiter({super.duration = const Duration(seconds: 1)});

  /// Runs [callback] and adds events to [stream] using the following sequence:
  ///
  /// * [busy], [delaying],[ready].
  @override
  Future<void> runAsync(FutureOr<void> Function() callback) async {
    if (hasTimedOut) {
      _add(CallbackControllerState.ready);
    }

    if (currentState.isNotReady) {
      return;
    }

    try {
      _add(CallbackControllerState.busy);
      await callback();
    } catch (error, stacktrace) {
      _controller.addError(error, stacktrace);
    }
    _add(CallbackControllerState.delaying);
  }

  @override
  void run(FutureOr<void> Function() callback) {
    if (hasTimedOut) {
      _add(CallbackControllerState.ready);
    }

    if (currentState.isNotReady) {
      return;
    }

    try {
      _add(CallbackControllerState.busy);
      callback();
    } catch (error, stacktrace) {
      _controller.addError(error, stacktrace);
    }
    _add(CallbackControllerState.delaying);
  }
}

/// Waits for [duration] before running a callback.
///
/// Use case: Collecting and aggregating input from a Futter `TextField`
/// while the user is typing and only processing the input after [duration].
class CallbackDelayer extends CallbackController {
  CallbackDelayer({required super.duration});

  Timer? _timer;
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

    if (currentState.isReady) {
      _add(CallbackControllerState.delaying);
      _timer = Timer(duration, () async {
        try {
          _add(CallbackControllerState.busy);
          await _callback();
        } catch (error, stacktrace) {
          _controller.addError(error, stacktrace);
        } finally {
          _add(CallbackControllerState.ready);
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

    if (currentState.isReady) {
      _add(CallbackControllerState.delaying);
      _timer = Timer(duration, () async {
        try {
          _add(CallbackControllerState.busy);
          _callback();
        } catch (error, stacktrace) {
          _controller.addError(error, stacktrace);
        } finally {
          _add(CallbackControllerState.ready);
        }
      });
    }
  }

  @override
  void _add(CallbackControllerState controllerState) {
    if (!_controller.isClosed) {
      currentState = controllerState.stamp;
      _controller.add(currentState.state);
    }
  }

  /// Closes the controller such that no further events will be added to stream.
  /// Any unfinished timers will be cancelled.
  ///
  /// This method should be called in the `onDispose()` method of a
  /// Flutter widget.
  @override
  Future close() {
    _timer?.cancel();
    return _controller.close();
  }
}
