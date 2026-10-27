import 'dart:async';

import 'package:callback_controller/callback_controller.dart';

Future<void> main(List<String> arguments) async {
  print('Example: CallbackDelayer with delay: 1000 ms');
  print('            User delay between calls: 300 ms');
  print(' ');

  final delayer = CallbackDelayer(duration: Duration(milliseconds: 1000));

  // ignore: unused_local_variable
  final subscription = delayer.stream.listen(
    (event) => print(
      '    > stream event: $event'.padRight(30, ' ') +
          DateTime.now().secMillisecMicrosec,
    ),
    onDone: () => print(
      'The function passed to delayer.runAsync is called at'
      'most once every 1000 ms. ',
    ),
    onError: (error) => print(error),
  );

  for (var i = 0; i < 5; i++) {
    print('Step $i -------------------------');
    await delayer.runAsync(() async {
      print(
        '    in callback from step $i: ' +
            delayer.current.state.toString() +
            '  ' +
            delayer.current.dateTimeStamp.secMillisecMicrosec,
      );
    });
    await Future.delayed(Duration(milliseconds: 300));
  }

  await delayer.close();
  await subscription.cancel();
}
