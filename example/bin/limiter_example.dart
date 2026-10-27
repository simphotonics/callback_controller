import 'dart:async';

import 'package:callback_controller/callback_controller.dart';

Future<void> main(List<String> arguments) async {
  print('Example: Callback limiter with duration: 1000 ms');
  print('                  delay between calls:   100 ms');
  print(' ');

  final limiter = CallbackLimiter(duration: Duration(milliseconds: 1000));

  // ignore: unused_local_variable
  final subscription = limiter.stream.listen(
    (event) => print(
      '    > stream event: $event'.padRight(30, ' ') +
          DateTime.now().secMillisecMicrosec,
    ),
    onDone: () => print(
      'The delay between stream evens: delaying->ready is approx: 1000 ms.',
    ),
    onError: (error) => print(error),
  );

  for (var i = 0; i < 5; i++) {
    print('Step $i ---------------------------');
    limiter.run(() {
      print('    in callback from step $i: ${limiter.current}');
    });
    await Future.delayed(Duration(milliseconds: 2000), () {
      print('    <= delaying 100 ms');
    });
  }

  await limiter.close();
  await subscription.cancel();
}
