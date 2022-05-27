// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'controller_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseBody _$ResponseBodyFromJson(Map<String, dynamic> json) => ResponseBody(
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ResponseBodyToJson(ResponseBody instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

WebSocketMessage _$WebSocketMessageFromJson(Map<String, dynamic> json) =>
    WebSocketMessage(
      type: $enumDecode(_$WebSocketMessageTypeEnumMap, json['type']),
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$WebSocketMessageToJson(WebSocketMessage instance) =>
    <String, dynamic>{
      'type': _$WebSocketMessageTypeEnumMap[instance.type],
      'data': instance.data,
    };

const _$WebSocketMessageTypeEnumMap = {
  WebSocketMessageType.getComments: 'getComments',
  WebSocketMessageType.addComment: 'addComment',
  WebSocketMessageType.updated: 'updated',
  WebSocketMessageType.comments: 'comments',
  WebSocketMessageType.invalid: 'invalid',
};
