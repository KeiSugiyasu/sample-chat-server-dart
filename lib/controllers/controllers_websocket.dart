import 'dart:convert';
import 'package:sample_chart_app_server_dart_proj/models/models.dart';
import 'package:sample_chart_app_server_dart_proj/services/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../dao/chat_pubsub.dart';
import '../dao/pubsub_models.dart';
import '../utils/logger.dart';
import 'controller_models.dart';

/// WebSocket connection controller, it listens and subscribe pubsub channels.
class WebSocketController {
  final WebSocketChannel _channel;
  final Services _services;
  final ChatPubsub _chatPubsub;

  static Function createWebSocketHandler(
      Services services, ChatPubsub chatPubsub) {
    return (channel) => WebSocketController(channel, services, chatPubsub);
  }

  WebSocketController(this._channel, this._services, this._chatPubsub) {
    _listen();
    _subscribe();
  }

  /// Subscription's callback
  void _chatUpdateCallback(PubsubMessage message) {
    logger.i("$message");
    switch (message.type) {
      case PubsubMessageType.chatUpdated:
        {
          _channel.sink.add(
              WebSocketMessage(type: WebSocketMessageType.updated, data: {})
                  .toTransferFormat());
        }
        break;
    }
  }

  /// Subscribe
  _subscribe() {
    _chatPubsub.subscribe(_chatUpdateCallback);
  }

  /// Listen client messages
  _listen() {
    _channel.stream.listen((message) {
      logger.v("$message received");
      final webSocketMessage =
          WebSocketMessage.fromJson(JsonDecoder().convert(message));
      if (webSocketMessage.type == WebSocketMessageType.getComments) {
        // request latest comments
        _sendChatItems(webSocketMessage.data);
      } else if (webSocketMessage.type == WebSocketMessageType.addComment) {
        // request add comment
        _addChatItem(webSocketMessage.data);
      }
    });
  }

  /// Send chat items related to client requet.
  _sendChatItems(Map<String, dynamic>? data) async {
    logger.i("$data");
    final from = data?["from"];
    final chatItems = await _services.getChatItems(
        from: from != null ? DateTime.parse(from) : null);
    _channel.sink.add(WebSocketMessage(
        type: WebSocketMessageType.comments,
        data: {'from': from, 'items': chatItems}).toTransferFormat());
  }

  /// Add new chat item received from the client.
  ///
  /// Updates databaes and publish to pubsub.
  _addChatItem(Map<String, dynamic>? data) async {
    logger.i("$data");
    final chatItem = ChatItem(name: data!['name']!, comment: data!['comment']!);
    await _services.addChatItem(chatItem, isPublish: true);
    // TODO response
  }
}
