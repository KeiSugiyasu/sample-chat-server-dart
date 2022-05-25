import 'package:sample_chart_app_server_dart_proj/dao/chat_pubsub.dart';
import 'package:sample_chart_app_server_dart_proj/dao/pubsub_models.dart';
import 'package:test/test.dart';

void main() {
  group('ChatPubsubMock', _TestMock().main);
}

/// Test for ChatPubsubMock
class _TestMock {
  final message = PubsubMessage(
      type: PubsubMessageType.chatUpdated, data: {'test': 'test message'});
  final message2 = PubsubMessage(
      type: PubsubMessageType.chatUpdated, data: {'test2': 'test message2'});

  main() {
    group('publish and subscribe', _publishAndSubscribe);
    group('unsubscribe', _unsubscribe);
  }

  /// Test for the publish and subscribe functions.
  _publishAndSubscribe() {
    late ChatPubsub chatPubsub;
    setUp(() async {
      chatPubsub = ChatPubsubMock();
    });

    test('It can publish if there are no subscribers.', () async {
      await chatPubsub.publish(message);
    });

    test(
        'If there is one subscriber, its callback function is called and passed the published message.',
        () async {
      await chatPubsub.subscribe(expectAsync1((PubsubMessage _message) {
        expect(_message, equals(message));
      }));
      await chatPubsub.publish(message);
    });

    test(
        'If there are two subscribers, each callback function is called and passed the published message.',
        () async {
      await chatPubsub.subscribe(expectAsync1((PubsubMessage _message) {
        expect(_message, equals(message));
      }));
      await chatPubsub.subscribe(expectAsync1((PubsubMessage _message) {
        expect(_message, equals(message));
      }));
      chatPubsub.publish(message);
    });

    test(
        'When messages are published N times, the callback function is called N times.',
        () async {
      await chatPubsub.subscribe(expectAsync1((PubsubMessage _message) {
        expect(_message, equals(message));
      }, count: 3));
      for (var _ in List.filled(3, 0)) {
        chatPubsub.publish(message);
      }
    });

    test(
        'When the different two messages are published, the subscribers get exactly the same two messages.',
        () async {
      var count = 0;
      await chatPubsub.subscribe(expectAsync1((PubsubMessage _message) {
        switch (count) {
          case 0:
            {
              expect(_message, equals(message));
            }
            break;
          case 1:
            expect(_message, equals(message2));
        }
        count++;
      }, count: 2));
      chatPubsub.publish(message);
      chatPubsub.publish(message2);
    });
  }

  /// Test for the unsubscribe function.
  _unsubscribe() {
    late ChatPubsub chatPubsub;
    setUp(() async {
      chatPubsub = ChatPubsubMock();
    });

    test('Unsubscribing without subscribing doesn\'t cause error.', () async {
      await chatPubsub.unsubscribe('test');
      await chatPubsub.subscribe((data) {});
      await chatPubsub.unsubscribe('test');
    });

    test('Duplicate unsubscribing doesn\'t cause error', () async {
      final subscriberId = await chatPubsub.subscribe((data) {});
      for (var _ in List.filled(2, 0)) {
        await chatPubsub.unsubscribe(subscriberId);
      }
    });

    test(
        'After unsubscribing, the callback function won\'t be called any more.',
        () async {
      final subscriberId =
          await chatPubsub.subscribe(expectAsync1((PubsubMessage _message) {
        expect(_message, equals(message));
      }));
      await chatPubsub.publish(message);
      chatPubsub.unsubscribe(subscriberId);
      await chatPubsub.publish(message);
    });

    test(
        'When the subscriber unsubscribes, other subscribers are still subscribing.',
        () async {
      final subscriberId =
          await chatPubsub.subscribe(expectAsync1((PubsubMessage _message) {
        expect(_message, equals(message));
      }));
      await chatPubsub.subscribe(expectAsync1((PubsubMessage _message) {
        expect(_message, equals(message));
      }, count: 2));
      await chatPubsub.subscribe(expectAsync1((PubsubMessage _message) {
        expect(_message, equals(message));
      }, count: 2));
      await chatPubsub.publish(message);
      chatPubsub.unsubscribe(subscriberId);
      await chatPubsub.publish(message);
    });
  }
}
