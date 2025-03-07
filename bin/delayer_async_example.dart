import 'dart:async';

import 'package:callback_controller/callback_controller.dart';

Future<void> main(List<String> arguments) async {
  print('Example: Callback delayer with duration: 100 ms');
  print('                  delay between calls:    25 ms');
  print(' ');

  final delayer = CallbackDelayer(duration: Duration(milliseconds: 200));

  // ignore: unused_local_variable
  final subscription = delayer.stream.listen(
    (event) => print('       > stream event: $event'),
    onDone: () => print('Done'),
    onError: (error) => print(error),
  );

  for (var i = 0; i < 5; i++) {
    print('Step $i ----------------- ${DateTime.now().smsus} -----------');
    await delayer.runAsync(() async {
      Future.delayed(Duration(milliseconds: 125), () {
        print('    \\$i/  in callback: ${delayer.current}');
      });
    });
    await Future.delayed(Duration(milliseconds: 150));
  }

  // await delayer.close();
  // await subscription.cancel();
}
