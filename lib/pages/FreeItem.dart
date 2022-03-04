import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'package:myapp/widgets/config.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;

class FreePage extends StatefulWidget {
  const FreePage({
    Key? key,
  }) : super(key: key);

  @override
  State<FreePage> createState() => _FreePageState();
}

class _FreePageState extends State<FreePage> {
  TextEditingController editingController = TextEditingController();
  List<Item> _list = [];
  int _total = 1, _received = 0, _index = -1;
  String _filter = "";

  @override
  void initState() {
    super.initState();
  }

  Future<List<Item>> filterSearchResults() async {
    if (_list.isEmpty) {
      _list = await getFreeItem();
    }

    if (_filter.isEmpty) {
      return _list;
    } else {
      return _list
          .where((element) =>
              element.name?.toLowerCase().contains(_filter.toLowerCase()) ??
              false)
          .toList();
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Библиотека"),
      ),
      bottomNavigationBar: const BottomMenu(),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _filter = value;
                  });
                },
                controller: editingController,
                decoration: const InputDecoration(
                    labelText: "Поиск",
                    hintText: "Поиск",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Item>>(
                future: filterSearchResults(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
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
                                    data: ((item.type == "test")
                                            ? "ТЕСТ&nbsp;"
                                            : "") +
                                        item.description!),
                              ]),
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
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Удалить загруженный элемент?'),
                                                            content: Text(item
                                                                .name
                                                                .toString()),
                                                            actions: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    final file =
                                                                        File(item
                                                                            .localpath!);
                                                                    await file
                                                                        .delete();
                                                                    item.load =
                                                                        false;
                                                                    await updateItem(
                                                                        item);
                                                                    setState(
                                                                        () {});
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: const Text(
                                                                      'Удалить')),
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {});
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
                                if (!(item.load ?? false)) return;
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
            ),
          ],
        ),
      ),
    );
  }
}
