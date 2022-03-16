import 'dart:io';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:myapp/database/Database.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'dart:async';

import 'package:myapp/widgets/config.dart';
import 'package:myapp/database/CourseModel.dart';
import 'package:sqflite/sqflite.dart';

import 'package:http/http.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isOnline = false;
  bool isLoad = false;
  List<Item> _list = [];
  List<Item> __list = [];
  int _totalItems = 1, _receivedItems = 0;
  int _total = 1, _received = 0, _index = -1;

  @override
  void initState() {
    super.initState();
  }

  Future onSelectNotification(String? payload) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("Hello Everyone"),
              content: Text("$payload"),
            ));
  }

  void check(context) async {
    await initGlobalData();
    if (GlobalData.isReadAll) return;
    isOnline = await hasNetwork(context);
    if (isOnline) {
      Navigator.pushReplacementNamed(context, '/syncCourses').then((value) {
        setState(() {});
      });
    }
  }

  Future<void> _downloadCourse(Course itm, index, context) async {
    _index = index;
    var isOnline = await hasNetwork(context);
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Нет подключения к интернету'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    setState(() {
      isLoad = true;
    });

    __list = [];
    _list = await getCourseItem(itm.id);
    for (Item i in _list) {
      if (!(i.load ?? false)) {
        __list.add(i);
      }
    }
    if (__list.isNotEmpty) {
      setState(() {
        _totalItems = __list.length;
        _receivedItems = 0;
      });
      for (Item i in __list) {
        setState(() {
          _receivedItems++;
        });
        await _downloadFile(i, context);
      }
    }

    itm.load = true;
    await updateCourse(itm);
    setState(() {
      _totalItems = 1;
      _receivedItems = 0;
      isLoad = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Курс загружен'),
      backgroundColor: Colors.yellow[900],
    ));
  }

  Future<void> _downloadFile(Item itm, context) async {
    late StreamSubscription<List<int>> responseStream;
    final List<int> _bytes = [];

    var _url = GlobalData.baseUrl;
    var _file = itm.path;
    var _load = false;

    final StreamedResponse _response =
        await http.Client().send(http.Request('GET', Uri.parse('$_url$_file')));
    if (_response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_response.reasonPhrase!),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _total = 1;
        _received = 0;
      });
      return;
    }

    _total = _response.contentLength ?? 0;
    var _free = await DiskSpace.getFreeDiskSpace;
    _free = (_free ?? 0) * (1024.0 * 1024.0);
    if (_total > _free) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Нет свободного места"),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _total = 1;
        _received = 0;
      });
      return;
    }

    responseStream = _response.stream.listen((value) async {
      setState(() {
        _bytes.addAll(value);
        _received += value.length;
      });
    }, onDone: () async {
      responseStream.pause();
      if (itm.type == "SCORM") {
        var res = await httpAPI("close/students/mobileApp.asp",
            '{"command": "getScorm", "id": "${itm.guid}"}', context);
        itm.jsondata = '{"version": "V1p3", "toc": ' + jsonEncode(res) + '}';
      }
      if (itm.type == "test") {
        var res = await httpAPI("close/students/mobileApp.asp",
            '{"command": "getTest", "id": "${itm.guid}"}', context);
        itm.jsondata = jsonEncode(res);
      }
      final file = File(itm.localpath!);
      final exist = await file.exists();
      if (exist) file.deleteSync(recursive: true);
      await file.writeAsBytes(_bytes, flush: true);
      itm.load = true;
      await updateItem(itm);

      await responseStream.cancel();
      _load = true;
      //responseStream.cancel();
      setState(() {
        _total = 1;
        _received = 0;
      });
      //await responseStream.cancel();
    }, onError: (e, sT) async {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e\n$sT'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _total = 1;
        _received = 0;
      });
      return true;
    });

    while (!_load) {
      await Future.delayed(const Duration(microseconds: 500));
    }
  }

