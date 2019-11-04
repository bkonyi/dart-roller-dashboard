// import 'package:flutter/material.dart';

enum DartRollStatusType {
  current,
  last,
  unknown,
}

enum DartRollStatus {
  success,
  pending,
  failed,
  canceled,
  unknown,
}

String dartRollStatusTypeToString(DartRollStatusType t) {
  switch (t) {
    case DartRollStatusType.current:
      return 'Current';
    case DartRollStatusType.last:
      return 'Last';
    case DartRollStatusType.unknown:
      return 'Unknown';
    default:
      throw 'Invalid status type: $t';
  }
}

String dartRollStatusToString(DartRollStatus s) {
  switch (s) {
    case DartRollStatus.success:
      return 'Success';
    case DartRollStatus.pending:
      return 'Pending';
    case DartRollStatus.failed:
      return 'Failed';
    case DartRollStatus.canceled:
      return 'Canceled';
    case DartRollStatus.unknown:
      return 'Unknown';
    default:
      throw 'Invalid status: $s';
  }
}

class DartRollStatusEvent {
  final DartRollStatusType type;
  final DartRollStatus status;
  String get revision {
    if (_revision == null) {
      return 'N/A';
    }
    return _revision;
  }

  set revision(String s) => _revision = s;
  String _revision;
  final DateTime timestamp;
  final DateTime completed;

  final String logLocation;

  static bool isDartRollStatusEvent(Map<String, dynamic> data) =>
      (data.containsKey('type') &&
          data.containsKey('status') &&
          data.containsKey('revision') &&
          data.containsKey('timestamp'));

  String get statusString => dartRollStatusToString(status);

  static DartRollStatusType _typeFromString(String s) {
    print("_typeFromString: $s");
    switch (s) {
      case 'Current':
        return DartRollStatusType.current;
      case 'Last':
        return DartRollStatusType.last;
      case 'Unknown':
        return DartRollStatusType.unknown;
      default:
        throw 'Invalid type: $s';
    }
  }

  static DartRollStatus _statusFromString(String s) {
    switch (s) {
      case 'Success':
        return DartRollStatus.success;
      case 'Pending':
        return DartRollStatus.pending;
      case 'Failed':
        return DartRollStatus.failed;
      case 'Canceled':
        return DartRollStatus.canceled;
      case 'Unknown':
        return DartRollStatus.unknown;
      default:
        throw 'Invalid status: $s';
    }
  }

  DartRollStatusEvent.unknown(this.type)
      : status = DartRollStatus.unknown,
        _revision = 'N/A',
        timestamp = null,
        completed = null,
        logLocation = 'N/A';

  DartRollStatusEvent(
      this.type, this.status, this._revision, this.timestamp, this.logLocation, {this.completed});
  DartRollStatusEvent.fromJson(Map<String, dynamic> data)
      : type = _typeFromString(data['type']),
        status = _statusFromString(data['status']),
        _revision = data['revision'],
        logLocation = data['logLocation'],
        timestamp = (data['timestamp'] != null)
            ? DateTime.parse(data['timestamp'])
            : null,
         completed = (data['completedTime'] != null)
            ? DateTime.parse(data['completedTime'])
            : null;

  Map<String, dynamic> toJson() => {
        'type': dartRollStatusTypeToString(type),
        'status': dartRollStatusToString(status),
        'revision': revision,
        'timestamp': timestamp?.toIso8601String(),
        'completedTime':completed?.toIso8601String(),
        'logLocation':logLocation,
      };

  DartRollStatusEvent toLastStatus() => DartRollStatusEvent(
      DartRollStatusType.last, status, revision, timestamp, logLocation);
}
