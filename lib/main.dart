import 'package:flutter/material.dart';
import 'package:gym_timer/settings.dart';
import 'timer.dart';
import 'stopwatch.dart';
import 'settings.dart';
import 'package:gym_timer/utils/notificationsHelper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:gym_timer/preferences-mod/preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/localeHelper.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preferences
  await PrefService.init();
  Map _defaultValues = {
    'incrementValue': 15,
    'rangeValuesMin': 30,
    'rangeValuesMax': 180,
    'wakeLockTimer': false,
    'wakeLockStopwatch': false,
    'singleBeepFrequencyTimer': 30,
    'singleBeepFrequencyStopwatch': 30,
    'doubleBeepFrequencyStopwatch': 60,
    'singleBeepTimer': false,
    'singleBeepStopwatch': true,
    'doubleBeepStopwatch': true,
    '90s': false,
    '60s': true,
    '30s': true,
    '15s': true,
    'countdownBeforeAlarm': false,
    'uni': false,
    'notifications': true,
    'alarmSound': 'Original',
    'englishVoice': false
  };
  PrefService.setDefaultValues(_defaultValues);

  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await initNotifications(flutterLocalNotificationsPlugin);
  requestIOSPermissions(flutterLocalNotificationsPlugin);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // White status bar text and icons
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
            statusBarIconBrightness: Brightness.light, // Android
            statusBarBrightness: Brightness.dark // iOS
        )
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym Timer',
      home: Root(),
      theme: ThemeData(canvasColor: Colors.black, fontFamily: 'Poppins-Regular'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('fr', ''), // French, no country code
        const Locale('de', '') // German, no country code
      ],
    );
  }
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  // RootState handles information that needs to spread from one page to another

  // Controller used for the PageView
  final pageController = PageController(
    initialPage: 1,
    keepPage: true
  );

  // Timer
  bool _singleBeepTimer;
  int _singleBeepFrequencyTimer;

  Function _callBackSingleBeepTimer;
  Function _callBackSingleBeepFrequencyTimer;

  // Stopwatch - Single Beep
  bool _singleBeepStopwatch;
  int _singleBeepFrequencyStopwatch;

  Function _callBackSingleBeepStopwatch;
  Function _callBackSingleBeepFrequencyStopwatch;

  // Stopwatch - Double Beep
  bool _doubleBeepStopwatch;
  int _doubleBeepFrequencyStopwatch;

  Function _callBackDoubleBeepStopwatch;
  Function _callBackDoubleBeepFrequencyStopwatch;

  // Timer - Unilateral
  bool _unilateral;
  String _unilateralFirstSide;

  Function _callBackUnilateral;
  Function _callBackUnilateralFirstSide;

  @override
  void initState() {
    super.initState();
    // Timer
    _singleBeepTimer = PrefService.getBool('singleBeepTimer');
    _singleBeepFrequencyTimer = PrefService.getInt('singleBeepFrequencyTimer');
    _callBackSingleBeepTimer = (bool singleBeepTimer) => {
      setState(() => {
        _singleBeepTimer = singleBeepTimer
      })
    };

    _callBackSingleBeepFrequencyTimer = (int singleBeepTimerFrequency) => {
      setState(() => {
        _singleBeepFrequencyTimer = singleBeepTimerFrequency
      })
    };

    // Stopwatch single beep
    _singleBeepStopwatch= PrefService.getBool('singleBeepStopwatch');
    _singleBeepFrequencyStopwatch = PrefService.getInt('singleBeepFrequencyStopwatch');
    _callBackSingleBeepStopwatch = (bool singleBeepStopwatch) => {
      setState(() => {
        _singleBeepStopwatch = singleBeepStopwatch
      })
    };

    _callBackSingleBeepFrequencyStopwatch = (int singleBeepStopwatchFrequency) => {
      setState(() => {
        _singleBeepFrequencyStopwatch = singleBeepStopwatchFrequency
      })
    };

    // Stopwatch double beep
    _doubleBeepStopwatch = PrefService.getBool('doubleBeepStopwatch');
    _doubleBeepFrequencyStopwatch = PrefService.getInt('doubleBeepFrequencyStopwatch');
    _callBackDoubleBeepStopwatch = (bool doubleBeepStopwatch) => {
      setState(() => {
        _doubleBeepStopwatch = doubleBeepStopwatch
      })
    };

    _callBackDoubleBeepFrequencyStopwatch = (int doubleBeepStopwatchFrequency) => {
      setState(() => {
        _doubleBeepFrequencyStopwatch = doubleBeepStopwatchFrequency
      })
    };

    // Unilateral
    _unilateral = PrefService.getBool('uni');
    _unilateralFirstSide = PrefService.getString('firstSide');
    _callBackUnilateral = (bool unilateral) => {
      setState(() => {
        _unilateral = unilateral
      })
    };

    _callBackUnilateralFirstSide = (String unilateralFirstSide) => {
      setState(() => {
        _unilateralFirstSide = unilateralFirstSide,
      })
    };
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          SettingsPage(
            callBackSingleBeepTimer: _callBackSingleBeepTimer,
            callBackSingleBeepFrequencyTimer: _callBackSingleBeepFrequencyTimer,
            callBackSingleBeepStopwatch: _callBackSingleBeepStopwatch,
            callBackSingleBeepFrequencyStopwatch: _callBackSingleBeepFrequencyStopwatch,
            callBackDoubleBeepStopwatch: _callBackDoubleBeepStopwatch,
            callBackDoubleBeepFrequencyStopwatch: _callBackDoubleBeepFrequencyStopwatch,
            callBackUnilateral: _callBackUnilateral,
            callBackUnilateralFirstSide: _callBackUnilateralFirstSide
          ),
          TimerPage(
            singleBeepTimer: _singleBeepTimer,
            singleBeepFrequencyTimer: _singleBeepFrequencyTimer,
            unilateral: _unilateral,
            unilateralFirstSide: _unilateralFirstSide,
            flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin
          ),
          StopwatchPage(
            singleBeepStopwatch: _singleBeepStopwatch,
            singleBeepFrequencyStopwatch: _singleBeepFrequencyStopwatch,
            doubleBeepStopwatch: _doubleBeepStopwatch,
            doubleBeepFrequencyStopwatch: _doubleBeepFrequencyStopwatch,
            flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin
          )
        ],
      );
  }
}