// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter_ui/ui.dart' as ui;
import 'package:org.dartlang.dart_roller_dashboard/main.dart' as app;

main() async {
  await ui.webOnlyInitializePlatform();
  app.main();
}
