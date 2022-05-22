import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'controller_models.g.dart';

@JsonSerializable()
class ResponseBody {
  final Map<String, dynamic> data;

  const ResponseBody({required this.data});

  static ResponseBody fromJson(Map<String, dynamic> json) =>
      _$ResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseBodyToJson(this);
}

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

enum WebSocketMessageType {
  // from client
  getComments,
  addComment,
  // from server
  updated,
  comments
}
