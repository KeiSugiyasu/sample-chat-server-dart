import 'dart:convert';
import 'package:sample_chart_app_server_dart_proj/models/models.dart';
import 'package:sample_chart_app_server_dart_proj/services/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../dao/chat_pubsub.dart';
import '../dao/pubsub_models.dart';
import '../utils/logger.dart';
import '../utils/extensions.dart';
import 'controller_models.dart';

/// Return the factory method of [WebSocketController] applying [Services] and [ChatPubsub].
Function createWebSocketHandler(Services services, ChatPubsub chatPubsub) {
  return (channel) => WebSocketController(channel, services, chatPubsub);
}

/// WebSocket connection controller, it listen to client message and subscribe pubsub channels.
class WebSocketController {
  final WebSocketChannel _channel;
  final Services _services;
  final ChatPubsub _chatPubsub;

  WebSocketController(this._channel, this._services, this._chatPubsub) {
    _listen();
    _subscribe();
  }

  /// Listen client messages.
  ///
  /// It works like the routing engine.
  _listen() {
    _channel.stream.listen((message) {
      logger.v("$message received");
      // TODO validate message format
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

  /// Send chat items related to client request ([data]).
  ///
  /// If [data].from is passed, the comments after the specific point are sent, other wise all comments are sent.
  _sendChatItems(Map<String, dynamic>? data) async {
    logger.i("$data");
    final from = data?["from"] as String?;
    final chatItems = await _services.getChatItems(from: from?.toDateTime());
    _channel.sink.add(WebSocketMessage(
        type: WebSocketMessageType.comments,
        data: {'from': from, 'items': chatItems}).toTransferFormat());
  }

  /// Add new chat item received from the client.
  ///
  /// Updates the databaese and publish to pubsub function.
  _addChatItem(Map<String, dynamic>? data) async {
    logger.i("$data");
    // TODO validate message
    final chatItem = ChatItem(name: data!['name']!, comment: data!['comment']!);
    await _services.addChatItem(chatItem, isPublish: true);
    // TODO response
  }

  /// Subscription's callback function.
  ///
  /// This is invoked when something related to it is published.
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

  /// Subscribe pubsub function.
  _subscribe() {
    _chatPubsub.subscribe(_chatUpdateCallback);
  }
}
