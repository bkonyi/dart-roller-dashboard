// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:sse/client/sse_client.dart';

import 'src/proxy_location.dart'; // DO NOT INCLUDE
import 'src/dart_autoroller_state_bloc.dart';
import 'src/dart_autoroller_state_widget.dart';
import 'src/event_router.dart';

void main() async {
  final channel = SseClient(backendLocation);
  EventRouter.startListening(channel);
  runApp(DartAutoRollerDashboard(channel));
}

class DartAutoRollerDashboard extends StatelessWidget {
  static const String kTitle =
      'Dart SDK Autoroller (go/dart-sdk-roller-dashboard)';
  static const double kStateFontSize = 30;

  static const TextStyle kStateTextStyle =
      const TextStyle(fontSize: kStateFontSize);

  final DartAutoRollerStateBloc _autoRollerStateBloc =
      DartAutoRollerStateBloc();
  final SseClient channel;
  DartAutoRollerDashboard(this.channel);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kTitle,
      home: Scaffold(
          appBar: AppBar(
            title: const Text(kTitle),
          ),
          body: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: [
              Divider(color: Colors.black, height: 5),
              BlocProvider.value(
                  value: _autoRollerStateBloc,
                  child: DartAutoRollerStateWidget()),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          )),
    );
  }
}
