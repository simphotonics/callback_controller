## 1.0.0
- Required Dart SDK ^3.13.0.
- Using primary constructor syntax.
- Changed the signature of the methods `run` and `runAsync` provided by
  the class `CallbackController`, eliminating `FutureOr`. The methods now
  return `void` and `Future<void>`, respectively. The methods
  expect a callback of type `void Function()` and `Future<void> Function()`,respectively.

## 0.0.3
Amended docs.

## 0.0.2
Fixed a bug in [CallbackLimiter], by introducing a Timer that sets the state
[ready].

## 0.0.1
Initial version.


[CallbackLimiter]: https://pub.dev/documentation/callback_controller/latest/callback_controller/CallbackLimiter-class.html

[ready]:https://pub.dev/documentation/callback_controller/latest/callback_controller/ready-constant.html