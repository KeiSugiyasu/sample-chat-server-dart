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
      late final WebSocketMessage webSocketMessage;
      try {
        webSocketMessage = WebSocketMessage.fromJson(JsonDecoder().convert(message));
      } catch (e) { // format error
        _notifyInvalidMessage(message);
        return;
      }
      if (webSocketMessage.type == WebSocketMessageType.getComments) {
        // request latest comments
        _sendChatItems(webSocketMessage.data);
      } else if (webSocketMessage.type == WebSocketMessageType.addComment) {
        // request add comment
        _addChatItem(webSocketMessage.data);
      } else { // message type is invalid
        _notifyInvalidMessage(message);
      }
    });
  }

  /// Notify the client of the invalid message.
  ///
  /// [message] helps client to notice the details.
  _notifyInvalidMessage(String message) async {
    logger.i("invalid message: $message");
    _channel.sink.add(WebSocketMessage(
        type: WebSocketMessageType.invalid,
        data: {'message': message}).toTransferFormat());
  }

  /// Send chat items related to client request ([data]).
  ///
  /// If [data].from is passed, the comments after the specific point are sent, other wise all comments are sent.
  _sendChatItems(Map<String, dynamic>? data) async {
    logger.i("$data");
    late final DateTime? from;
    try {
      from = (data?["from"] as String?)?.toDateTime();
    } catch (e) {
      _notifyInvalidMessage(jsonEncode(data));
      return;
    }
    final chatItems = await _services.getChatItems(from: from);
    _channel.sink.add(WebSocketMessage(
        type: WebSocketMessageType.comments,
        data: {'from': from.toString(), 'items': chatItems}).toTransferFormat());
  }

  /// Add new chat item received from the client.
  ///
  /// Updates the databaese and publish to pubsub function.
  _addChatItem(Map<String, dynamic>? data) async {
    logger.i("$data");
    late final ChatItem chatItem;
    try {
      chatItem = ChatItem.fromJson(data!);
    } catch (e) {
      _notifyInvalidMessage(jsonEncode(data));
      return;
    }
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
