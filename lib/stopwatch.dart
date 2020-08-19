import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:wakelock/wakelock.dart';
import 'package:gym_timer/preferences-mod/preferences.dart';
import 'utils/helper.dart';
import 'utils/notificationsHelper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'utils/localeHelper.dart';

class StopwatchPage extends StatefulWidget {

  // Initialize data coming from the Root widget
  final bool singleBeepStopwatch;
  final int singleBeepFrequencyStopwatch;
  final bool doubleBeepStopwatch;
  final int doubleBeepFrequencyStopwatch;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const StopwatchPage({
    @required this.singleBeepStopwatch,
    @required this.singleBeepFrequencyStopwatch,
    @required this.doubleBeepStopwatch,
    @required this.doubleBeepFrequencyStopwatch,
    @required this.flutterLocalNotificationsPlugin,
    Key key,
  }) : super(key: key);

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  String _timeToDisplay;
  bool _timerIsRunning, _timerReset, _wasUndone;
  int _singleBeepTimeRemaining, _doubleBeepTimeRemaining;
  int _timePassed;
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
    _sec = 0;
    _timePassed = timeSplitToSeconds(_min, _sec);
    _timeToDisplay = timeSecondsToString(_timePassed);
    _listOfSets = List<String>();
    _previousListOfSets = List<String>();
    audioCache = AudioCache();
    _singleBeepTimeRemaining = this.widget.singleBeepFrequencyStopwatch;
    _doubleBeepTimeRemaining = this.widget.doubleBeepFrequencyStopwatch;
  }

  void _startTimer() {
    if(this.mounted){
      setState(() {
        _timerIsRunning = true;
        _timerReset = false;
        Wakelock.enable();
        PrefService.setBool('wakeLockStopwatch', true);
        _singleBeepTimeRemaining = this.widget.singleBeepFrequencyStopwatch;
        _doubleBeepTimeRemaining = this.widget.doubleBeepFrequencyStopwatch;
      });
    }

    _timePassed = timeSplitToSeconds(_min, _sec);

    Timer.periodic(Duration(
        seconds: 1
    ), (Timer t) {
      if(this.mounted){
        setState(() {
          if (_timerReset){
            t.cancel();
            _timePassed = timeSplitToSeconds(_min, _sec);
            _timerReset = false;
            _timerIsRunning = false;

            // if the timer is running simultaneously, let Wakelock enabled
            if (!PrefService.get('wakeLockTimer')) {
              Wakelock.disable();
            }
            PrefService.setBool('wakeLockStopWatch', false);

            // notification
            if (PrefService.getBool('notifications')) {
              showNotificationWithNoSound(
                  this.widget.flutterLocalNotificationsPlugin,
                  '${AppLocalizations.of(context).translate('StopwatchWasStopped')}',
                  _timeToDisplay,
                  1
              );
            }
          }
          else {
            // Increase elapsed time
            _timePassed += 1;

            // Handle time remaining until next single/double beep
            _singleBeepTimeRemaining = (_singleBeepTimeRemaining == 1) ? this.widget.singleBeepFrequencyStopwatch : _singleBeepTimeRemaining - 1;
            _doubleBeepTimeRemaining = (_doubleBeepTimeRemaining == 1) ? this.widget.doubleBeepFrequencyStopwatch : _doubleBeepTimeRemaining - 1;

            // Play single/double beep
            if (this.widget.doubleBeepStopwatch && _timePassed % this.widget.doubleBeepFrequencyStopwatch == 0) {
              audioCache.play('doubleBeep.mp3');
            }
            else if (this.widget.singleBeepStopwatch && _timePassed % this.widget.singleBeepFrequencyStopwatch == 0) {
              audioCache.play('beep.mp3');
            }

            if (PrefService.getBool('notifications')) {
              showNotificationWithNoSound(
                  this.widget.flutterLocalNotificationsPlugin,
                  '${AppLocalizations.of(context).translate('StopwatchIsRunning')}',
                  _timeToDisplay,
                  1
              );
            }
          }

          // Update displayed time
          _timeToDisplay = timeSecondsToString(_timePassed);
        });
      }
    });
  }

  void _resetTimer() {
    if (this.mounted){
      setState(() {
        //this.widget.flutterLocalNotificationsPlugin.cancel(1);
        _timerReset = true;
        _previousListOfSets.clear();
        _previousListOfSets.addAll(_listOfSets);
        _listOfSets.clear();
        _wasUndone = false;
      });
    }
  }

  void _stopTimer() {
    if (this.mounted && !_timerReset){
      setState(() {
        _timerReset = true;
        _previousListOfSets.clear();
        _previousListOfSets.addAll(_listOfSets);
        _listOfSets.insert(0,'${_listOfSets.length + 1} - ${timeSecondsToString(_timePassed)}');
        _wasUndone = false;
      });
    }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            this.widget.doubleBeepStopwatch ? LinearProgressIndicator(
                value: (_timePassed == 0) ? 1.0 : (_doubleBeepTimeRemaining / this.widget.doubleBeepFrequencyStopwatch),
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue[900]),
                backgroundColor: Colors.black
            ) : SizedBox.shrink(),
            this.widget.singleBeepStopwatch ? LinearProgressIndicator(
                value: (_timePassed == 0) ? 1.0 : (_singleBeepTimeRemaining / this.widget.singleBeepFrequencyStopwatch),
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.black
            ) : SizedBox.shrink(),
            Expanded(
              flex: 4,
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(_timeToDisplay, style: TextStyle(color: Colors.white, fontSize: 100, fontFamily: 'Timebomb')),
                ],
              ),
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
                    )
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
                          color: _timerIsRunning ? Colors.blue[900] : Colors.blue[900],
                        ),
                        child: FlatButton.icon(
                          onPressed: _timerIsRunning ? _stopTimer : _startTimer,
                          icon: Icon(_timerIsRunning ? Icons.stop : Icons.play_arrow, color: Colors.white,),
                          label: Text(
                              '${_timerIsRunning ? '${AppLocalizations.of(context).translate('Stop')} ' : '${AppLocalizations.of(context).translate('Start')}'}',
                              style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Orbitron-Black')
                          ),
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
                        color: Colors.blue[900],
                      ),
                      child: FlatButton.icon(
                        onPressed: _resetTimer,
                        icon: Icon(Icons.autorenew, color: Colors.white),
                        label: Text('${AppLocalizations.of(context).translate('Reset')}', style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Orbitron-Black')),
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: SizedBox.shrink()),
                ],
              ),
            ),
          ],
        )
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
