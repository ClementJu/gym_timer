import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

// Notifications
final BehaviorSubject<String> selectNotificationSubject =
BehaviorSubject<String>();

Future<void> initNotifications(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var initializationSettingsAndroid = AndroidInitializationSettings('notification_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
  );
  var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });
}

Future<void> showNotificationWithNoSound(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, title, body, int id) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'silent channel id',
      'silent channel name',
      'silent channel description',
      playSound: false,
      styleInformation: DefaultStyleInformation(true, true));
  var iOSPlatformChannelSpecifics = IOSNotificationDetails(presentSound: false);
  var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(id, title, body, platformChannelSpecifics);
}


void requestIOSPermissions(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
}
