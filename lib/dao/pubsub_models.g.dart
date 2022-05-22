// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubsub_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubsubMessage _$PubsubMessageFromJson(Map<String, dynamic> json) =>
    PubsubMessage(
      type: $enumDecode(_$PubsubMessageTypeEnumMap, json['type']),
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PubsubMessageToJson(PubsubMessage instance) =>
    <String, dynamic>{
      'type': _$PubsubMessageTypeEnumMap[instance.type],
      'data': instance.data,
    };

const _$PubsubMessageTypeEnumMap = {
  PubsubMessageType.chatUpdated: 'chatUpdated',
};
