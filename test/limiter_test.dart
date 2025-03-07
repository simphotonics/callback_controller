import 'dart:io';

import 'package:callback_controller/callback_controller.dart';
import 'package:test/test.dart';

import 'src/callback.dart';

void main() {
  final duration = Duration(milliseconds: 100);
  group('Initialize:', () {
    test('state', () {
      final limiter = CallbackLimiter(duration: duration);
      expect(limiter.currentState.isReady, isTrue);
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
    test('pause exceeding limiter duration', () {
      final limiter = CallbackLimiter(duration: duration);
      final callback = Callback();
      final events0 = [ready, busy, delaying];
      final events = <CallbackControllerState>[];
      for (var i = 0; i < 10; i++) {
        limiter.run(callback.call);
        sleep(Duration(milliseconds: 100));
        events.addAll(events0);
      }

      expect(limiter.stream, emitsInOrder(events));
      expect(callback.calls, 10);
    });
  });

  test('pause below limiter duration', () {
    final limiter = CallbackLimiter(duration: duration);
    final callback = Callback();
    final events0 = [ready, busy, delaying];
    final events = <CallbackControllerState>[];

    final delayinMilliseconds = 38;
    for (var i = 0; i < 10; i++) {
      limiter.run(callback.call);
      sleep(Duration(milliseconds: delayinMilliseconds));
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
  });

  group('Repeated delayed async runs:', () {
    test('pause exceeding limiter duration', () async {
      final limiter = CallbackLimiter(duration: duration);
      final callback = Callback();
      final events0 = [ready, busy, delaying];
      final events = <CallbackControllerState>[];
      for (var i = 0; i < 10; i++) {
        await limiter.runAsync(callback.callAsync);
        sleep(Duration(milliseconds: 100));
        events.addAll(events0);
      }

      expect(limiter.stream, emitsInOrder(events));
      expect(callback.calls, 10);
    });
  });

  test('pause below limiter duration', () async {
    final limiter = CallbackLimiter(duration: duration);
    final callback = Callback();
    final events0 = [ready, busy, delaying];
    final events = <CallbackControllerState>[];

    final delayinMilliseconds = 38;
    for (var i = 0; i < 10; i++) {
      await limiter.runAsync(callback.callAsync);
      sleep(Duration(milliseconds: delayinMilliseconds));
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
  });
}
