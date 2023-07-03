import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:myapp/database/ConfigModel.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/database/NotifyModel.dart';
import 'package:myapp/widgets/config.dart';
import 'package:myapp/widgets/http_post.dart';

FlutterLocalNotificationsPlugin? flutterNotificationPlugin;

void checkNotify() async {
  //final DateTime now = DateTime.now();
  //final int isolateId = Isolate.current.hashCode;
  int timeout = 60;
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

  await initGlobalData();

  if (await hasNetwork(null)) {
    // СИНХРОНИЗАЦИЯ
    var data1 = [];
    var data2 = [];
    List<Notify> res = await getAllNotify();
    for (Notify itm in res) {
      if (itm.sync ?? false) {
        if (itm.remove ?? false) {
          data1.add(itm.id);
          deleteNotify(itm);
        } else {
          if (itm.dtview != null) {
            data2.add({
              "id": itm.id,
              "dtview": DateFormat('yyyyMMdd HH:mm:ss').format(itm.dtview!)
            });
            itm.sync = false;
            updateNotify(itm);
          }
        }
      }
    }

    // ПОЛУЧАЕМ СПИСОК Notify
    var res_ = await httpAPI(
        "close/students/mobileApp.asp",
        jsonEncode({
          "command": "getNotify",
          "data": {"remove": data1, "view": data2, "sync": []}
        }),
        null);
    data1 = [];
    var _listNotify = (res_ as List).toList();
    for (var itm in _listNotify) {
      data1.add(itm["id"]);
      var rec = await getNotify(itm["id"]);
      if (rec == null) {
        //var body = {"html": itm["body"]};
        //itm["body"] = jsonEncode(body);
        await newNotify(Notify.fromMap(itm));
        await _showGroupedNotifications(Notify.fromMap(itm));
      } else {
        await updateNotify(Notify.fromMap(itm));
      }
    }
    await httpAPI(
        "close/students/mobileApp.asp",
        jsonEncode({
          "command": "getNotify",
          "data": {"sync": data1, "remove": [], "view": []}
        }),
        null);

    ////////////////////////////////////////////////////////////////////////
  }

  // Вызов следующего опроса
  await AndroidAlarmManager.oneShot(
    Duration(seconds: timeout),
    // Ensure we have a unique alarm ID.
    Random().nextInt(pow(2, 31) as int),
    checkNotify,
  );
}

Future onSelectNotification(String? payload) async {}

Future<void> _showGroupedNotifications(Notify item) async {
  const String groupKey = 'com.android.myapp.WORK_EMAIL';
  const String groupChannelId = 'grouped channel id';
  const String groupChannelName = 'grouped channel name';
  const String groupChannelDescription = 'grouped channel description';

  // example based on https://developer.android.com/training/notify-user/group.html
  // 1
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

  // 2
  const AndroidNotificationDetails secondNotificationAndroidSpecifics =
      AndroidNotificationDetails(groupChannelId, groupChannelName,
          channelDescription: groupChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          groupKey: groupKey);
  const NotificationDetails secondNotificationPlatformSpecifics =
      NotificationDetails(android: secondNotificationAndroidSpecifics);

  await flutterNotificationPlugin?.show(
      Random().nextInt(pow(2, 31) as int),
      item.subject,
      DateFormat('yyyy-MM-dd HH:mm').format(item.dt!),
      secondNotificationPlatformSpecifics);

  // Create the summary notification to support older devices that pre-date
  /// Android 7.0 (API level 24).
  ///
  /// Recommended to create this regardless as the behaviour may vary as
  /// mentioned in https://developer.android.com/training/notify-user/group
  /*
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
  */
}
