import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'dart_autoroller_api.dart';
import 'dart_autoroller_state_bloc.dart';
import 'dart_autoroller_common.dart';
import 'dart_roll_status.dart';
import 'dart_autoroller_status_bloc.dart';

class DartAutoRollerStateWidget extends StatefulWidget {
  final Widget child;

  DartAutoRollerStateWidget({Key key, this.child}) : super(key: key);

  _DartAutoRollerStateWidgetState createState() =>
      _DartAutoRollerStateWidgetState();
}

class _DartAutoRollerStateWidgetState extends State<DartAutoRollerStateWidget> {
  static const double kStateFontSize = 30;
  static const TextStyle kStateTextStyle =
      const TextStyle(fontSize: kStateFontSize, fontWeight: FontWeight.bold);

  static final _currentRollStatusBloc =
      DartRollStatusBloc(DartRollStatusType.current);
  static final _lastRollStatusBloc =
      DartRollStatusBloc(DartRollStatusType.last);

  final _rollToRevisionTextFieldController = TextEditingController();

  Color _statusColor(DartRollStatus status) {
    switch (status) {
      case DartRollStatus.success:
        return Colors.green;
      case DartRollStatus.pending:
        return Colors.yellow[600];
      case DartRollStatus.failed:
      case DartRollStatus.canceled:
        return Colors.red;
      case DartRollStatus.unknown:
        return Colors.grey;
      default:
        throw 'Invalid status: $status';
    }
  }

  Color _stateColor(DartAutoRollerState state) {
    switch (state) {
      case DartAutoRollerState.idle:
        return Colors.grey;
      case DartAutoRollerState.paused:
        return Colors.yellow[600];
      case DartAutoRollerState.running:
        return Colors.green;
      case DartAutoRollerState.unknown:
        return Colors.red;
      default:
        throw 'Invalid state: $state';
    }
  }

  Widget _buildStateRow(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<DartAutoRollerStateBloc>(context),
        builder: (BuildContext context, DartAutoRollerStateEvent event) {
          final buttonText =
              event.isPaused ? const Text('Resume') : const Text('Pause');
          final _onPauseResumePressed = () {
            if (event.isPaused) {
              DartAutorollerApi.resumeRoller();
            } else {
              DartAutorollerApi.pauseRoller();
            }
          };
          return Row(
            children: [
              const Text('Current State: ',
                  textAlign: TextAlign.left, style: kStateTextStyle),
              Text(event.toString(),
                  style:
                      kStateTextStyle.apply(color: _stateColor(event.state))),
              Padding(
                  child: RaisedButton(
                      onPressed: _onPauseResumePressed, child: buttonText),
                  padding: EdgeInsets.only(left: 20)),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          );
        });
  }

  Widget _buildStatusRow(String title, String status,
      {Color statusColor, FontWeight statusFontWeight}) {
    return Row(children: [
      Text('$title: ', style: TextStyle(fontWeight: FontWeight.w700)),
      Text('$status',
          style: TextStyle(color: statusColor, fontWeight: statusFontWeight))
    ], mainAxisAlignment: MainAxisAlignment.spaceBetween);
  }

  Widget _buildStatusSection(DartRollStatusType type) {
    bool isCurrentStatus = (type == DartRollStatusType.current);
    return BlocBuilder(
        bloc: (isCurrentStatus ? _currentRollStatusBloc : _lastRollStatusBloc),
        builder: (BuildContext context, DartRollStatusEvent event) {
          return (isCurrentStatus && event.status == DartRollStatus.unknown)
              ? Column(children: [])
              : Column(children: [
                  isCurrentStatus
                      ? _buildSubtitle('Current Roll Status:')
                      : _buildSubtitle('Last Roll Status:'),
                  _buildStatusRow('Status', event.statusString,
                      statusColor: _statusColor(event.status),
                      statusFontWeight: FontWeight.w600),
                  _buildStatusRow('Revision', event.revision),
                  _buildStatusRow(
                      'Started at', event.timestamp?.toString() ?? 'N/A'),
                  (event.completed != null)
                      ? _buildStatusRow(
                          'Completed at', event.completed.toString())
                      : Column(children: []),
                  _buildStatusRow('Log file (go/dart-sdk-roller-logs)', event?.logLocation ?? 'N/A'),
                  Divider(height: 10),
                ]);
        });
  }

  Text _buildSubtitle(String title) =>
      Text(title, style: kStateTextStyle.apply(fontSizeFactor: 0.8));

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all(width: 2)),
        padding: EdgeInsets.all(10),
        width: 550,
        child: Column(children: [
          _buildStateRow(context),
          Divider(height: 10),
          _buildStatusSection(DartRollStatusType.current),
          _buildStatusSection(DartRollStatusType.last),
          Row(children: [
            Container(
                width: 400,
                child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Roll to Revision',
                    ),
                    controller: _rollToRevisionTextFieldController)),
            RaisedButton(
                onPressed: () {
                  DartAutorollerApi.rollToRevision(
                      _rollToRevisionTextFieldController.text);
                  _rollToRevisionTextFieldController.clear();
                },
                child: const Text('Submit'))
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
          Container(
              child: Column(children: [
            _buildSubtitle('Dart Autoroller Controls'),
            Row(
                children: [
                  RaisedButton(
                    child: const Text('Force Roll'),
                    onPressed: () => DartAutorollerApi.forceRoll(),
                  ),
                  Container(padding: EdgeInsets.only(left: 20)),
                  RaisedButton(
                    child: const Text('Cancel Roll'),
                    onPressed: () => DartAutorollerApi.cancelRoll(),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly)
          ], mainAxisAlignment: MainAxisAlignment.start)),
        ]));
  }
}
