import 'package:database/database.dart';
import 'package:database_adapter_postgre/database_adapter_postgre.dart';

import '../models/models.dart';

class DaoHelper {
  static Map<String, String> chatItemtoMap(ChatItem chatItem) => {
        "name": chatItem.name,
        "comment": chatItem.comment,
        "updated": chatItem.updated.toString()
      };

  static ChatItem mapToChatItem(Map<String, String> map) => ChatItem(
      name: map["name"]!,
      comment: map["comment"]!,
      updated: DateTime.parse(map["updated"]!));
}

abstract class Dao {
  Future<List<ChatItem>> getChatItems(DateTime? from);

  Future<void> addChatItem(ChatItem chatItem);
}

class DaoImpl implements Dao {
  final Database database;

  static const TABLE_CHAT_ITEMS = "chat_items";

  DaoImpl(
      {required String host,
      required int port,
      required String user,
      required String password,
      required String dbName})
      : database = Postgre(
          host: host,
          user: user,
          port: port,
          password: password,
          databaseName: dbName,
        ).database();

  @override
  Future<List<ChatItem>> getChatItems(DateTime? from) async {
    final query = database.sqlClient.table(TABLE_CHAT_ITEMS);

    if (from != null) {
      query.whereSql('updated > ?', [from]);
    }

    return query
        .descending('updated')
        .select(columnNames: ['name', 'comment', 'updated'])
        .toMaps()
        .then((records) {
          return records
              .map((record) => DaoHelper.mapToChatItem({
                    'name': record['name']!.toString(),
                    'comment': record['comment']!.toString(),
                    'updated': record['updated']!.toString()
                  }))
              .toList();
        });
  }

  @override
  Future<void> addChatItem(ChatItem chatItem) async {
    return database.sqlClient
        .table(TABLE_CHAT_ITEMS)
        .insert(DaoHelper.chatItemtoMap(chatItem))
        .then((result) => result.affectedRows);
  }
}

class DaoMock implements Dao {
  final chatItems = List<ChatItem>.empty(growable: true);

  @override
  Future<List<ChatItem>> getChatItems(DateTime? from) async {
    return from == null
        ? chatItems
        : chatItems.sublist(
            chatItems.indexWhere((data) => data.updated!.compareTo(from!) > 0));
  }

  @override
  Future<void> addChatItem(ChatItem chatItem) async {
    chatItems.add(chatItem);
  }
}
