import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CountDownTimerBloc extends CountDownTimerInfo {
  /// @formatter:off
  /// カウントダウンタイマーの更新通知用
  final StreamController<CountDownTimerInfo> _controller = BehaviorSubject();
  Stream<CountDownTimerInfo> get timer => _controller.stream;

  /// カウントダウンタイマー操作用
  final StreamController<TimerAction> _timerActionController =
      BehaviorSubject();
  Sink<TimerAction> get timerAction => _timerActionController.sink;

  /// 計測時間設定用
  final StreamController<Duration> _settingController = BehaviorSubject();
  Sink get setting => _settingController.sink;

  /// タイマーの状態 See[TimerState]
  TimerState _timerState = TimerState.BEFORE_SETTING;
  TimerState get timerState => _timerState;

  /// 計測時間
  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  /// 残り時間
  Duration _remainingTime;
  Duration get remainingTime => _remainingTime;

  Timer _timer;

  /// カウントダウンタイマー更新回数
  int _counter = 0;

  /// カウントダウンタイマー更新間隔
  static final Duration _countUpDuration = new Duration(milliseconds: 100);

  /// @formatter:on
  CountDownTimerBloc() {
    _remainingTime = _duration;
    _timerActionController.stream.listen(actionHandle);
    _settingController.stream.listen(setDuration);
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
    _timerActionController.close();
    _settingController.close();
  }

  void actionHandle(TimerAction action) {
    if (timerState == TimerState.BEFORE_SETTING) {
      return;
    }

    switch (action) {
      case TimerAction.TOGGLE_START_STOP:
        if (timerState == TimerState.STOP) {
          _start();
        } else {
          _stop();
        }
        break;
      case TimerAction.RESET:
        _reset();
        break;
    }
  }

  void setDuration(Duration duration) {
    if (duration != null) {
      _duration = duration;
      _reset();
    }
  }

  void _start() {
    _timerState = TimerState.START;
    _timer ??= Timer.periodic(_countUpDuration, _tick);
  }

  void _reset() {
    _counter = 0;
    _stop();
  }

  void _stop() {
    _timerState = TimerState.STOP;
    updateRemainingTime();
    _timer?.cancel();
    _timer = null;
  }

  void _tick(Timer timer) {
    _counter++;
    if (_duration.inMilliseconds <= _convertCounterToMilliseconds()) {
      _timerState = TimerState.TIME_UP;
    }
    updateRemainingTime();
  }

  void updateRemainingTime() {
    _calcDiffByTimeUp();
    _controller.sink.add(this);
  }

  void _calcDiffByTimeUp() => _remainingTime =
      _duration - Duration(milliseconds: _convertCounterToMilliseconds());

  int _convertCounterToMilliseconds() =>
      _counter * _countUpDuration.inMilliseconds;
}

abstract class CountDownTimerInfo {
  /// タイマーの状態
  TimerState get timerState;

  /// タイムアップまでの時間
  Duration get remainingTime;

  /// タイムアップ時間
  Duration get duration;
}

enum TimerState { BEFORE_SETTING, START, STOP, TIME_UP }

enum TimerAction { TOGGLE_START_STOP, RESET }

class TimeFormatter {
  /// 時間:分:秒 形式の文字列に変換します.
  /// ms以下は1秒切り上げます.
  static String formatToHMSColon(Duration duration) {
    int seconds =
        (duration.inMilliseconds / Duration.millisecondsPerSecond).ceil();
    Duration roundingDuration = Duration(seconds: seconds);
    return roundingDuration.toString().replaceAll(RegExp("\\..*"), "");
  }
}

Future<Duration> showTimerDialog({
  @required BuildContext context,
  TransitionBuilder builder,
  bool useRootNavigator = true,
}) {
  final Widget dialog = _TimerDialog();
  return showDialog(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}

class _TimerDialog extends StatefulWidget {
  @override
  State createState() => _TimerDialogState();
}

class _TimerDialogState extends State<_TimerDialog> {
  final dateTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final List<Widget> actions = [
      FlatButton(
        child: Text(localizations.cancelButtonLabel),
        onPressed: () => Navigator.pop(context),
      ),
      FlatButton(
        child: Text(localizations.okButtonLabel),
        onPressed: () {
          // TODO バリデーション
          int seconds = int.tryParse(dateTextController.text);
          Navigator.pop<Duration>(context, Duration(seconds: seconds));
        },
      ),
    ];
    final AlertDialog dialog = AlertDialog(
      title: Text("Set Timer"),
      content: TextField(
        controller: dateTextController,
        decoration: InputDecoration(
          hintText: "sec",
        ),
        autofocus: true,
        keyboardType: TextInputType.number,
      ),
      actions: actions,
    );

    return dialog;
  }

  @override
  void dispose() {
    dateTextController.dispose();
    super.dispose();
  }
}
