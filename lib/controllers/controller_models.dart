/// Models used mainly by the controllers.
///
/// So, the models here are used for input or output for client-server communications.

import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'controller_models.g.dart';

/// Response format.
@JsonSerializable()
class ResponseBody {
  final Map<String, dynamic> data;

  const ResponseBody({required this.data});

  static ResponseBody fromJson(Map<String, dynamic> json) =>
      _$ResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseBodyToJson(this);
}

/// Error response format.
class ErrorResponseBody {
  final String message;
  final String? details;

  ErrorResponseBody(this.message, {this.details});

  get body {
    final error = {'message': message};
    final errorDetails = details != null ? {'details': details} : {};

    return {
      'error': {...error, ...errorDetails}
    };
  }
}

/// WebSocket message format.
@JsonSerializable()
class WebSocketMessage {
  final WebSocketMessageType type;
  final Map<String, dynamic> data;

  const WebSocketMessage({required this.type, required this.data});

  static WebSocketMessage fromJson(Map<String, dynamic> json) =>
      _$WebSocketMessageFromJson(json);

  Map<String, dynamic> toJson() => _$WebSocketMessageToJson(this);

  String toTransferFormat() => jsonEncode(this);
}

/// WebSocket message types.
enum WebSocketMessageType {
  // from client
  getComments,
  addComment,
  // from server
  updated,
  comments
}
