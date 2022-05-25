# Simple chat server application written with dart.

*I created this application just to learn dart programming, so its architecture may not be reasonable.*

This is a chat server application.
The features are explained below.

## Get started

### Prerequisites

* dart sdk (version >= 2.17.1)

### Development

Get dependencies.
```shell
dart pub get
```

Run builder to generate json serializer codes when you modified the models annoted with json serializer or adding one.
```
dart run build_runner build
```
For details, check https://pub.dev/packages/json_serializable.

Run the app with mock.
```
export MOCK=1
dart --no-sound-null-safety run bin/main.dart
```

For the sample web application, open 'http://127.0.0.1:8080/' with the browser.

The web server uses the following ports by default.
* 8080 (web server serving static files and standard web api)
* 8081 (websocket)

You can change to other ports by setting the following environment variables.
* PORT_WEB
* PORT_WEBSOCKET

## Run test codes

```dart test```

## Generate the documentations.

Generates the documentations into doc directory.
```dart doc```