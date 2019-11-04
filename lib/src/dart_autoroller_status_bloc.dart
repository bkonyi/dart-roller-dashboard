import 'package:bloc/bloc.dart';

import 'dart_autoroller_common.dart';
import 'dart_roll_status.dart';
import 'event_router.dart';

class DartRollStatusBloc
    extends Bloc<DartRollStatusEvent, DartRollStatusEvent> {
  final DartRollStatusType type;

  DartRollStatusBloc(this.type) {
    EventRouter.addHandler(eventDispatcher);
  }

  @override
  DartRollStatusEvent get initialState => DartRollStatusEvent.unknown(type);

  @override
  Stream<DartRollStatusEvent> mapEventToState(
      DartRollStatusEvent state) async* {
    yield state;
  }

  void eventDispatcher(data) {
    if (data is! Map || !DartRollStatusEvent.isDartRollStatusEvent(data)) {
      return;
    }
    final event = DartRollStatusEvent.fromJson(data);
    if (event.type != type) {
      return;
    }
    add(event);
  }
}
