import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:myapp/pages/ConfigPage.dart';
import 'package:myapp/pages/FreeItem.dart';
import 'package:myapp/pages/HomePage.dart';
import 'package:myapp/pages/ItemPage.dart';
import 'package:myapp/pages/LoadPageItem.dart';
import 'package:myapp/pages/SyncCourses.dart';
import 'package:myapp/pages/WebinarPage.dart';
import 'package:myapp/pages/ZakazPage.dart';
import 'package:myapp/pages/exam/TestPage.dart';
import 'package:myapp/pages/viewers/FileReaderPage.dart';
import 'package:myapp/pages/viewers/PhotoPage.dart';
import 'package:myapp/pages/viewers/ScormSyncPage.dart';
import 'package:myapp/pages/viewers/VideoPlayer.dart';
import 'package:myapp/pages/viewers/ViewPDFPage.dart';
import 'package:myapp/pages/viewers/WebViewPage.dart';
import 'package:myapp/widgets/notifyService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.periodic(
    const Duration(seconds: 20),
    0,
    checkNotify,
    //exact: true,
  );

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
        '/viewSCORM': (context) => const WebViewPage(),
        '/syncSCORM': (context) => const ScormSyncPage(),
        '/syncCourses': (context) => const SyncCourses(),
        '/test': (context) => const TestPage(),
        '/webinars': (context) => const WebinarPage(),
        '/books': (context) => const FreePage(),
        '/zakaz': (context) => const ZakazPage(),
      },
    );
  }
}
