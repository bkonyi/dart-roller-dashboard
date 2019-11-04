
abstract class DartAutorollerConstants {
  static const String apiTypeKey = 'type';
  static const String revisionKey = 'revision';
  static const String stateKey = 'state';
}

enum DartAutorollerApiTypes {
  cancelRoll,
  forceRoll,
  pause,
  resume,
  rollToRevision,
}

DartAutorollerApiTypes stringToDartAutorollerApiTypes(String s) {
  switch (s) {
    case 'cancelRoll':
      return DartAutorollerApiTypes.cancelRoll;
    case 'forceRoll':
      return DartAutorollerApiTypes.forceRoll;
    case 'pause':
      return DartAutorollerApiTypes.pause;
    case 'resume':
      return DartAutorollerApiTypes.resume;
    case 'rollToRevision':
      return DartAutorollerApiTypes.rollToRevision;
    default:
      throw 'Invalid type: $s';
  }
}

String dartAutorollerApiTypesToString(DartAutorollerApiTypes t) {
  switch (t) {
    case DartAutorollerApiTypes.cancelRoll:
      return 'cancelRoll';
    case DartAutorollerApiTypes.forceRoll:
      return 'forceRoll';
    case DartAutorollerApiTypes.pause:
      return 'pause';
    case DartAutorollerApiTypes.resume:
      return 'resume';
    case DartAutorollerApiTypes.rollToRevision:
      return 'rollToRevision';
    default:
      throw 'Invalid type: $t';
  }
}