enum CallbackControllerState {
  /// Ready state before running the callback.
  ready,

  /// Busy state after starting the callback but before the callback has
  /// finished.
  busy,

  /// The state after the callback has finished and before the state [ready].
  delaying;

  @override
  String toString() => name;

  TimeStampedCallbackControllerState get stamp =>
      TimeStampedCallbackControllerState(state: this);
}

const ready = CallbackControllerState.ready;
const busy = CallbackControllerState.busy;
const delaying = CallbackControllerState.delaying;

class TimeStampedCallbackControllerState {
  TimeStampedCallbackControllerState({required this.state});
  final CallbackControllerState state;
  final DateTime dateTimeStamp = DateTime.now();

  /// Returns `true` if `this == DebounceState.ready` and false otherwise.
  bool get isReady => state == CallbackControllerState.ready;

  /// Returns `true` if `this != DebounceState.ready` and false otherwise.
  bool get isNotReady => state != CallbackControllerState.ready;

  /// Returns `true` if `this == DebounceState.busy` and false otherwise.
  bool get isBusy => state == CallbackControllerState.busy;

  /// Returns `true` if `this == DebounceState.resetting` and false otherwise.
  bool get isDelaying => state == CallbackControllerState.delaying;

  @override
  String toString() => '$state ${dateTimeStamp.smsus}';
}

extension OneMilliMicroSeconds on DateTime {
  String get smsus => '${second}s:${'$millisecond'.padLeft(3, '0')}ms:'
      '${'$microsecond'.padLeft(3, '0')}us';
}
