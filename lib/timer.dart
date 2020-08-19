import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:wakelock/wakelock.dart';
import 'package:gym_timer/preferences-mod/preferences.dart';
import 'utils/helper.dart';
import 'utils/notificationsHelper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'utils/localeHelper.dart';

class TimerPage extends StatefulWidget {

  // Initialize data coming from the Root widget
  final bool singleBeepTimer;
  final int singleBeepFrequencyTimer;
  final bool unilateral;
  final String unilateralFirstSide;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const TimerPage({
    @required this.singleBeepTimer,
    @required this.singleBeepFrequencyTimer,
    @required this.unilateral,
    @required this.unilateralFirstSide,
    @required this.flutterLocalNotificationsPlugin,
    Key key,
  }) : super(key: key);

  @override
  _TimerPageState createState() => _TimerPageState();

}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  String _timeToDisplay, _sideUnilateralIndication;
  bool _timerIsRunning, _timerReset, _wasUndone;
  int _timeRemaining, _startingTimeRemaining;
  int _singleBeepTimeRemaining;
  int _min, _sec;
  List<String> _listOfSets, _previousListOfSets;
  AudioCache audioCache;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: _timer(context),
    );
  }

  @override
  void initState() {
    super.initState();
    PrefService.init();

    _timerIsRunning = false;
    _timerReset = false;
    _wasUndone = false;
    _min = 0;
    _sec = 90;
    _timeRemaining = timeSplitToSeconds(_min, _sec);
    _timeToDisplay = timeSecondsToString(_timeRemaining);
    _listOfSets = List<String>();
    _previousListOfSets = List<String>();
    audioCache = AudioCache();
    _startingTimeRemaining = _timeRemaining;
    _singleBeepTimeRemaining = this.widget.singleBeepFrequencyTimer;
    _sideUnilateralIndication = this.widget.unilateralFirstSide;
  }

  void _startTimer() {
    if(this.mounted){
      setState(() {
        _timerIsRunning = true;
        _timerReset = false;
        Wakelock.enable();
        PrefService.setBool('wakeLockTimer', true);
        _timeRemaining = timeSplitToSeconds(_min, _sec);
        _startingTimeRemaining = _timeRemaining;
        _singleBeepTimeRemaining = this.widget.singleBeepFrequencyTimer;
        _sideUnilateralIndication = _getNextSideUnilateral();
      });
    }

    Timer.periodic(Duration(
        seconds: 1
    ), (Timer t) {
      if(this.mounted){
        setState(() {
          // Stop timer if it reaches 0 or if the reset button was pressed
          if (_timeRemaining < 1 || _timerReset){
            t.cancel();
            _timeRemaining = timeSplitToSeconds(_min, _sec);

            if(!_timerReset) {
              if (PrefService.getBool('notifications')){
                showNotificationWithNoSound(
                  this.widget.flutterLocalNotificationsPlugin,
                  '${AppLocalizations.of(context).translate('TimeIsUp')}',
                  _timeToDisplay,
                  0
                );
              }

              switch(PrefService.get('alarmSound')){
                case 'Original': {
                  audioCache.play('alarm.mp3');
                  break;
                }
                case 'Double beep': {
                  audioCache.play('doubleBeep.mp3');
                  break;
                }
                default: {
                  break;
                }
              }

              _previousListOfSets.clear();
              _previousListOfSets.addAll(_listOfSets);
              _listOfSets.insert(0,'${_listOfSets.length + 1} - ${timeSecondsToString(_timeRemaining)}');
              _wasUndone = false;
            }

            _timerReset = false;
            _timerIsRunning = false;

            // if the stopwatch is running simultaneously, let Wakelock enabled
            // 1) null: not initialized, so not running 2) normal case
            if (PrefService.get('wakeLockStopwatch') == null || !PrefService.get('wakeLockStopwatch')) {
              Wakelock.disable();
            }
            PrefService.setBool('wakeLockTimer', false);
          }
          // Continue decreasing the timer
          else {
            if (PrefService.getBool('notifications')){
              showNotificationWithNoSound(
                  this.widget.flutterLocalNotificationsPlugin,
                  '${AppLocalizations.of(context).translate('TimerIsRunning')}',
                  timeSecondsToString(_timeRemaining - 1),
                  0
              );
            }

            String _voiceAssetLocation =
                'voice/${PrefService.get('englishVoice')
                ? 'en'
                : AppLocalizations.of(context).translate('languageCode')}';

            if (_timeRemaining == 6 && PrefService.get('countdownBeforeAlarm')) {
              audioCache.play('$_voiceAssetLocation/5.mp3');
            }
            else if (_timeRemaining == 5 && PrefService.get('countdownBeforeAlarm')) {
              audioCache.play('$_voiceAssetLocation/4.mp3');
            }
            else if (_timeRemaining == 4 && PrefService.get('countdownBeforeAlarm')) {
              audioCache.play('$_voiceAssetLocation/3.mp3');
            }
            else if (_timeRemaining == 3 && PrefService.get('countdownBeforeAlarm')) {
              audioCache.play('$_voiceAssetLocation/2.mp3');
            }
            else if (_timeRemaining == 2 && PrefService.get('countdownBeforeAlarm')) {
              audioCache.play('$_voiceAssetLocation/1.mp3');
            }
            else if (_timeRemaining == 16 && PrefService.get('15s')) {
              audioCache.play('$_voiceAssetLocation/15seconds.mp3');
            }
            else if (_timeRemaining == 31 && PrefService.get('30s')) {
              audioCache.play('$_voiceAssetLocation/30seconds.mp3');
            }
            else if (_timeRemaining == 61 && PrefService.get('60s')) {
              audioCache.play('$_voiceAssetLocation/60seconds.mp3');
            }
            else if (_timeRemaining == 91 && PrefService.get('90s')) {
              audioCache.play('$_voiceAssetLocation/90seconds.mp3');
            }
            else if (_timeRemaining == 8 && this.widget.unilateral) {
              if (_getNextSideUnilateral() == 'Left') {
                audioCache.play('$_voiceAssetLocation/leftSide.mp3');
              }
              else {
                audioCache.play('$_voiceAssetLocation/rightSide.mp3');
              }
            }
            else if (this.widget.singleBeepTimer && _singleBeepTimeRemaining == 1 ) {
              audioCache.play('beep.mp3');
            }

            // Decrease overall time remaining + time remaining until next beep
            _timeRemaining -= 1;
            _singleBeepTimeRemaining = (_singleBeepTimeRemaining == 1) ? this.widget.singleBeepFrequencyTimer : _singleBeepTimeRemaining - 1;
          }

          // Update displayed time
          _timeToDisplay = timeSecondsToString(_timeRemaining);
        });
      }
    });
  }

  String _getNextSideUnilateral(){
    if (this.widget.unilateralFirstSide == 'Left'){
      if ((_listOfSets.length + 1) % 2 == 0){
        return 'Left';
      }
      else {
        return 'Right';
      }
    }
    else{
      if ((_listOfSets.length + 1) % 2 == 0){
        return 'Right';
      }
      else {
        return 'Left';
      }
    }
  }

  void _resetTimer() {
    if (this.mounted){
      setState(() {
        //this.widget.flutterLocalNotificationsPlugin.cancel(0);
        _timerReset = true;
        _previousListOfSets.clear();
        _previousListOfSets.addAll(_listOfSets);
        _listOfSets.clear();
        _wasUndone = false;
        _singleBeepTimeRemaining = this.widget.singleBeepFrequencyTimer;
        _sideUnilateralIndication = this.widget.unilateralFirstSide;
      });
    }
  }

  void _increaseDuration(BuildContext context) {
    setState(() {
      int _timeInSeconds = timeSplitToSeconds(_min, _sec);
      int _newTimeInSeconds = _timeInSeconds + PrefService.get('incrementValue');
      if (_newTimeInSeconds > PrefService.get('rangeValuesMax')) {
        _newTimeInSeconds = PrefService.get('rangeValuesMin');
      }
      List _timeSplitMinSec = timeSecondsToSplit(_newTimeInSeconds);
      _min = _timeSplitMinSec[0];
      _sec = _timeSplitMinSec[1];
      _timeToDisplay = timeSecondsToString(timeSplitToSeconds(_min, _sec));
    });
  }

  void _dialogOnPressedConfirm(_minutes, _seconds) {
    setState(() {
      if (validateDuration(_minutes, _seconds)){
        _min = (_minutes == null) ? 0 : _minutes;
        _sec = (_seconds == null) ? 0 : _seconds;
        _timeToDisplay = timeSecondsToString(timeSplitToSeconds(_min, _sec));
      }
    });
  }

  void _undoRedoAction(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
                (_wasUndone) ? '${AppLocalizations.of(context).translate('Redo')}' : '${AppLocalizations.of(context).translate('Undo')}',
                style: TextStyle(fontFamily: 'Orbitron-Black', color: Colors.white)
            ),
            content: Text(
                _wasUndone ? '${AppLocalizations.of(context).translate('RedoSentence')}' : '${AppLocalizations.of(context).translate('UndoSentence')}',
                style: TextStyle(fontFamily: 'Orbitron-Black', color: Colors.white)
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('${AppLocalizations.of(context).translate('Cancel')}', style: TextStyle(fontFamily: 'Orbitron-Black'))),
              FlatButton(
                onPressed: () {
                  setState(() {
                    if(_wasUndone) {
                      // redo
                      // temp = _previousListOfSets
                      var _tempList = List<String>();
                      _tempList.addAll(_previousListOfSets);

                      // _previousListOfSets = _listOfSets
                      _previousListOfSets.clear();
                      _previousListOfSets.addAll(_listOfSets);

                      // _listOfSets = _previousListOfSets
                      _listOfSets.clear();
                      _listOfSets.addAll(_tempList);

                      _wasUndone = false;
                    }
                    else {
                      // undo
                      // temp = _listOfSets
                      var _tempList = List<String>();
                      _tempList.addAll(_listOfSets);

                      // _listOfSets = _previousListOfSets
                      _listOfSets.clear();
                      _listOfSets.addAll(_previousListOfSets);

                      // _previousListOfSets = _listOfSets
                      _previousListOfSets.clear();
                      _previousListOfSets.addAll(_tempList);

                      _wasUndone = true;
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text('${AppLocalizations.of(context).translate('Confirm')}', style: TextStyle(fontFamily: 'Orbitron-Black')),
              )
            ],
          );
        });
  }

  Widget _timer(context){
    return Container(
      child: SafeArea(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            LinearProgressIndicator(
              value: (_timeRemaining / _startingTimeRemaining),
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
              backgroundColor: Colors.black
            ),
            this.widget.singleBeepTimer ? LinearProgressIndicator(
                value: (_timerIsRunning) ? (_singleBeepTimeRemaining / this.widget.singleBeepFrequencyTimer) : 1.0,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.black
            ) : SizedBox.shrink(),
            Expanded(
              flex: 4,
              child: InkWell(
                onLongPress: () {if(!_timerIsRunning){changeDuration(context, _dialogOnPressedConfirm, '${AppLocalizations.of(context).translate('ChangeDuration')}');}},
                onTap: () {if(!_timerIsRunning){_increaseDuration(context);}},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        this.widget.unilateral ? Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: (_sideUnilateralIndication == 'Left') ? Colors.red : Colors.transparent,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                        ) : SizedBox.shrink(),
                        Text(_timeToDisplay, style: TextStyle(color: Colors.white, fontSize: 100, fontFamily: 'Timebomb')),
                        this.widget.unilateral ? Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: (_sideUnilateralIndication == 'Right') ? Colors.red : Colors.transparent,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                        ) : SizedBox.shrink(),
                      ],
                    )
                  ],
                ),
              )
            ),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: InkWell(
                      onDoubleTap: () {_undoRedoAction(context);},
                      child: ListView.separated(
                        separatorBuilder: (context, index) => Divider(color: Colors.white),
                        itemCount: _listOfSets.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              title: Center(
                                child: Text(
                                    '${_listOfSets[index]}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40.0,
                                        fontFamily: 'Timebomb'
                                    )
                                ),
                              )
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(flex: 1, child: SizedBox.shrink()),
                  Expanded(
                      flex: 15,
                      child: Container(
                        //padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _timerIsRunning ? Colors.grey : Colors.red,
                        ),
                        child: FlatButton.icon(
                          onPressed: _timerIsRunning ? null : _startTimer,
                          icon: Icon(Icons.play_arrow, color: Colors.white,),
                          label: Text('${AppLocalizations.of(context).translate('Start')}', style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Orbitron-Black')),
                          padding: EdgeInsets.symmetric(horizontal: AppLocalizations.of(context).translate('languageCode') == 'fr' ? 25 : 20),
                        ),
                      ),
                  ),
                  Expanded(flex: 1, child: SizedBox.shrink()),
                  Expanded(
                    flex: 15,
                    child: Container(
                      //padding: EdgeInsets.symmetric(horizontal: AppLocalizations.of(context).translate('languageCode') == 'fr' ? 0 : 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red,
                      ),
                      child: FlatButton.icon(
                        onPressed: _resetTimer,
                        icon: Icon(Icons.autorenew, color: Colors.white),
                        label: Text('${AppLocalizations.of(context).translate('Reset')}', style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Orbitron-Black')),
                      ),
                    )
                  ),
                  Expanded(flex: 1, child: SizedBox.shrink()),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}