/*
  Future<void> notificationScheduled() async {
    int hour = 19;
    var ogValue = hour;
    int minute = 05;

    var time = Time(hour, minute, 20);

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      channelDescription: 'repeatDailyAtTime description',
      importance: Importance.max,
      // sound: 'slow_spring_board',
      ledColor: Color(0xFF3EB16F),
      ledOffMs: 1000,
      ledOnMs: 1000,
      enableLights: true,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterNotificationPlugin?.periodicallyShow(0, 'repeating title',
        'repeating body', RepeatInterval.everyMinute, platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список курсов'),
      ),
      bottomNavigationBar: (isLoad) ? null : const BottomMenu(),
      body: FutureBuilder<List<Course>>(
        future: getAllCourse(),
        builder: (BuildContext context, AsyncSnapshot<List<Course>> snapshot) {
          if (snapshot.hasData) {
            Future.delayed(Duration.zero, () => check(context));
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                Course item = snapshot.data![index];
                return Card(
                    child: ListTile(
                  title: Text(item.name!),
                  subtitle: Text("Модуль: " + item.moduleName!),
                  leading: null,
                  onTap: () {
                    if (isLoad) return;
                    Navigator.pushNamed(context, '/items', arguments: item)
                        .then((value) {
                      setState(() {});
                    });
                  },
                  trailing: FittedBox(
                      fit: BoxFit.fill,
                      child: Row(
                        children: <Widget>[
                          (isLoad)
                              ? SizedBox(
                                  width: 100,
                                  child: Column(children: <Widget>[
                                    LinearProgressIndicator(
                                      backgroundColor: (_index == index)
                                          ? null
                                          : Colors.white,
                                      value: (_index == index)
                                          ? _receivedItems / _totalItems
                                          : 0,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    LinearProgressIndicator(
                                      backgroundColor: (_index == index)
                                          ? null
                                          : Colors.white,
                                      value: (_index == index)
                                          ? _received / _total
                                          : 0,
                                    ),
                                  ]),
                                )
                              : (item.load ?? false)
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.cloud_done,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {},
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.cloud_download,
                                        color: Colors.green,
                                      ),
                                      onPressed: () async {
                                        await _downloadCourse(
                                            item, index, context);
                                      },
                                    ),
                          (!isLoad)
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.delete_sweep,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Удалить загруженные элементы курса?'),
                                            content: Text(item.name.toString()),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    if (isLoad) return;
                                                    var list =
                                                        await getCourseItem(
                                                            item.id);
                                                    for (Item itm in list) {
                                                      if (itm.load ?? false) {
                                                        final file = File(
                                                            itm.localpath!);
                                                        final exist =
                                                            await file.exists();
                                                        if (exist) {
                                                          file.deleteSync(
                                                              recursive: true);
                                                        }
                                                        itm.load = false;
                                                        itm.jsondata = "";
                                                        await updateItem(itm);
                                                      }
                                                    }
                                                    item.load = false;
                                                    await updateCourse(item);
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  },
                                                  child: const Text('Удалить')),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {});
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Отмена')),
                                            ],
                                          );
                                        });
                                  },
                                )
                              : Container(),
                        ],
                      )),
                ));
                /*
                return Dismissible(
                    key: UniqueKey(),
                    background: Container(color: Colors.red),
                    child: Card(
                      child: ListTile(
                        title: Text(item.name!),
                        subtitle: Text("Модуль: " + item.moduleName!),
                        //(item.dtend != null)
                        //    ? Text(GlobalData.getDateString(item.dtend!))
                        //    : null,
                        leading: null,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_sweep,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title:
                                        const Text('Удалить загруженный курс?'),
                                    content: Text(item.name.toString()),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            await deleteCourse(item.id!);
                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Удалить')),
                                      ElevatedButton(
                                          onPressed: () {
                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Отмена')),
                                    ],
                                  );
                                });
                          },
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/items',
                                  arguments: item)
                              .then((value) {
                            setState(() {});
                          });
                        },
                      ),

                    ),
                    onDismissed: (direction) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Удалить загруженный курс?'),
                              content: Text(item.name.toString()),
                              actions: [
                                ElevatedButton(
                                    onPressed: () async {
                                      await deleteCourse(item.id!);
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Удалить')),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена')),
                              ],
                            );
                          });
                    });
                    */
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<List<Item>> getCourseItem(id) async {
    Database db = await DBProvider.db.database as Database;
    var res = await db.query("Items", where: "courseid = ?", whereArgs: [id]);
    List<Item> list =
        res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
    return list;
  }
}
