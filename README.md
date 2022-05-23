# Simple chat server application written with dart.

*I created this application just to learn dart programming, so its architecture may not be reasonable.*

This is a chat server application.
The features are explained below.


## Prerequisites

* dart sdk (version >= 2.17.1)

## Development

Get dependencies.
```shell
dart pub get
```

Run builder to generate json serializer codes.
```
dart run build_runner build
```
For details, check https://pub.dev/packages/json_serializable.

Run the app with mock.
```
export MOCK=1
dart --no-sound-null-safety run bin/main.dart
```

Open 'http://127.0.0.1:8080/' with the browser.

It uses the following ports by default.
* 8080 (web server)
* 8081 (websocket)

You can change to other ports by setting the following environment variables.
* PORT_WEB
* PORT_WEBSOCKET

## Generate the documentations.

Generates the documentations into doc directory.
```dart doc```