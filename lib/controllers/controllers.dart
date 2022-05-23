import 'dart:convert';
import 'package:sample_chart_app_server_dart_proj/controllers/controller_models.dart';
import 'package:sample_chart_app_server_dart_proj/services/services.dart';
import 'package:shelf/shelf.dart';
import '../dao/dao.dart';
import '../models/models.dart';
import '../utils/extensions.dart';

/// Controller for the normal http request.
class Controller {
  final Services services;
  final Dao dao;

  Controller({required this.services, required this.dao});

  /// Return chat items.
  ///
  /// If [request] contains 'from' parameter, the items created after 'from' time are returned.
  Future<Response> listItems(Request request) async {
    final body = JsonDecoder().convert(await request.readAsString());
    final from = body['data']?['from'] as String?;
    final chats = await services.getChatItems(from: from?.toDateTime());
    return ResponseHelper.standardJsonResponse(
        body: ResponseBody(data: {
      'from': from,
      'items': chats.map((record) => record.toJson()).toList()
    }).toJson());
  }

  /// Add a chat item.
  ///
  /// [request] should contain parameters name and comment.
  Future<Response> addItem(Request request) async {
    // TODO valiate request parameter
    final body = JsonDecoder().convert(await request.readAsString());
    await services.addChatItem(ChatItem.fromJson(body), isPublish: true);
    return ResponseHelper.standardJsonResponse();
  }
}

/// Helper for creating response.
class ResponseHelper {
  static Response standardJsonResponse(
      {Map? body, Map<String, String> headers = const {}}) {
    return Response.ok(
      body != null ? JsonEncoder.withIndent('').convert(body) : '{}',
      headers: {
        ...headers,
        ...{
          'content-type': 'application/json',
          'Cache-Control': 'none',
        }
      },
    );
  }
}
