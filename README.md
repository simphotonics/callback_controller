
# Callback Controller

[![Dart](https://github.com/simphotonics/callback_controller/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/callback_controller/actions/workflows/dart.yml)


## Introduction

Functions that require network calls, database queries, or writing/reading
local data, have the potential of slowing down an app or program.
In some situations, it makes sense to restrict frequent calls to such
functions.

The package introduced here, provides the eponymous
class [`CallbackController`][CallbackController] that can be used to limit the
number of times a
callback is executed. When limiting the number of times a function is called
there are two commonly used strategies:
* throttling: Calling the function as soon as possible and then
rejecting subsequent calls for a certain time duration.
This kind of behaviour can be achieved by using the methods
`run` and `runAsync` provided by the class [`CallbackLimiter`][CallbackLimiter].

* debouncing: Starting a countdown timer when a function is called, but
accepting  subsequent calls. After the timer has completed its countdown, the
latest call is finally executed. Debouncing can be achieved using the method
`run` and `runAsync` provided by [`CallbackDelayer`][CallbackDelayer].


## Usage

To use this library include [`callback_controller`][callback_controller]
as a dependency in your `pubspec.yaml` file.


[`CallbackController`][CallbackController] exposes a [stream] emitting events of
type [`CallbackControllerState`][CallbackControllerState].
The stream can be used
with Flutter's [StreamBuilder] to create responsive widgets. For example, a
button could be styled differently if the current callback controller *state* is
[ready][ready], [busy][busy], or [delaying][delaying].

### Limiting Function Calls

To call a function as soon as possible and then
reject subsequent calls for a certain time duration, one can use a controller
of type [`CallbackLimiter`][CallbackLimiter]:

```Dart
import 'dart:async';

import 'package:callback_controller/callback_controller.dart';

void callback(){
  print('In callback');
}

Future<void> main(List<String> arguments) async {
  final duration = Duration(milliseconds: 200);

  // Defining the controller.
  final limiter = CallbackLimiter(duration: duration));

  // Alternatively, use the provided factory constructor:
  // final limiter = CallbackController.limiter(duration: duration));

  // Passing the the callback to the method run of the controller.
  limiter.run(callback);
}
```

The example below shows how to limit the number of function calls using
a controller of type [`CallbackLimiter`][CallbackLimiter].
The program includes a loop in which a callback is run five times.
The actual callback is passed to the method `limiter.run` and the controller
is configured to *delay* subsequent calls by at least 200 milliseconds.

<details> <summary> Click to show the entire program listing. </summary>

```Dart
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
      'The delay between stream events: delaying->ready is approx: 1000 ms.',
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
```
</details>
<details> <summary> Click to show the console output. </summary>

```Console
$ dart example/bin/limiter_example.dart
Example: Callback limiter with duration: 1000 ms
                  delay between calls:   100 ms

Step 0 ---------------------------
    in callback from step 0: busy at 2026-10-27 17:41:18.208671
    > stream event: ready     18s:218ms:084us
    > stream event: busy      18s:218ms:570us
    > stream event: delaying  18s:218ms:613us
    > stream event: ready     19s:222ms:115us
    <= delaying 100 ms
Step 1 ---------------------------
    in callback from step 1: busy at 2026-10-27 17:41:20.228102
    > stream event: busy      20s:228ms:911us
    > stream event: delaying  20s:229ms:185us
    > stream event: ready     21s:229ms:930us
    <= delaying 100 ms
Step 2 ---------------------------
    in callback from step 2: busy at 2026-10-27 17:41:22.229974
    > stream event: busy      22s:230ms:501us
    > stream event: delaying  22s:230ms:783us
    > stream event: ready     23s:231ms:904us
    <= delaying 100 ms
Step 3 ---------------------------
    in callback from step 3: busy at 2026-10-27 17:41:24.232031
    > stream event: busy      24s:232ms:589us
    > stream event: delaying  24s:232ms:759us
    > stream event: ready     25s:233ms:818us
    <= delaying 100 ms
Step 4 ---------------------------
    in callback from step 4: busy at 2026-10-27 17:41:26.233879
    > stream event: busy      26s:234ms:295us
    > stream event: delaying  26s:234ms:579us
    > stream event: ready     27s:234ms:928us
    <= delaying 100 ms
The delay between stream evens: delaying->ready is approx: 1000 ms.
```
</details>


### Delaying and Limiting Function Calls

The example below shows how to *delay and limit* the number of function calls
using a controller of type [`CallbackDelayer`][CallbackDelayer]. A callback
delayer can be used, for example, to wrap the [`onChanged`][onChanged]
method of a Flutter [`TextField`][TextField]. Ths will allow the user to type
for a certain duration before [`onChanged`][onChanged] is called.

<details> <summary> Click to show the entire program listing. </summary>

```Dart
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
      'The function passed to delayer.run is called at'
      'most once every 1000 ms. ',
    ),
    onError: (error) => print(error),
  );

  for (var i = 0; i < 5; i++) {
    print('Step $i -------------------------');
    delayer.run(() {
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
```
</details>
<details> <summary> Click to show the console output. </summary>

```Console
$ dart example/bin/delayer_example.dart
Example: CallbackDelayer with delay: 1000 ms
            User delay between calls: 300 ms

Step 0 -------------------------
    > stream event: ready     53s:844ms:291us
    > stream event: delaying  53s:847ms:838us
Step 1 -------------------------
Step 2 -------------------------
Step 3 -------------------------
    in callback from step 3: busy  54s:840ms:112us
    > stream event: busy      54s:844ms:111us
    > stream event: ready     54s:845ms:518us
Step 4 -------------------------
    > stream event: delaying  55s:063ms:448us
The function passed to delayer.run is called atmost once every 1000 ms.
```
</details>

The program above includes a loop in which a callback is run five times.
The actual callback is passed to the method `delayer.run` and the controller
is configured to delay subsequent calls by at least 1000 milliseconds. Note that
there is a delay of 300 milliseconds between subsequent calls.
As the console output shows, the callback is *not* run in step 0.
Instead, it is called in step 3 after a delay of 1000 ms. 

## Examples

For further information see [example].

## Features and bugs

Please file feature requests and bugs at the [issue tracker].


<!-- Links -->

[issue tracker]: https://github.com/simphotonics/callback_controller/issues

[example]: https://github.com/simphotonics/callback_controller/tree/main/example

[callback_controller]: https://pub.dev/packages/callback_controller

[CallbackController]: https://pub.dev/documentation/callback_controller/latest/callback_controller/CallbackController-class.html

[CallbackControllerState]: https://pub.dev/documentation/callback_controller/latest/callback_controller/CallbackControllerState.html

[CallbackLimiter]: https://pub.dev/documentation/callback_controller/latest/callback_controller/CallbackLimiter-class.html

[CallbackDelayer]: https://pub.dev/documentation/callback_controller/latest/callback_controller/CallbackDelayer-class.html

[stream]: https://pub.dev/documentation/callback_controller/latest/callback_controller/CallbackController/stream.html

[StreamBuilder]: https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html

[ready]:https://pub.dev/documentation/callback_controller/latest/callback_controller/ready-constant.html

[busy]: https://pub.dev/documentation/callback_controller/latest/callback_controller/busy-constant.html

[delaying]:https://pub.dev/documentation/callback_controller/latest/callback_controller/delaying-constant.html

[TextField]: https://api.flutter.dev/flutter/material/TextField-class.html

[onChanged]:  https://api.flutter.dev/flutter/material/TextField/onChanged.html