import 'package:flutter/material.dart';
import 'package:gym_timer/preferences-mod/preferences.dart';
import 'utils/helper.dart';
import 'about.dart';
import 'utils/localeHelper.dart';

class SettingsPage extends StatefulWidget {
  // Initialize callbacks coming from the RootWidget
  final Function(bool) callBackSingleBeepTimer;
  final Function(int) callBackSingleBeepFrequencyTimer;
  final Function(bool) callBackSingleBeepStopwatch;
  final Function(int) callBackSingleBeepFrequencyStopwatch;
  final Function(bool) callBackDoubleBeepStopwatch;
  final Function(int) callBackDoubleBeepFrequencyStopwatch;
  final Function(bool) callBackUnilateral;
  final Function(String) callBackUnilateralFirstSide;

  const SettingsPage({
    @required this.callBackSingleBeepTimer,
    @required this.callBackSingleBeepFrequencyTimer,
    @required this.callBackSingleBeepStopwatch,
    @required this.callBackSingleBeepFrequencyStopwatch,
    @required this.callBackDoubleBeepStopwatch,
    @required this.callBackDoubleBeepFrequencyStopwatch,
    @required this.callBackUnilateral,
    @required this.callBackUnilateralFirstSide,
    Key key,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: _settings(context),
    );
  }

