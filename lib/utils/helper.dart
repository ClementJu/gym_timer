import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'localeHelper.dart';


/// Transforms a duration in minutes and seconds into seconds
int timeSplitToSeconds(int min, int sec) {
  return min * 60 + sec;
}

/// Transforms a duration in seconds into a displayable String duration: XX:XX
String timeSecondsToString(int seconds) {
  int min = (seconds / 60).floor();
  int sec = seconds % 60;
  return '${min < 10 ? '0$min' : '$min'}:${sec < 10 ? '0$sec' : '$sec'}';
}

/// Transforms a duration in seconds into a duration in minutes and seconds
List timeSecondsToSplit(int seconds) {
  int min = (seconds / 60).floor();
  int sec = seconds % 60;
  return [min, sec];
}

/// Transforms a duration in seconds into a displayable String duration. For example: 15s, 3min48, 2min
String rangeSecondsToSplit(int seconds){
  if (seconds < 60) {
    return '${seconds}s';
  }
  else {
    int min = (seconds / 60).floor();
    int sec = seconds % 60;
    return (sec < 10) ? '$min:0$sec' : '$min:$sec';
  }
}

/// Validates a duration in minutes and seconds
bool validateDuration(int min, int sec) {
  if (min == null && sec == null) { return false; }
  if (sec == null){sec = 0;}
  if (min == null){min = 0;}
  return (sec >= 0 && min >= 0) && (sec < 60);
}

/// Generates a standardized dialog window to change a duration
void changeDuration(BuildContext context, Function onPressedConfirm, String title) {
  int _minutes, _seconds;
  final GlobalKey<FormState> _formKeyMin = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeySec = GlobalKey<FormState>();

  showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
            child: AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(title, style: TextStyle(
                  fontFamily: 'Poppins-Regular', color: Colors.white, fontWeight: FontWeight.bold)
              ),
              content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Expanded(
                              flex: 1,
                              child: Form(
                                key: _formKeyMin,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context).translate('Min'),
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    if (val == '') {
                                      _minutes = null;
                                    }
                                    else {
                                      _minutes = int.parse(val);
                                    }
                                  },
                                  textAlign: TextAlign.center,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              child: Text(' : ', style: TextStyle(fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))
                          ),
                          Container(
                              child: Expanded(
                                flex: 1,
                                child: Form(
                                  autovalidate: true,
                                  key: _formKeySec,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context).translate('Sec'),
                                      labelStyle: TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) {
                                      if (val == '') {
                                        _seconds = null;
                                      }
                                      else {
                                        _seconds = int.parse(val);
                                      }
                                    },
                                    textAlign: TextAlign.center,
                                    autofocus: true,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                          )
                        ],
                      )
                    ],
                  )
              ),

              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel',
                        style: TextStyle(fontFamily: 'Poppins-Regular', fontWeight: FontWeight.bold))),
                FlatButton(
                  onPressed: () {
                    onPressedConfirm(_minutes, _seconds);
                    Navigator.pop(context);
                  },
                  child: Text('Confirm',
                      style: TextStyle(fontFamily: 'Poppins-Regular', fontWeight: FontWeight.bold)),
                )
              ],
            )
        );
      });
}

