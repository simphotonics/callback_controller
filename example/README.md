
# Callback Controller Example

[![Dart](https://github.com/simphotonics/callback_controller/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/callback_controller/actions/workflows/dart.yml)

## Usage

To use this library include [`callback_controller`][callback_controller]
as a dependency in your `pubspec.yaml` file.


[`CallbackController`][CallbackController] exposes a [stream] emitting events of
type [`CallbackControllerState`][CallbackControllerState].
The stream can be used
with Flutter's [StreamBuilder] to create responsive widgets. For example, a
button could be styled differently if the current callback controller *state* is
[ready][ready], [busy][busy], or [delaying][delaying].



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