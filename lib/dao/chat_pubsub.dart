import 'package:sample_chart_app_server_dart_proj/dao/pubsub_models.dart';
import 'package:uuid/uuid.dart';

/// Type of subscriber id
typedef SubscriberId = String;

/// Type of callback function
typedef void PubsubCallback(PubsubMessage data);

/// Simple pubsub feature that supports only one pubsub channel.
///
/// Use it to publish and subscribe for o channel.
abstract class ChatPubsub {
  /// Subscribes [callback] function to the channel and returns new [SubscriberId].
  Future<SubscriberId> subscribe(PubsubCallback callback);

  /// Unsubscribes from the channel.
  Future<void> unsubscribe(SubscriberId id);

  /// Publish a message.
  Future<void> publish(PubsubMessage message);
}

/// Mock of ChatPubsub.
///
/// It works without external resource, but doesn't support multiple web servers.
class ChatPubsubMock implements ChatPubsub {
  final _uuid = Uuid();
  final Map<SubscriberId, PubsubCallback> _subscribes;

  ChatPubsubMock() : _subscribes = {};

  Future<SubscriberId> subscribe(PubsubCallback callback) {
    final id = _uuid.v4();
    _subscribes[id] = callback;
    return Future.value(id);
  }

  Future<void> unsubscribe(SubscriberId id) {
    _subscribes.remove(id);
    return Future.value();
  }

  Future<void> publish(PubsubMessage message) {
    _subscribes.forEach((_, callback) {
      callback(message);
    });
    return Future.value();
  }
}
