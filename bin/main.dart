import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:sample_chart_app_server_dart_proj/controllers/controllers_websocket.dart';
import 'package:sample_chart_app_server_dart_proj/dao/chat_pubsub.dart';
import 'package:sample_chart_app_server_dart_proj/services/services.dart';
import 'package:sample_chart_app_server_dart_proj/utils/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

import 'package:sample_chart_app_server_dart_proj/controllers/controllers.dart';
import 'package:sample_chart_app_server_dart_proj/dao/dao.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

final getIt = GetIt.instance;

Future main() async {
  setupDI();
  setupServer();
  setupWebSocketServer();
}

Future<void> setupServer() async {
  final controller = Controller(services: getIt<Services>(), dao: getIt<Dao>());
  final staticHandler =
      shelf_static.createStaticHandler('public', defaultDocument: 'index.html');
  final router = shelf_router.Router()
    ..post('/api/chat/', controller.listItems)
    ..put('/api/chat/', controller.addItem);

  final cascade = Cascade().add(staticHandler).add(router);

  final port = int.parse(Platform.environment['PORT_WEB'] ?? '8080');
  final server = await shelf_io.serve(
      logRequests().addHandler(cascade.handler),
      InternetAddress.loopbackIPv4, // allow internal access only
      port,
      shared: true);
  logger.i('Serving at http://${server.address.host}:${server.port}');
}

Future<void> setupWebSocketServer() async {
  final webSocketPort =
      int.parse(Platform.environment['PORT_WEBSOCKET'] ?? '8081');
  final handlerWebSocket = webSocketHandler(
      WebSocketController.createWebSocketHandler(
          getIt<Services>(), getIt<ChatPubsub>()),
      pingInterval: Duration(seconds: 30));

  final webSocketServer = await shelf_io.serve(
      handlerWebSocket, InternetAddress.loopbackIPv4, webSocketPort,
      shared: true);
  logger.i(
      'Serving at ws://${webSocketServer.address.host}:${webSocketServer.port}');
}

void setupDI() {
  if (Platform.environment['MOCK'] != null) {
    getIt.registerSingleton<Dao>(DaoMock());
  } else {
    getIt.registerSingleton<Dao>(createDaoImpl());
  }
  getIt.registerSingleton<ChatPubsub>(ChatPubsubMock());
  getIt
      .registerSingleton<Services>(Services(getIt<Dao>(), getIt<ChatPubsub>()));
}

DaoImpl createDaoImpl() {
  return DaoImpl(
    host: Platform.environment['DB_HOST'] ?? 'localhost',
    port: int.parse(Platform.environment['DB_PORT'] ?? '5432'),
    user: Platform.environment['DB_USER'] ?? 'root',
    password: Platform.environment['DB_PASSWORD'] ?? 'root',
    dbName: Platform.environment['DB_NAME'] ?? 'sample',
  );
}
