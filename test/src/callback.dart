import 'dart:collection';

class Callback {
  final _callTimeStamps = <DateTime>[];

  List<DateTime> get timeStamps => UnmodifiableListView(_callTimeStamps);

  /// Returns the number of times [call] has run.
  int get calls => _callTimeStamps.length;

  /// Callback uses for testing purposes.
  void call() {
    print('   =====>> in callback: ${DateTime.now()}');
    _callTimeStamps.add(DateTime.now());
  }

  /// Async callback used for testing purposes.
  Future<void> callAsync() async {
    _callTimeStamps.add(DateTime.now());
  }

  void reset() {
    _callTimeStamps.clear();
  }
}
