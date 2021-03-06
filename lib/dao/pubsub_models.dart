import 'package:json_annotation/json_annotation.dart';

part 'pubsub_models.g.dart';

/// Pubsub message format.
@JsonSerializable()
class PubsubMessage {
  final PubsubMessageType type;
  final Map<String, dynamic> data;

  const PubsubMessage({required this.type, required this.data});

  static PubsubMessage fromJson(Map<String, dynamic> json) =>
      _$PubsubMessageFromJson(json);

  Map<String, dynamic> toJson() => _$PubsubMessageToJson(this);
}

/// Pubsub message type.
enum PubsubMessageType { chatUpdated }
