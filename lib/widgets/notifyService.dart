import 'dart:isolate';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin? flutterNotificationPlugin;

void checkNotify() async {
  //final DateTime now = DateTime.now();
  //final int isolateId = Isolate.current.hashCode;

  if (flutterNotificationPlugin == null) {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = const IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterNotificationPlugin = FlutterLocalNotificationsPlugin();

    flutterNotificationPlugin?.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  await _showGroupedNotifications();

/*
  await AndroidAlarmManager.oneShot(
    const Duration(seconds: 20),
    // Ensure we have a unique alarm ID.
    Random().nextInt(pow(2, 31) as int),
    checkNotify,
    //exact: true,
  );
  */
}

Future onSelectNotification(String? payload) async {}

Future<void> _showGroupedNotifications() async {
  const String groupKey = 'com.android.myapp.WORK_EMAIL';
  const String groupChannelId = 'grouped channel id';
  const String groupChannelName = 'grouped channel name';
  const String groupChannelDescription = 'grouped channel description';

  // example based on https://developer.android.com/training/notify-user/group.html
  const AndroidNotificationDetails firstNotificationAndroidSpecifics =
      AndroidNotificationDetails(groupChannelId, groupChannelName,
          channelDescription: groupChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          groupKey: groupKey);
  const NotificationDetails firstNotificationPlatformSpecifics =
      NotificationDetails(android: firstNotificationAndroidSpecifics);
  await flutterNotificationPlugin?.show(1, 'Alex Faarborg',
      'You will not believe...', firstNotificationPlatformSpecifics);

  const AndroidNotificationDetails secondNotificationAndroidSpecifics =
      AndroidNotificationDetails(groupChannelId, groupChannelName,
          channelDescription: groupChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          groupKey: groupKey);
  const NotificationDetails secondNotificationPlatformSpecifics =
      NotificationDetails(android: secondNotificationAndroidSpecifics);
  await flutterNotificationPlugin?.show(
      2,
      'Jeff Chang',
      'Please join us to celebrate the...',
      secondNotificationPlatformSpecifics);

  // Create the summary notification to support older devices that pre-date
  /// Android 7.0 (API level 24).
  ///
  /// Recommended to create this regardless as the behaviour may vary as
  /// mentioned in https://developer.android.com/training/notify-user/group
  const List<String> lines = <String>[
    'Alex Faarborg  Check this out',
    'Jeff Chang    Launch Party'
  ];
  const InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: '2 сообщения',
      summaryText: 'janedoe@example.com');
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(groupChannelId, groupChannelName,
          channelDescription: groupChannelDescription,
          styleInformation: inboxStyleInformation,
          groupKey: groupKey,
          setAsGroupSummary: true);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterNotificationPlugin?.show(
      3, 'Attention', 'Two messages', platformChannelSpecifics);
}
