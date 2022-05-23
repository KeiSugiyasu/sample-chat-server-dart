import 'package:database/database.dart';
import 'package:database_adapter_postgre/database_adapter_postgre.dart';
import '../utils/extensions.dart';
import '../models/models.dart';

/// Helper object for DAO.
class DaoHelper {
  /// Convert [ChatItem] to Map<String, String>
  static Map<String, String> chatItemtoMap(ChatItem chatItem) {
    final item = chatItem.toJson();
    item['updated'] = item['updated'].toString();
    return item as Map<String, String>;
  }

  /// Covert Map<String, String> to [ChatItem].
  static ChatItem mapToChatItem(Map<String, String> map) {
    final Map<String, dynamic> item = Map.from(map);
    item['updated'] = (item['updated'] as String).toDateTime();
    return ChatItem.fromJson(item);
  }
}

/// DAO abstract base class.
abstract class Dao {
  /// Return chat items.
  Future<List<ChatItem>> getChatItems(DateTime? from);

  /// Add a chat item.
  Future<void> addChatItem(ChatItem chatItem);
}

/// Database implementation of [Dao].
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

/// Mock implementation of [Dao].
///
/// It stores chat cata in memory.
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
