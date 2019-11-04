import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cron/cron.dart';

import 'server.dart';
import '../lib/src/dart_autoroller_common.dart';
import '../lib/src/dart_roll_status.dart';

abstract class DartAutorollerController {
  static bool _paused = false;
  static bool _canceled = false;
  static Process _currentRoll;
  static DartRollStatusEvent get currentRoll => _currentRollStatus;
  static DartRollStatusEvent get lastRoll => _lastRollStatus;
  static DartRollStatusEvent _currentRollStatus;
  static DartRollStatusEvent _lastRollStatus;

  static DartAutoRollerState get state {
    if (_paused) {
      return DartAutoRollerState.paused;
    } else if (_currentRoll == null) {
      return DartAutoRollerState.idle;
    } else {
      return DartAutoRollerState.running;
    }
  }

  static void initialize() {
    Cron().schedule(Schedule.parse('0 0,6,9,12,15,18,21 * * 1,2,3,4,5'),
        () async {
      if (_paused) return;
      await _startRoll();
    });
  }

  static void cancelCurrent() {
    _canceled = true;
    _currentRoll?.kill();
    _currentRoll = null;
    requestRouter.stateUpdated(state);
  }

  static void forceRoll() {
    if (_currentRoll != null) return;
    _startRoll();
  }

  static void pause() {
    if (_paused) {
      return;
    }
    _paused = true;
    requestRouter.stateUpdated(state);
  }

  static void resume() {
    if (!_paused) {
      return;
    }
    _paused = false;
    requestRouter.stateUpdated(state);
  }

  static final command =
      '/usr/local/google/home/bkonyi/engine/src/tools/dart/dart_autoroller.py';

  static void rollToRevision(String revision) => _startRoll(revision: revision);

  static DartRollStatus _getStatusFromExit(int exitCode) {
    if (_canceled) {
      _canceled = false;
      return DartRollStatus.canceled;
    }
    return (exitCode == 0) ? DartRollStatus.success : DartRollStatus.failed;
  }

  static Future<void> _startRoll({String revision}) async {
    if (_currentRoll != null) {
      return;
    }
    final arguments = <String>[
    ];
    if (revision != null) {
      arguments.add('--dart-sdk-revision=$revision');
    }
    final env = <String, String>{
      'TERM': 'dumb' // Force ninja to print build steps on individual lines.
    };
    final date = DateTime.now();
    String logFileDir =
        '/usr/local/google/home/bkonyi/autoroller-workspace/dart-sdk-roller-logs/';
    String logFileName =
        'sdk-roll-${date.year}-${date.month}-${date.day}-${date.hour}-${date.millisecondsSinceEpoch}.log';
    final logFile = File(logFileDir + logFileName).openWrite();
    final roll = await Process.start(command, arguments, environment: env);
    _currentRoll = roll;
    requestRouter.stateUpdated(state);

    _currentRollStatus = DartRollStatusEvent(DartRollStatusType.current,
        DartRollStatus.pending, revision, DateTime.now(), logFileName);
    requestRouter.rollStatusUpdated(_currentRollStatus);

    roll.stdout
        .transform(Utf8Decoder())
        .transform(LineSplitter())
        .listen((line) {
      stdout.writeln(line);
      try {
        logFile.writeln(line);
      } catch (e) {
        // Ignore closed sink.
      }
      if (line.contains("for Dart SDK roll")) {
        _currentRollStatus.revision = line.split(' ')[5];
        requestRouter.rollStatusUpdated(_currentRollStatus);
      }
    });

    roll.stderr
        .transform(Utf8Decoder())
        .transform(LineSplitter())
        .listen((line) {
      stderr.writeln(line);
      try {
        logFile.writeln(line);
      } catch (e) {
        // Ignore closed sink.
      }
    });

    roll.exitCode.then((int exitCode) async {
      assert(_currentRoll == roll);
      _currentRoll = null;
      requestRouter.stateUpdated(state);
      _lastRollStatus = DartRollStatusEvent(
          DartRollStatusType.last,
          _getStatusFromExit(exitCode),
          _currentRollStatus.revision,
          _currentRollStatus.timestamp,
          _currentRollStatus.logLocation,
          completed: DateTime.now());
      _currentRollStatus = null;
      requestRouter.rollStatusUpdated(_lastRollStatus);
      requestRouter.rollStatusUpdated(
          DartRollStatusEvent.unknown(DartRollStatusType.current));
      await logFile.close();
    });
  }
}
