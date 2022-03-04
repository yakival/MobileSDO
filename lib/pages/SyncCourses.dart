import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/database/CourseModel.dart';
import 'package:myapp/database/Database.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/database/WebinarModel.dart';
import 'package:myapp/widgets/config.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SyncCourses extends StatefulWidget {
  const SyncCourses({
    Key? key,
  }) : super(key: key);

  @override
  State<SyncCourses> createState() => _SyncCoursesState();
}

class _SyncCoursesState extends State<SyncCourses> {
  final List<dynamic> _list = [];
  bool isrun = false;

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> _getData(context) async {
    List<dynamic> _listCourse = [];
    List<dynamic> _listItem = [];

    if (_list.isEmpty) {
      await initGlobalData();
      var isOnline = await hasNetwork(context);
      if (!isOnline) {
        return _list;
      }

      var res_ = await httpAPI("close/students/mobileApp.asp",
          '{"command": "getWebinars"}', context);
      var _listWebinar = (res_ as List).toList();
      deleteAllWebinar();
      for (var itm in _listWebinar) {
        await newWebinar(Webinar.fromMap(itm));
      }

      // ПОЛУЧАЕМ ЭЛЕМЕНТЫ БИБЛИОТЕКИ
      res_ = await httpAPI(
          "close/students/mobileApp.asp", '{"command": "getBooks"}', context);
      _listItem = (res_ as List).toList();
      for (var itm in _listItem) {
        itm["load"] = false;
        var res = await getItemGuid(itm["guid"]!);
        itm["checked"] = (res == null) ? false : true;
        itm["courseid"] = null;
        _list.add(itm);
      }

      // УАДАЛЯЕМ ЛИШНИЕ ЭЛЕМЕНТЫ В БИБЛИОТЕКЕ
      var guid = _listItem.map((i) => "'" + i["guid"] + "'").toList();
      Database db = await DBProvider.db.database as Database;
      var res = await db.query("Items",
          where: "courseid = ? and (guid not in (" +
              guid.toString().replaceAll("[", "").replaceAll("]", "") +
              "))",
          whereArgs: [0]);
      List<Item> list1 =
          res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
      for (var itm in list1) {
        if (File(itm.localpath!).existsSync()) {
          final file = File(itm.localpath!);
          await file.delete();
        }
        await deleteItem(itm);
      }

      // ПОЛУЧАЕМ КУРСЫ
      res_ = await httpAPI(
          "close/students/mobileApp.asp", '{"command": "getCourses"}', context);
      _listCourse =
          (res_ as List).toList(); // map((i) => {"id": i["id"], }).toList();
      for (var itm in _listCourse) {
        var res = await getCourseGuid(itm["guid"]!);
        itm["checked"] = (res == null) ? false : true;
        if (itm["checked"]) itm["id"] = res.id;
        itm["description"] = "КУРС";
        _list.add(itm);
      }

      // ПОЛУЧАЕМ ЭЛЕМЕНТЫ КУРСОВ
      for (var itmc in _listCourse) {
        res_ = await httpAPI("close/students/mobileApp.asp",
            '{"command": "getCourse", "id": "' + itmc["guid"] + '"}', context);
        _listItem = (res_ as List).toList();
        for (var itm in _listItem) {
          itm["load"] = false;
          var res = await getItemGuid(itm["guid"]!);
          itm["checked"] = (res == null) ? false : true;
          itm["courseid"] = itmc["guid"];
          _list.add(itm);
        }

        // УАДАЛЯЕМ ЛИШНИЕ ЭЛЕМЕНТЫ В КУУРСЕ
        if (itmc["checked"]) {
          var guid = _listItem.map((i) => "'" + i["guid"] + "'").toList();
          Database db = await DBProvider.db.database as Database;
          var res = await db.query("Items",
              where: "courseid = ? and (guid not in (" +
                  guid.toString().replaceAll("[", "").replaceAll("]", "") +
                  "))",
              whereArgs: [itmc["id"]]);
          List<Item> list =
              res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
          for (var itm in list) {
            if (File(itm.localpath!).existsSync()) {
              final file = File(itm.localpath!);
              await file.delete();
            }
            await deleteItem(itm);
          }
        }
      }

      // УАДАЛЯЕМ ЛИШНИЕ КУРСЫ
      guid = _listCourse.map((i) => "'" + i["guid"] + "'").toList();
      db = await DBProvider.db.database as Database;
      res = await db.query("Course",
          where: "(guid not in (" +
              guid.toString().replaceAll("[", "").replaceAll("]", "") +
              "))",
          whereArgs: []);
      List<Course> list =
          res.isNotEmpty ? res.map((c) => Course.fromMap(c)).toList() : [];
      for (var itm in list) {
        var items = await getCourseItem(itm.id);
        for (Item itm_ in items) {
          if (File(itm_.localpath!).existsSync()) {
            final file = File(itm_.localpath!);
            await file.delete();
          }
          await deleteItem(itm_);
        }
        await deleteCourse(itm.id!);
      }
    }
    return _list;
  }

  void runMigrate(context) async {
    isrun = true;

    if (_list.isNotEmpty) {
      for (var itm in _list) {
        var key = false;
        var keys = itm.keys.toList();
        for (var el in keys) {
          if (el == "courseid") {
            key = true;
            break;
          }
        }
        if (!itm["checked"]) {
          itm["checked"] = true;
          if (key) {
            if (itm["courseid"] != null) {
              var course_ = await getCourseGuid(itm["courseid"]);
              itm["courseid"] = course_.id;
            } else {
              itm["courseid"] = 0;
            }
            var fn = itm["path"]!.split('/').last;
            var ext = itm["path"]!.split('.').last;
            itm["localpath"] =
                '${(await getApplicationDocumentsDirectory()).path}/$fn';
            if ((itm["type"] != "SCORM") && (itm["type"] != "test")) {
              itm["type"] = ext;
            }
            itm["load"] = false;
            await newItem(Item.fromMap(itm));
          } else {
            await newCourse(Course.fromMap(itm));
          }
          setState(() {});
        } else {
          if (key) {
            if (itm["type"] == "test") {
              Item itm_ = await getItemGuid(itm["guid"]);
              itm_.description = itm["description"];
              await updateItem(itm_);
            }
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Оглавление обновлено'),
        backgroundColor: Colors.yellow[900],
      ));
      setState(() {});
    }
    GlobalData.isReadAll = true;
    Navigator.popAndPushNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Обновление оглавления'), actions: <Widget>[
        FittedBox(
            fit: BoxFit.fill,
            child: Row(children: const <Widget>[
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ])),
      ]),
      //drawer: const LeftMenu(),
      body: FutureBuilder<List<dynamic>>(
          future: _getData(context),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              if (!isrun) {
                Future.delayed(Duration.zero, () => runMigrate(context));
              }
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var item = snapshot.data![index];
                    return ListTile(
                      title: Text(item["name"].toString()),
                      trailing: Checkbox(
                        value:
                            (item["checked"] != null) ? item["checked"] : false,
                        onChanged: null,
                      ),
                    );
                  });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  //_downloadFile(item, int index, BuildContext context) {}
}

class _getData {}
