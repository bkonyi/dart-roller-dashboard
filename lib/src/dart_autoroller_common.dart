enum DartAutoRollerState { idle, paused, running, unknown }

DartAutoRollerState stringToDartAutoRollerState(String s) {
  switch (s) {
    case 'Idle':
      return DartAutoRollerState.idle;
    case 'Paused':
      return DartAutoRollerState.paused;
    case 'Running':
      return DartAutoRollerState.running;
    case 'Unknown':
      return DartAutoRollerState.unknown;
    default:
      throw 'Invalid state: $s';
  }
}

String dartAutoRollerStateToString(DartAutoRollerState state) {
  switch (state) {
    case DartAutoRollerState.idle:
      return 'Idle';
    case DartAutoRollerState.paused:
      return 'Paused';
    case DartAutoRollerState.running:
      return 'Running';
    case DartAutoRollerState.unknown:
      return 'Unknown';
    default:
      throw 'Invalid state: $state';
  }
}

