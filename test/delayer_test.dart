import 'package:callback_controller/callback_controller.dart';
import 'package:test/test.dart';

import 'src/callback.dart';

void main() {
  final duration = Duration(milliseconds: 100);
  group('Initialize:', () {
    test('state', () {
      final delayer = CallbackDelayer(duration: duration);
      expect(delayer.current.state.isReady, isTrue);
      expect(delayer.stream, emitsInOrder([ready]));
      expect(delayer.duration, Duration(milliseconds: 100));
    });
  });

  group('Single run:', () {
    test('stream events', () async {
      final delayer = CallbackDelayer(duration: duration);
      final callback = Callback();
      delayer.run(callback.call);
      expect(delayer.stream, emitsInOrder([ready, delaying]));
      expect(callback.calls, 0);
      await delayer.close();
    });
  });

  group('Single async run:', () {
    test('stream events', () async {
      final delayer = CallbackDelayer(duration: duration);
      final callback = Callback();
      await delayer.runAsync(callback.callAsync);
      expect(delayer.stream, emitsInOrder([ready, delaying]));
      expect(callback.calls, 0);
      await delayer.close();
    });
  });

  group('Repeated runs:', () {
    test('stream events', () async {
      final delayer = CallbackDelayer(duration: duration);
      final callback = Callback();
      for (var i = 0; i < 10; i++) {
        delayer.run(callback.call);
      }
      expect(delayer.stream, emitsInOrder([ready, delaying]));
      expect(callback.calls, 0);
      await delayer.close();
    });
  });

  group('Repeated async runs:', () {
    test('stream events', () async {
      final delayer = CallbackDelayer(duration: duration);
      final callback = Callback();
      for (var i = 0; i < 10; i++) {
        await delayer.runAsync(callback.callAsync);
      }
      expect(delayer.stream, emitsInOrder([ready, delaying]));
      expect(callback.calls, 0);
    });
  });

  group('Repeated delayed runs:', () {
    test('pause exceeding delayer duration', () async {
      final delayer = CallbackDelayer(duration: duration);
      final callback = Callback();
      final events0 = [ready, delaying, busy];
      final events = <CallbackControllerState>[];
      for (var i = 0; i < 5; i++) {
        delayer.run(callback.call);
        await Future.delayed(Duration(milliseconds: 120));
        events.addAll(events0);
      }
      await expectLater(delayer.stream, emitsInOrder(events));
      await expectLater(callback.calls, 5);
    });
    test(
      'pause shorter than delayer duration',
      () async {
        final delayer = CallbackDelayer(duration: duration);
        final callback = Callback();
        final events0 = [ready, delaying, busy];
        final events = <CallbackControllerState>[];

        final delayinMilliseconds = 38;
        for (var i = 0; i < 10; i++) {
          delayer.run(callback.call);
          await Future.delayed(Duration(milliseconds: delayinMilliseconds));
        }

        final calls = callback.calls;

        for (var i = 0; i < calls; i++) {
          events.addAll(events0);
        }

        expect(delayer.stream, emitsInOrder(events));
      },
    );
  });

  group('Repeated delayed async runs:', () {
    test('pause exceeding delayer duration', () async {
      final delayer = CallbackDelayer(duration: duration);
      final callback = Callback();
      final events0 = [ready, delaying, busy];
      final events = <CallbackControllerState>[];
      for (var i = 0; i < 5; i++) {
        await delayer.runAsync(callback.callAsync);
        await Future.delayed(Duration(milliseconds: 120));
        events.addAll(events0);
      }
      expect(delayer.stream, emitsInOrder(events));
      expect(callback.calls, 5);
    });
    test('pause below delayer duration', () async {
      final delayer = CallbackDelayer(duration: duration);
      final callback = Callback();
      final events0 = [ready, delaying, busy];
      final events = <CallbackControllerState>[];

      final delayinMilliseconds = 38;
      for (var i = 0; i < 5; i++) {
        await delayer.runAsync(callback.callAsync);
        await Future.delayed(Duration(milliseconds: delayinMilliseconds));
      }

      final calls = callback.calls;

      for (var i = 0; i < calls; i++) {
        events.addAll(events0);
      }
      expect(delayer.stream, emitsInOrder(events));
    });
  });
}
