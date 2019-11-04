import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as io;
import 'package:sse/server/sse_handler.dart';

import 'autoroller_controller.dart';
import '../lib/src/dart_autoroller_api_common.dart';
import '../lib/src/dart_autoroller_common.dart';
import '../lib/src/dart_roll_status.dart';

final bindAddress = Platform.environment['AUTOROLLER_BIND_ADDRESS'];

class Router {
  void addClient(SseConnection client) {
    client.sink.done.then((_) => clients.remove(client));
    clients.add(client);
    client.stream.listen((data) {
      final jsonData = json.decode(data);
      final requestType = stringToDartAutorollerApiTypes(
          jsonData[DartAutorollerConstants.apiTypeKey]);
      switch (requestType) {
        case DartAutorollerApiTypes.cancelRoll:
          cancelRoll();
          break;
        case DartAutorollerApiTypes.forceRoll:
          forceRoll();
          break;
        case DartAutorollerApiTypes.pause:
          pauseRoller();
          break;
        case DartAutorollerApiTypes.resume:
          resumeRoller();
          break;
        case DartAutorollerApiTypes.rollToRevision:
          rollToRevision(jsonData);
          break;
        default:
          print('Warning: invalid type, $requestType');
      }
    });
    stateUpdated(DartAutorollerController.state);
    rollStatusUpdated(DartAutorollerController.currentRoll);
    rollStatusUpdated(DartAutorollerController.lastRoll);
  }

  void cancelRoll() {
    DartAutorollerController.cancelCurrent();
  }

  void forceRoll() {
    DartAutorollerController.forceRoll();
  }

  void pauseRoller() {
    DartAutorollerController.pause();
    stateUpdated(DartAutoRollerState.paused);
  }

  void resumeRoller() {
    DartAutorollerController.resume();
    stateUpdated(DartAutorollerController.state);
  }

  void rollToRevision(Map<String, dynamic> data) {
    final String revision = data[DartAutorollerConstants.revisionKey];
    if (revision == null) {
      return;
    }
    DartAutorollerController.rollToRevision(revision);
  }

  void stateUpdated(DartAutoRollerState state) {
    final data = <String, dynamic>{
      DartAutorollerConstants.stateKey: dartAutoRollerStateToString(state),
    };
    _sendToAll(data);
  }

  void rollStatusUpdated(DartRollStatusEvent event) {
    if (event == null) return;
    _sendToAll(event.toJson());
  }

  void _sendToAll(data) {
    data = jsonEncode(data);
    clients.forEach((client) {
      try {
        client.sink.add(data);
      } catch (e) {
        print(e);
      }
    });
  }

  List<SseConnection> clients = <SseConnection>[];
}

final Router requestRouter = Router();

String localFile(path) => Platform.script.resolve(path).toFilePath();

void main() async {
  DartAutorollerController.initialize();
  final sse = SseHandler(Uri.parse('/sseHandler'));
  await io.serve(sse.handler, bindAddress, 8081);
  while (await sse.connections.hasNext) {
    final connection = await sse.connections.next;
    requestRouter.addClient(connection);
  }
}
