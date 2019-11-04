import 'dart:convert';

import 'package:sse/client/sse_client.dart';

import 'dart_autoroller_api_common.dart';

abstract class DartAutorollerApi {
  static SseClient _channel;
  static void setChannel(SseClient channel) => _channel = channel;

  static void _simpleRequest(DartAutorollerApiTypes type) {
    String api = dartAutorollerApiTypesToString(type);
    assert(_channel != null);
    final Map<String, String> request = <String, String>{
      DartAutorollerConstants.apiTypeKey: api,
    };
    _channel.sink.add(json.encode(request));
  }

  static void cancelRoll() => _simpleRequest(DartAutorollerApiTypes.cancelRoll);
  static void forceRoll() => _simpleRequest(DartAutorollerApiTypes.forceRoll);

  static void pauseRoller() => _simpleRequest(DartAutorollerApiTypes.pause);
  static void resumeRoller() => _simpleRequest(DartAutorollerApiTypes.resume);

  static void rollToRevision(String revision) {
    assert(_channel != null);
    if (revision == null) {
      return;
    }
    final Map<String, String> request = <String, String>{
      DartAutorollerConstants.apiTypeKey:
          dartAutorollerApiTypesToString(DartAutorollerApiTypes.rollToRevision),
      DartAutorollerConstants.revisionKey: revision
    };
    _channel.sink.add(json.encode(request));
  }
}
