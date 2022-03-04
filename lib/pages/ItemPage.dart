import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'package:myapp/pages/exam/class/Test.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'package:myapp/widgets/http_post.dart';

import 'package:myapp/widgets/config.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/database/CourseModel.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;

class ItemPage extends StatefulWidget {
  const ItemPage({
    Key? key,
    //required this.course,
  }) : super(key: key);

  //final Course course;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  int _total = 1, _received = 0, _index = -1;

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() async {
    await initGlobalData();
  }

  openFile(filePath) async {
    var _result = await OpenFile.open(filePath);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_result.message),
      backgroundColor: Colors.blue,
    ));
  }

  Future<void> _downloadFile(Item itm, index, context) async {
    late StreamSubscription<List<int>> responseStream;
    final List<int> _bytes = [];

    var _url = GlobalData.baseUrl;
    var _file = itm.path;
    var _load = false;

    var isOnline = await hasNetwork(context);
    if (!isOnline) return;

    _index = index;
    final StreamedResponse _response =
        await http.Client().send(http.Request('GET', Uri.parse('$_url$_file')));
    _total = _response.contentLength ?? 0;

    responseStream = _response.stream.listen((value) {
      setState(() {
        _bytes.addAll(value);
        _received += value.length;
      });
    }, onDone: () async {
      responseStream.pause();
      if (itm.type == "SCORM") {
        var res = await httpAPI("close/students/mobileApp.asp",
            '{"command": "getScorm", "id": "${itm.guid}"}', context);

        /*
        var measure = "0";
        for (final element in (res as List<dynamic>)) {
          var decoded = base64.decode(element["xml"]);
          var sdata = utf8.decode(decoded);
          var myTransformer = Xml2Json();
          myTransformer.parse(sdata);
          var json = jsonDecode(myTransformer.toBadgerfish());
          var item = (json["item"] as Map<String, dynamic>);
          var key = item.keys
              .toList()
              .firstWhereOrNull((el) => el.contains("sequencing"));
          if (key != null) {
            item = (item[key] as Map<String, dynamic>);
            key = item.keys
                .toList()
                .firstWhereOrNull((el) => el.contains("rollupRules"));
            if (key != null) {
              item = (item[key] as Map<String, dynamic>);
              key = item.keys.toList().firstWhereOrNull(
                  (el) => el.contains("objectiveMeasureWeight"));
              if (key != null) measure = item[key];
            }
          }
          element["scope"] = measure.toString().replaceAll(",", ".");
          element["xml"] = "";
        }
        */

        itm.jsondata = '{"version": "V1p3", "toc": ' + jsonEncode(res) + '}';
      }
      if (itm.type == "test") {
        var res = await httpAPI("close/students/mobileApp.asp",
            '{"command": "getTest", "id": "${itm.guid}"}', context);
        itm.jsondata = jsonEncode(res);
      }
      var fn = itm.path!.split('/').last;
      final file = File(itm.localpath!);
      await file.writeAsBytes(_bytes, flush: true);
      itm.load = true;
      await updateItem(itm);

      await responseStream.cancel();
      _load = true;
      setState(() {
        _total = 1;
        _received = 0;
      });
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Course;

    if (GlobalData.baseUrl!.isEmpty ||
        GlobalData.username!.isEmpty ||
        GlobalData.password!.isEmpty) {
      Navigator.pushReplacementNamed(context, '/config');
      return const Scaffold();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Курс ' + args.name!),
      ),
      bottomNavigationBar: const BottomMenu(),
      body: FutureBuilder<List<Item>>(
        future: getCourseItem(args.id),
        builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  Item item = snapshot.data![index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        item.name!,
                        style: TextStyle(
                            color: (item.load ?? false)
                                ? Colors.black
                                : Colors.red),
                      ),
                      subtitle: Column(children: [
                        Html(
                            data: ((item.type == "test") ? "ТЕСТ&nbsp;" : "") +
                                item.description!),
                      ]),
                      //(item.dtend != null)
                      //    ? Text(GlobalData.getDateString(item.dtend!))
                      //    : null,
                      leading: (item.type == 'pdf')
                          ? const Icon(
                              Icons.picture_as_pdf_outlined,
                              color: Colors.blue,
                            )
                          : (item.type == 'png' ||
                                  item.type == 'jpg' ||
                                  item.type == 'gif')
                              ? const Icon(
                                  Icons.image,
                                  color: Colors.blue,
                                )
                              : (item.type == 'mp4')
                                  ? const Icon(
                                      Icons.video_camera_back_outlined,
                                      color: Colors.blue,
                                    )
                                  : (item.type == 'doc' ||
                                          item.type == 'docx' ||
                                          item.type == 'xls' ||
                                          item.type == 'xlsx')
                                      ? const Icon(
                                          Icons.document_scanner,
                                          color: Colors.blue,
                                        )
                                      : ((item.type == 'SCORM') && item.load!)
                                          ? IconButton(
                                              onPressed: () async {
                                                var isOnline =
                                                    await hasNetwork(context);
                                                if (!isOnline) return;
                                                var res = await httpAPI(
                                                    "close/students/sync.asp",
                                                    '{"id": "${item.guid}", "type": "SCORM"}',
                                                    context);
                                                item.attempt = (res as Map<
                                                    String,
                                                    dynamic>)["AttemptId"];
                                                Navigator.pushNamed(
                                                    context, '/syncSCORM',
                                                    arguments: item);
                                              },
                                              icon: const Icon(
                                                Icons.cloud_upload_rounded,
                                                color: Colors.green,
                                              ))
                                          : ((item.type == 'test') &&
                                                  item.load!)
                                              ? (item.sync!)
                                                  ? const CircularProgressIndicator()
                                                  : IconButton(
                                                      onPressed: () async {
                                                        var isOnline =
                                                            await hasNetwork(
                                                                context);
                                                        if (!isOnline) return;
                                                        item.sync = true;
                                                        await updateItem(item);
                                                        setState(() {});
                                                        var json = jsonDecode(
                                                            item.jsondata!);
                                                        for (var sec in json[
                                                            "sections"]) {
                                                          for (var q in sec[
                                                              "questions"]) {
                                                            q["Txt"] = "";
                                                          }
                                                        }
                                                        await httpAPI(
                                                            "close/students/sync.asp",
                                                            '{"id": "${item.guid}", "course": "${args.guid}", "type": "TEST", "data": ' +
                                                                jsonEncode(
                                                                    json) +
                                                                '}',
                                                            context);
                                                        item.sync = false;
                                                        await updateItem(item);
                                                        setState(() {});
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .cloud_upload_rounded,
                                                        color: Colors.green,
                                                      ))
                                              : null,
                      trailing: FittedBox(
                          fit: BoxFit.fill,
                          child: Row(
                            children: <Widget>[
                              (_total == 1)
                                  ? ((item.load ?? false)
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.delete_sweep,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Удалить загруженный элемент курса?'),
                                                    content: Text(
                                                        item.name.toString()),
                                                    actions: [
                                                      ElevatedButton(
                                                          onPressed: () async {
                                                            final file = File(
                                                                item.localpath!);
                                                            await file.delete();
                                                            item.load = false;
                                                            await updateItem(
                                                                item);
                                                            setState(() {});
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Удалить')),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            setState(() {});
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Отмена')),
                                                    ],
                                                  );
                                                });
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.download,
                                            color: Colors.green,
                                          ),
                                          onPressed: () async {
                                            await _downloadFile(
                                                item, index, context);
                                            setState(() {});
                                          },
                                        ))
                                  : CircularProgressIndicator(
                                      key: Key(index.toString()),
                                      value: (_index == index)
                                          ? _received / _total
                                          : 0,
                                    ),
                            ],
                          )),
                      onTap: () async {
                        if (!(item.load ?? false)) {
                          await _downloadFile(item, index, context);
                          if (!(item.load ?? false)) return;
                        }
                        if (item.type == "pdf") {
                          Navigator.pushNamed(context, '/viewPDF',
                              arguments: item);
                          return;
                        }
                        if (item.type == "mp4") {
                          Navigator.pushNamed(context, '/viewVideo',
                              arguments: item);
                          return;
                        }
                        if (item.type == 'png' ||
                            item.type == 'jpg' ||
                            item.type == 'gif') {
                          Navigator.pushNamed(context, '/viewPhoto',
                              arguments: item);
                          return;
                        }
                        if (item.type == "SCORM") {
                          Navigator.pushNamed(context, '/viewSCORM',
                                  arguments: item)
                              .then((value) {
                            setState(() {});
                          });
                          return;
                        }
                        if (item.type == "test") {
                          TTest test =
                              TTest.fromMap(jsonDecode(item.jsondata!));
                          test.localpath = item.localpath;
                          Navigator.pushNamed(context, '/test',
                              arguments: [item, test]).then((value) {
                            setState(() {});
                          });
                          return;
                        }

                        openFile(item.localpath);
                      },
                    ),
                  );
                });
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      /*
      floatingActionButton: FloatingActionButton(
        tooltip: "Загрузить данные с сервера",
        onPressed: () async {
          await initGlobalData();
          if (GlobalData.baseUrl == null ||
              GlobalData.username == null ||
              GlobalData.password == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Нет задана конфигурация'),
              backgroundColor: Colors.red,
            ));
            return;
          }
          Navigator.pushNamed(context, '/loaditem', arguments: args)
              .then((value) {
            setState(() {});
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      */
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