  // Style
  final TextStyle _styleTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'Poppins-Regular'
  );

  final TextStyle _styleSubtitle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins-Regular'
  );

  final TextStyle _styleContent = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontFamily: 'Poppins-Regular'
  );

  final TextStyle _styleButton = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontFamily: 'Poppins-Regular',
    fontWeight: FontWeight.bold
  );

  @override
  void initState() {
    super.initState();
  }

  Widget _settings(context){
    return Container(
      color: Colors.grey[900],
      child: SafeArea(
        child: PreferencePage([
          PreferenceTitle(
            '${AppLocalizations.of(context).translate('Timer')}',
            style: _styleTitle,
            bottomPadding: 20.0,
            border: Border(bottom: BorderSide(width: 2.0, color: Colors.white))
          ),
          PreferenceTitle(
              '${AppLocalizations.of(context).translate('Voice')} '
              + '▹ ${AppLocalizations.of(context).translate('Countdown')}',
              style: _styleSubtitle),
          SwitchPreference(
              Text('90 ${AppLocalizations.of(context).translate('seconds')}', style: _styleContent),
              '90s'
          ),
          SwitchPreference(
              Text('60 ${AppLocalizations.of(context).translate('seconds')}', style: _styleContent),
              '60s',
              defaultVal: true
          ),
          SwitchPreference(
              Text('30 ${AppLocalizations.of(context).translate('seconds')}', style: _styleContent),
              '30s',
              defaultVal: true
          ),
          SwitchPreference(
              Text('15 ${AppLocalizations.of(context).translate('seconds')}', style: _styleContent),
              '15s',
              defaultVal: true
          ),
          SwitchPreference(
              Text('${AppLocalizations.of(context).translate('Last')} 5 ${AppLocalizations.of(context).translate('seconds')}', style: _styleContent),
              'countdownBeforeAlarm',
              defaultVal: false
          ),
          PreferenceTitle(
              '${AppLocalizations.of(context).translate('Voice')} '
              +'▹ ${AppLocalizations.of(context).translate('Unilateral')}',
              style: _styleSubtitle),
          SwitchPreference(
              Text(
                  '${AppLocalizations.of(context).translate('VocalIndication')}',
                  style: _styleContent
              ),
              'uni',
              onEnable: () => this.widget.callBackUnilateral(true),
              onDisable: () => this.widget.callBackUnilateral(false)
          ),
          DropdownPreference(
            Text('${AppLocalizations.of(context).translate('YourFirstSide')}', style: _styleContent),
            'firstSide',
            style: _styleContent,
            defaultVal: 'Left',
            values: ['Left', 'Right'],
            displayValues: [
              '${AppLocalizations.of(context).translate('Left')}',
              '${AppLocalizations.of(context).translate('Right')}'
            ],
            onChange: (String value) => this.widget.callBackUnilateralFirstSide(value)
          ),
          PreferenceTitle('${AppLocalizations.of(context).translate('Beep')}', style: _styleSubtitle),
          SwitchPreference(
              Text('${AppLocalizations.of(context).translate('SingleBeep')}', style: _styleContent),
              'singleBeepTimer',
              onEnable: () => this.widget.callBackSingleBeepTimer(true),
              onDisable: () => this.widget.callBackSingleBeepTimer(false)
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  child: ListTile(
                      title: Text(
                        '${AppLocalizations.of(context).translate('Frequency')}: ${rangeSecondsToSplit(PrefService.get('singleBeepFrequencyTimer'))}',
                        style: _styleContent,
                      ),
                      trailing: FlatButton(
                          child: Text('${AppLocalizations.of(context).translate('Change')}', style: _styleButton),
                          onPressed: () => changeDuration(context, _onPressedConfirmFrequencyTimer, '${AppLocalizations.of(context).translate('ChangeFrequency')}'),
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 35.0),
                          color: Colors.blue[600]
                      )
                  )
              ),
            ],
          ),
          PreferenceTitle(
              '${AppLocalizations.of(context).translate('Alarm')}',
              style: _styleSubtitle
          ),
          DropdownPreference(
            Text('${AppLocalizations.of(context).translate('ChooseAlarmSound')}',
                style: _styleContent),
            'alarmSound',
            style: _styleContent,
            defaultVal: 'Original',
            values: [
              'Original',
              'Double beep',
              'No sound'
            ],
            displayValues: [
              '${AppLocalizations.of(context).translate('Original')}',
              '${AppLocalizations.of(context).translate('DoubleBeep')}',
              '${AppLocalizations.of(context).translate('NoSound')}'
            ],
          ),
          (AppLocalizations.of(context).translate('languageCode') != 'en') ? PreferenceTitle(
            '${AppLocalizations.of(context).translate('Voice')} '
                + '▹ ${AppLocalizations.of(context).translate('Language')}',
            style: _styleSubtitle
          ) : SizedBox.shrink(),
          (AppLocalizations.of(context).translate('languageCode') != 'en') ? SwitchPreference(
            Text('${AppLocalizations.of(context).translate('EnglishVoice')}', style: _styleContent),
            'englishVoice',
            defaultVal: false
          ) : SizedBox.shrink(),
          PreferenceTitle(
            '${AppLocalizations.of(context).translate('Duration')} '
            + '▹ ${AppLocalizations.of(context).translate('TapToIncrease')}',
            style: _styleSubtitle
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  child: ListTile(
                      title: Text(
                        '${AppLocalizations.of(context).translate('LowerBound')}: ${rangeSecondsToSplit(PrefService.getInt('rangeValuesMin'))}',
                        style: _styleContent,
                      ),
                      trailing: FlatButton(
                          child: Text('${AppLocalizations.of(context).translate('Change')}', style: _styleButton),
                          onPressed: () => changeDuration(context, _onPressedConfirmLowerBoundTimer, '${AppLocalizations.of(context).translate('ChangeLowerBound')}'),
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 35.0),
                          color: Colors.blue[600]
                      )
                  )
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  child: ListTile(
                      title: Text(
                        '${AppLocalizations.of(context).translate('UpperBound')}: ${rangeSecondsToSplit(PrefService.getInt('rangeValuesMax'))}',
                        style: _styleContent,
                      ),
                      trailing: FlatButton(
                          child: Text('${AppLocalizations.of(context).translate('Change')}', style: _styleButton),
                          onPressed: () => changeDuration(context, _onPressedConfirmUpperBoundTimer, '${AppLocalizations.of(context).translate('ChangeUpperBound')}'),
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 35.0),
                          color: Colors.blue[600]
                      )
                  )
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  child: ListTile(
                      title: Text(
                        '${AppLocalizations.of(context).translate('Step')}: ${rangeSecondsToSplit(PrefService.getInt('incrementValue'))}',
                        style: _styleContent,
                      ),
                      trailing: FlatButton(
                          child: Text('${AppLocalizations.of(context).translate('Change')}', style: _styleButton),
                          onPressed: () => changeDuration(context, _onPressedConfirmIncrementValue, '${AppLocalizations.of(context).translate('ChangeStep')}'),
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 35.0),
                          color: Colors.blue[600]
                      )
                  )
              ),
            ],
          ),
          PreferenceTitle(
            '${AppLocalizations.of(context).translate('Stopwatch')}',
            style: _styleTitle,
            bottomPadding: 20.0,
            topPadding: 40.0,
            border: Border(bottom: BorderSide(width: 2.0, color: Colors.white)),
          ),
          PreferenceTitle('${AppLocalizations.of(context).translate('Beep')}', style: _styleSubtitle),
          SwitchPreference(
            Text('${AppLocalizations.of(context).translate('SingleBeep')}', style: TextStyle(color: Colors.white)),
            'singleBeepStopwatch',
              onEnable: () => this.widget.callBackSingleBeepStopwatch(true),
              onDisable: () => this.widget.callBackSingleBeepStopwatch(false)
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: ListTile(
                  title: Text(
                    '${AppLocalizations.of(context).translate('Frequency')}: ${rangeSecondsToSplit(PrefService.getInt('singleBeepFrequencyStopwatch'))}',
                    style: _styleContent,
                  ),
                  trailing: FlatButton(
                    child: Text('${AppLocalizations.of(context).translate('Change')}', style: _styleButton),
                    onPressed: () => changeDuration(context, _onPressedConfirmFrequencyStopwatch, '${AppLocalizations.of(context).translate('ChangeFrequency')}'),
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 35.0),
                    color: Colors.blue[600]
                  )
                )
              )
            ],
          ),
          SwitchPreference(
              Text('${AppLocalizations.of(context).translate('DoubleBeep')}', style: TextStyle(color: Colors.white)),
              'doubleBeepStopwatch',
              onEnable: () => this.widget.callBackDoubleBeepStopwatch(true),
              onDisable: () => this.widget.callBackDoubleBeepStopwatch(false)
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  child: ListTile(
                      title: Text(
                        '${AppLocalizations.of(context).translate('Frequency')}: ${rangeSecondsToSplit(PrefService.getInt('doubleBeepFrequencyStopwatch'))}',
                        style: _styleContent,
                      ),
                      trailing: FlatButton(
                          child: Text('${AppLocalizations.of(context).translate('Change')}', style: _styleButton),
                          onPressed: () => changeDuration(context, _onPressedConfirmFrequencyStopwatchDoubleBeep, '${AppLocalizations.of(context).translate('ChangeFrequency')}'),
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 35.0),
                          color: Colors.blue[600]
                      )
                  )
              )
            ],
          ),
          PreferenceTitle(
            '${AppLocalizations.of(context).translate('Notifications')}',
            style: _styleTitle,
            bottomPadding: 20.0,
            topPadding: 40.0,
            border: Border(bottom: BorderSide(width: 2.0, color: Colors.white)),
          ),
          SwitchPreference(
              Text('${AppLocalizations.of(context).translate('ProgressNotifications')}', style: _styleContent),
              'notifications'
          ),
          Padding(padding: EdgeInsets.all(15)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey[700],
                    child: ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AboutPage()
                        )
                      ),
                      title: Text('${AppLocalizations.of(context).translate('About')}', style: _styleTitle),
                      leading: Icon(Icons.info, color: Colors.white),
                    )
                  )
              )
            ],
          )
        ]),
      ),
    );
  }

  // Callbacks for frequency changes
  void _onPressedConfirmFrequencyTimer(minutes, seconds){
    setState(() {
      if (validateDuration(minutes, seconds)){
        int min = (minutes == null) ? 0 : minutes;
        int sec = (seconds == null) ? 0 : seconds;
        int _singleBeepFrequencyTimer = timeSplitToSeconds(min, sec);
        PrefService.setInt('singleBeepFrequencyTimer', _singleBeepFrequencyTimer);
        this.widget.callBackSingleBeepFrequencyTimer(_singleBeepFrequencyTimer);
      }
    });
  }

  void _onPressedConfirmFrequencyStopwatch(minutes, seconds){
    setState(() {
      if (validateDuration(minutes, seconds)){
        int min = (minutes == null) ? 0 : minutes;
        int sec = (seconds == null) ? 0 : seconds;
        int _singleBeepFrequencyStopwatch = timeSplitToSeconds(min, sec);
        PrefService.setInt('singleBeepFrequencyStopwatch', _singleBeepFrequencyStopwatch);
        this.widget.callBackSingleBeepFrequencyStopwatch(_singleBeepFrequencyStopwatch);
      }
    });
  }

  void _onPressedConfirmFrequencyStopwatchDoubleBeep(minutes, seconds){
    setState(() {
      if (validateDuration(minutes, seconds)){
        int min = (minutes == null) ? 0 : minutes;
        int sec = (seconds == null) ? 0 : seconds;
        int _doubleBeepFrequencyStopwatch = timeSplitToSeconds(min, sec);
        PrefService.setInt('doubleBeepFrequencyStopwatch', _doubleBeepFrequencyStopwatch);
        this.widget.callBackDoubleBeepFrequencyStopwatch(_doubleBeepFrequencyStopwatch);
      }
    });
  }

  void _onPressedConfirmLowerBoundTimer(minutes, seconds){
    setState(() {
      if (validateDuration(minutes, seconds)){
        int min = (minutes == null) ? 0 : minutes;
        int sec = (seconds == null) ? 0 : seconds;
        int _rangeValuesMin = timeSplitToSeconds(min, sec);
        if (_rangeValuesMin < PrefService.getInt('rangeValuesMax')) {
          PrefService.setInt('rangeValuesMin', _rangeValuesMin);
        }
      }
    });
  }

  void _onPressedConfirmUpperBoundTimer(minutes, seconds){
    setState(() {
      if (validateDuration(minutes, seconds)){
        int min = (minutes == null) ? 0 : minutes;
        int sec = (seconds == null) ? 0 : seconds;
        int _rangeValuesMax = timeSplitToSeconds(min, sec);
        if (_rangeValuesMax > PrefService.getInt('rangeValuesMin')){
          PrefService.setInt('rangeValuesMax', _rangeValuesMax);
        }
      }
    });
  }

  void _onPressedConfirmIncrementValue(minutes, seconds){
    setState(() {
      if (validateDuration(minutes, seconds)){
        int min = (minutes == null) ? 0 : minutes;
        int sec = (seconds == null) ? 0 : seconds;
        int _incrementValue = timeSplitToSeconds(min, sec);
        if (_incrementValue > 0){
          PrefService.setInt('incrementValue', _incrementValue);
        }
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
