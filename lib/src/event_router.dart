import 'dart:convert';

import 'package:sse/client/sse_client.dart';
import 'dart_autoroller_api.dart';

typedef EventHandler = void Function(Object);

abstract class EventRouter {
  static SseClient _channel;

  static void startListening(SseClient channel) {
    _channel = channel;
    DartAutorollerApi.setChannel(channel);
    _channel.stream.listen((data) {
      final decoded = json.decode(data);
      _handlers.forEach((handler) => handler(decoded));
    });
  }

  static void addHandler(EventHandler handler) => _handlers.add(handler);
  static List<EventHandler> _handlers = <EventHandler>[];
}
