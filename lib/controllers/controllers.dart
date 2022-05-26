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
    late final DateTime? from;
    try {
      from = (JsonDecoder().convert(await request.readAsString())['from'] as String?)?.toDateTime();
    } on Exception {
      return ResponseHelper.badRequestJsonResponse();
    }
    final chats = await services.getChatItems(from: from);
    return ResponseHelper.standardJsonResponse(
        body: ResponseBody(data: {
      'from': from.toString(),
      'items': chats.map((record) => record.toJson()).toList()
    }).toJson());
  }

  /// Add a chat item.
  ///
  /// [request] should contain parameters name and comment.
  Future<Response> addItem(Request request) async {
    late final ChatItem chatItem;
    try {
      chatItem = ChatItem.fromJson(JsonDecoder().convert(await request.readAsString()));
    } on Exception {
      return ResponseHelper.badRequestJsonResponse();
    }
    await services.addChatItem(chatItem, isPublish: true);
    return ResponseHelper.standardJsonResponse();
  }

  /// Handle cases routes are not found.
  Future<Response> notFound(Request request) async {
    return ResponseHelper.standardErrorJsonResponse(Response.notFound, body: ErrorResponseBody("notFound"));
  }
}

/// Helper for creating response.
class ResponseHelper {
  static final Map<String, String> commonHeaders = {'content-type': 'application/json',};

  /// Response helper for standard json format response.
  static Response standardJsonResponse(
      {Map? body, Map<String, String> headers = const {}}) {
    return Response.ok(
      body != null ? JsonEncoder().convert(body) : '{}',
      headers: {
        ...commonHeaders,
        ...{
          'Cache-Control': 'none',
        },
        ...headers,
      },
    );
  }

  /// Response helper for standard error json format response.
  ///
  /// Examples of [responseFunctions] are [Response.notFound] and [Response.internalServerError].
  static Response standardErrorJsonResponse(Function(
      Object? body, {
        Map<String, Object>? headers,
        Encoding? encoding,
        Map<String, Object>? context,
      }) responseFunction, {required ErrorResponseBody body, Map<String, String> headers = const {}}) {
    return responseFunction(JsonEncoder().convert(body.body), headers: {...commonHeaders, ...headers});
  }

  /// Response helper for 400 Bad Request.
  static Response badRequestJsonResponse({String? details}) {
    return Response.badRequest(body: JsonEncoder().convert(ErrorResponseBody("BadRequest", details:details).body));
  }
}
