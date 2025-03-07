import 'package:test/test.dart';

import 'src/callback.dart';

/// Represent a ...lkjljklkj
typedef Pair = ({int first, String second});

void main() {
  final duration = Duration(milliseconds: 100);
  group('Initialize:', () {
    test('timestamp', () {
      final callback = Callback();
      callback.call();
      expect(callback.microsecondsTimeStamps.first, greaterThan(0));
    });
  });
  group('Call:', () {
    test('timestamp', () async {
      final callback = Callback();
      await Future.delayed(duration);
      callback.call();
      expect(callback.microsecondsTimeStamps[0],
          greaterThanOrEqualTo(duration.inMicroseconds));
    });
  });

  final Pair pair = (first: 1, second: 'hi');
}
