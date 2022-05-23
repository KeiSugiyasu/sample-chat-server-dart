import 'package:sample_chart_app_server_dart_proj/dao/pubsub_models.dart';
import '../dao/chat_pubsub.dart';
import '../dao/dao.dart';
import '../models/models.dart';
import '../utils/logger.dart';

/// Business logic.
///
class Services {
  final Dao dao;
  final ChatPubsub pubsub;

  Services(this.dao, this.pubsub);

  /// Return chat items.
  Future<List<ChatItem>> getChatItems({DateTime? from}) {
    return dao.getChatItems(from);
  }

  /// Add chat item and publish to the pubsub channel.
  Future<void> addChatItem(ChatItem chatItem, {isPublish = false}) async {
    await dao.addChatItem(chatItem.withUpdated(chatItem));
    if (isPublish) {
      final message = PubsubMessage(
          type: PubsubMessageType.chatUpdated, data: chatItem.toJson());
      await pubsub.publish(message);
      logger.v("${message} published");
    }
    return Future.value();
  }
}
