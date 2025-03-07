import 'dart:async';

import 'package:callback_controller/callback_controller.dart';

Future<void> main(List<String> arguments) async {
  print('Example: Callback limiter with duration: 200 ms');
  print('                  delay between calls:   100 ms');
  print(' ');

  final limiter = CallbackLimiter(duration: Duration(milliseconds: 200));

  // ignore: unused_local_variable
  final subscription = limiter.stream.listen(
    (event) => print('    > stream event: $event'),
    onDone: () => print('Done'),
    onError: (error) => print(error),
  );

  for (var i = 0; i < 5; i++) {
    print(
        'Step $i -------------------------- ${DateTime.now().smsus} -----------');
    limiter.run(() {
      print('    in callback from step $i: ${limiter.currentState}');
    });
    await Future.delayed(Duration(milliseconds: 100));
  }

  // await delayer.close();
  // await subscription.cancel();
}
