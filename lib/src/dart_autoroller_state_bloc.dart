import 'package:bloc/bloc.dart';

import 'dart_autoroller_common.dart';
import 'event_router.dart';

class DartAutoRollerStateEvent {
  final DartAutoRollerState state;

  static bool isDartAutoRollerStateEvent(Map<String, dynamic> data) =>
      data.containsKey('state');
  bool get isPaused => (state == DartAutoRollerState.paused);

  DartAutoRollerStateEvent(this.state);

  DartAutoRollerStateEvent.fromJson(Map<String, dynamic> data)
      : state = stringToDartAutoRollerState(data['state']);

  @override
  String toString() => dartAutoRollerStateToString(state);
}

class DartAutoRollerStateBloc
    extends Bloc<DartAutoRollerStateEvent, DartAutoRollerStateEvent> {
  DartAutoRollerStateBloc() {
    EventRouter.addHandler(eventDispatcher);
  }

  @override
  DartAutoRollerStateEvent get initialState =>
      DartAutoRollerStateEvent(DartAutoRollerState.unknown);

  @override
  Stream<DartAutoRollerStateEvent> mapEventToState(
      DartAutoRollerStateEvent state) async* {
    yield state;
  }

  void eventDispatcher(data) {
    if (data is! Map ||
        !DartAutoRollerStateEvent.isDartAutoRollerStateEvent(data)) {
      return;
    }
    add(DartAutoRollerStateEvent.fromJson(data));
  }
}
