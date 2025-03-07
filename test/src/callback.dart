import 'dart:collection';

class Callback {
  final _callTimeStamps = <int>[];

  final _initialStamp = DateTime.now().microsecondsSinceEpoch;

  List<int> get microsecondsTimeStamps => UnmodifiableListView(_callTimeStamps);

  /// Returns the number of times [call] has run.
  int get calls => _callTimeStamps.length;

  /// Callback uses for testing purposes.
  void call() {
    _callTimeStamps.add(DateTime.now().microsecondsSinceEpoch - _initialStamp);
  }

  /// Async callback used for testing purposes.
  Future<void> callAsync() async {
    _callTimeStamps.add(DateTime.now().microsecondsSinceEpoch - _initialStamp);
  }

  void reset() {
    _callTimeStamps.clear();
  }
}
