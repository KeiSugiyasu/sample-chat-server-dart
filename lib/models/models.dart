import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

/// Chat item model.
@JsonSerializable()
class ChatItem {
  final String name;
  final String comment;
  final DateTime? updated;

  const ChatItem({required this.name, required this.comment, this.updated});

  ChatItem withUpdated({required DateTime updated}) =>
      ChatItem(name: name, comment: comment, updated: updated);

  Map<String, dynamic> toJson() => _$ChatItemToJson(this);

  static ChatItem fromJson(Map<String, dynamic> json) =>
      _$ChatItemFromJson(json);
}
