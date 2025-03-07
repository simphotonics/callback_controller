
# Callback Controller

[![Dart](https://github.com/simphotonics/callback_controller/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/callback_controller/actions/workflows/dart.yml)


## Introduction

Functions that include e.g. network calls, database queries, writing/reading
local data, have the potential
of compromising the usability of an app or program by slowing it down
considerably.

In many situations, it makes sense to restrict frequent calls to such
functions. The package introduced here, provides the eponymous
class [`CallbackController`][CallbackController] that can be used to limit the number of times a
callback is executed. When limiting the number of times a function is called there a two commonly used
strategies:
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
type [`CallbackControllerState][CallbackControllerState]. The stream can be used
with Flutter's [StreamBuilder] to create responsive widgets. For example, a
button could be styled differently if the current callback controller *state* is
[ready][ready], [busy][busy], or [delaying][delaying].

### Limiting Function Calls

Defining a callback controller:

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
is configured to delay subsequent calls by at least 200 milliseconds.

<details> <summary> Click to show the entire program listing. </summary>

```Dart
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
        'Step $i -------------------------- ${DateTime.now().smsus} ----'
        '-------');
    limiter.run(() {
      print('    in callback from step $i: ${limiter.currentState}');
    });
    await Future.delayed(Duration(milliseconds: 100));
  }
}
```
</details>
<details> <summary> Click to show the console output. </summary>

```Console
$ dart bin/limiter_example.dart
Example: Callback delayer with duration: 200 ms
                  delay between calls:   100 ms

Step 0 -------------------------- 9s:322ms:442us -----------
    in callback from step 0: busy 9s:325ms:711us
    > stream event: ready
    > stream event: busy
    > stream event: delaying
Step 1 -------------------------- 9s:434ms:902us -----------
Step 2 -------------------------- 9s:537ms:329us -----------
    in callback from step 2: busy 9s:537ms:732us
    > stream event: ready
    > stream event: busy
    > stream event: delaying
Step 3 -------------------------- 9s:639ms:426us -----------
Step 4 -------------------------- 9s:740ms:443us -----------
    in callback from step 4: busy 9s:740ms:799us
    > stream event: ready
    > stream event: busy
    > stream event: delaying

```
</details>

Note that there is a delay of 100 milliseconds
between subsequent callback runs.
As the console output shows, the callback is run immediately in step 0,
and then again in step 2 after a delay of 212 milliseconds,
and in step 4, after a delay of 203 milliseconds.


### Delaying and Limiting Function Calls

The example below shows how to *delay* and limit the number of function calls
using a controller of type [`CallbackDelayer`][CallbackDelayer].

<details> <summary> Click to show the entire program listing. </summary>

```Dart
import 'dart:async';

import 'package:callback_controller/callback_controller.dart';

Future<void> main(List<String> arguments) async {
  print('Example: Callback delayer with duration: 200 ms');
  print('                  delay between calls:   100 ms');
  print(' ');

  final delayer = CallbackLimiter(duration: Duration(milliseconds: 200));

  // ignore: unused_local_variable
  final subscription = delayer.stream.listen(
    (event) => print('    > stream event: $event'),
    onDone: () => print('Done'),
    onError: (error) => print(error),
  );

  for (var i = 0; i < 5; i++) {
    print(
        'Step $i -------------------------- ${DateTime.now().smsus} ----'
        '-------');
    delayer.run(() {
      print('    in callback from step $i: ${delayer.currentState}');
    });
    await Future.delayed(Duration(milliseconds: 100));
  }
}
```
</details>
<details> <summary> Click to show the console output. </summary>

```Console
$ dart bin/delayer_example.dart
Example: Callback delayer with duration: 200 ms
                  delay between calls:   100 ms

Step 0 -------------------------- 31s:238ms:322us -----------
    > stream event: ready
    > stream event: delaying
Step 1 -------------------------- 31s:352ms:356us -----------
    in callback from step 1: busy 31s:447ms:234us
    > stream event: busy
    > stream event: ready
Step 2 -------------------------- 31s:453ms:446us -----------
    > stream event: delaying
Step 3 -------------------------- 31s:554ms:423us -----------
    in callback from step 3: busy 31s:654ms:410us
    > stream event: busy
    > stream event: ready
Step 4 -------------------------- 31s:655ms:617us -----------
    > stream event: delaying
    in callback from step 4: busy 31s:856ms:396us
    > stream event: busy
    > stream event: ready
```
</details>

The program above includes a loop in which a callback is run five times.
The actual callback is passed to the method `delayer.run` and the controller
is configured to delay subsequent calls by at least 200 milliseconds. Note that
there is a delay of 100 milliseconds between subsequent calls.
As the console output shows, the callback is *not* run in step 0.
Instead, it is called in step 1 after a delay of 209 ms. The callback is run
again in step 3 after a delay of 207 ms. The callback is also run after
step 4 following a delay of 202 milliseconds.

## Examples

For further information see [example].

## Features and bugs

Please file feature requests and bugs at the [issue tracker].


<!-- Links -->

[issue tracker]: https://github.com/simphotonics/callback_controller/issues

[example]: https://github.com/simphotonics/callback_controller/tree/main/example

[callback_controller]: https://pub.dev/packages/callback_controller

[CallbackController]: https://pub.dev/documentation/callback_controller/latest/callback_controller/CallbackController-class.html

[CallbackLimiter]: https://pub.dev/documentation/callback_controller/latest/callback_controller/CallbackLimiter-class.html

[CallbackDelayer]: https://pub.dev/documentation/callback_controller/latest/callback_controller/CallbackDelayer-class.html