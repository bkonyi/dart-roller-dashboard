import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

Future main() async {
  await io.serve(createStaticHandler('build/web', defaultDocument:
        'index.html'), 'bkonyi0.mtv.corp.google.com', 8181);
}
