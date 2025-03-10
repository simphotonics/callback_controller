import 'package:callback_controller/callback_controller.dart';
import 'package:test/test.dart';

import 'src/callback.dart';

void main() {
  final duration = Duration(milliseconds: 100);
  group('Initialize:', () {
    test('state', () {
      final limiter = CallbackLimiter(duration: duration);
      expect(limiter.current.state.isReady, isTrue);
      expect(limiter.stream, emitsInOrder([ready]));
      expect(limiter.duration, Duration(milliseconds: 100));
    });
  });

  group('Single run:', () {
    test('stream events', () {
      final limiter = CallbackLimiter(duration: duration);
      final callback = Callback();
      limiter.run(callback.call);
      expect(limiter.stream, emitsInOrder([ready, busy, delaying]));
      expect(callback.calls, 1);
    });
  });

  group('Single async run:', () {
    test('stream events', () {
      final limiter = CallbackLimiter(duration: duration);
      final callback = Callback();
      limiter.runAsync(callback.callAsync);
      expect(limiter.stream, emitsInOrder([ready, busy, delaying]));
      expect(callback.calls, 1);
    });
  });

  group('Repeated runs:', () {
    test('stream events', () {
      final limiter = CallbackLimiter(duration: duration);
      final callback = Callback();
      for (var i = 0; i < 10; i++) {
        limiter.run(callback.call);
      }
      expect(limiter.stream, emitsInOrder([ready, busy, delaying]));
      expect(callback.calls, 1);
    });
  });

  group('Repeated async runs:', () {
    test('stream events', () async {
      final limiter = CallbackLimiter(duration: duration);
      final callback = Callback();
      for (var i = 0; i < 10; i++) {
        await limiter.runAsync(callback.callAsync);
      }
      expect(limiter.stream, emitsInOrder([ready, busy, delaying]));
      expect(callback.calls, 1);
    });
  });

  group('Repeated delayed runs:', () {
    test('pause exceeding limiter duration', () async {
      final limiter = CallbackLimiter(duration: duration);
      final callback = Callback();
      final events0 = [ready, busy, delaying];
      final events = <CallbackControllerState>[];
      for (var i = 0; i < 5; i++) {
        limiter.run(callback.call);
        await Future.delayed(duration + Duration(milliseconds: 100));
        events.addAll(events0);
      }

      expect(limiter.stream, emitsInOrder(events));
      expect(callback.calls, 5);
      final stamps = callback.microsecondsTimeStamps;
      expect(stamps[1] - stamps[0], greaterThan(duration.inMilliseconds));
    });
  });

  test('pause below limiter duration', () async {
    final callback = Callback();
    final events0 = [ready, busy, delaying];
    final events = <CallbackControllerState>[];
    final limiter = CallbackLimiter(duration: duration);

    final delayinMilliseconds = 38;
    for (var i = 0; i < 10; i++) {
      limiter.run(callback.call);
      await Future.delayed(Duration(milliseconds: delayinMilliseconds));
    }

    final calls = callback.calls;

    for (var i = 0; i < calls; i++) {
      events.addAll(events0);
    }

    expect(limiter.stream, emitsInOrder(events));
    expect(
      calls,
      (delayinMilliseconds * 10 / (limiter.duration.inMilliseconds)).ceil(),
    );
    if (calls > 1) {
      final stamps = callback.microsecondsTimeStamps;
      expect(stamps[1] - stamps[0], greaterThan(duration.inMicroseconds));
    }
  });

  group('Repeated delayed async runs:', () {
    test('pause exceeding limiter duration', () async {
      final limiter = CallbackLimiter(duration: duration);
      final callback = Callback();
      final events0 = [ready, busy, delaying];
      final events = <CallbackControllerState>[];
      for (var i = 0; i < 5; i++) {
        await limiter.runAsync(callback.callAsync);
        await Future.delayed(Duration(milliseconds: 150));
        events.addAll(events0);
      }

      expect(limiter.stream, emitsInOrder(events));
      expect(callback.calls, 5);
    });
  });

  test('pause below limiter duration', () async {
    final limiter = CallbackLimiter(duration: duration);
    final callback = Callback();
    final events0 = [ready, busy, delaying];
    final events = <CallbackControllerState>[];

    final delayinMilliseconds = 38;
    for (var i = 0; i < 5; i++) {
      await limiter.runAsync(callback.callAsync);
      await Future.delayed(Duration(milliseconds: delayinMilliseconds));
    }

    final calls = callback.calls;
    for (var i = 0; i < calls; i++) {
      events.addAll(events0);
    }
    expect(limiter.stream, emitsInOrder(events));
  });
}
