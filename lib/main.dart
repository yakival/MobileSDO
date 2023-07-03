import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lifecycle_aware/lifecycle_route_observer.dart';
import 'package:myapp/pages/AlertPage.dart';
import 'package:myapp/pages/ConfigPage.dart';
import 'package:myapp/pages/FreeItem.dart';
import 'package:myapp/pages/HomePage.dart';
import 'package:myapp/pages/ItemPage.dart';
import 'package:myapp/pages/LoadPageItem.dart';
import 'package:myapp/pages/NotifyPage.dart';
import 'package:myapp/pages/PlayerPage.dart';
import 'package:myapp/pages/SyncCourses.dart';
import 'package:myapp/pages/WebinarPage.dart';
import 'package:myapp/pages/ZakazPage.dart';
import 'package:myapp/pages/exam/TestPage.dart';
import 'package:myapp/pages/viewers/FileReaderPage.dart';
import 'package:myapp/pages/viewers/HtmlViewPage.dart';
import 'package:myapp/pages/viewers/PhotoPage.dart';
import 'package:myapp/pages/viewers/ScormSyncPage.dart';
import 'package:myapp/pages/viewers/VideoPlayer.dart';
import 'package:myapp/pages/viewers/ViewPDFPage.dart';
import 'package:myapp/pages/viewers/WebViewPage.dart';
import 'package:myapp/pages/viewers/WriterItemPage.dart';
import 'package:myapp/pages/viewers/WriterPage.dart';
import 'package:myapp/widgets/notifyService.dart';

import 'pages/MessagePage.dart';

void main() async {
  // Поддержка сообщений
  if (true) {
    WidgetsFlutterBinding.ensureInitialized();
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.oneShot(
      const Duration(seconds: 40),
      Random().nextInt(pow(2, 31) as int),
      checkNotify,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //navigatorObservers: [LifecycleRouteObserver.routeObserver],
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/config': (context) => const ConfigPage(),
        '/items': (context) => const ItemPage(),
        '/loaditems': (context) => const LoadPageItem(),
        '/viewPDF': (context) => const ViewPDFPage(),
        '/viewVideo': (context) => const VideoPlayerScreen(),
        '/viewPhoto': (context) => const PhotoViewPage(),
        '/viewFile': (context) => const FileReaderPage(),
        '/viewHtml': (context) => const HtmlViewPage(),
        '/viewSCORM': (context) => const WebViewPage(),
        '/syncSCORM': (context) => const ScormSyncPage(),
        '/syncCourses': (context) => const SyncCourses(),
        '/test': (context) => const TestPage(),
        '/webinars': (context) => const WebinarPage(),
        '/books': (context) => const FreePage(),
        '/zakaz': (context) => const ZakazPage(),
        '/writeritem': (context) => const WriterItemPage(),
        '/writer': (context) => const WriterPage(),
        '/alert': (context) => const AlertPage(),
        '/player': (context) => const PlayerPage(),
        '/notify': (context) => const NotifyPage(),
        '/message': (context) => const MessagePage(),
      },
    );
  }
}
