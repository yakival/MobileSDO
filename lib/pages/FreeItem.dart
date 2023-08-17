import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:badges/badges.dart' as badge;
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'package:myapp/widgets/config.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

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
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) async {
      await initGlobalData();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    var _load = false;

    var isOnline = await hasNetwork(context);
    if (!isOnline) return;

    _index = index;

    if (itm.type == "SCORM") {
      var res = await httpAPI("close/students/mobileApp.asp",
          '{"command": "getScorm", "id": "${itm.guid}"}', context);
      var json = res as Map<String, dynamic>;
      itm.jsondata = '{"version": "' +
          json["version"] +
          '", "menu": ' +
          ((itm.menu ?? false) ? "true" : "false") +
          ', "toc": ' +
          jsonEncode(json["toc"]) +
          '}';
      itm.attempt = json["attemptid"];
    }
    if (itm.type == "test") {
      var res = await httpAPI("close/students/mobileApp.asp",
          '{"command": "getTest", "id": "${itm.guid}"}', context);
      itm.jsondata = jsonEncode(res);
    }
    if (itm.type == "CMP") {
      var res = await httpAPI("close/students/mobileApp.asp",
          '{"command": "getCMP", "id": "${itm.guid}"}', context);
      itm.path = res.toString();

      final Directory appDir = await getApplicationDocumentsDirectory();
      var fn = itm.path!.split('/').last;
      itm.localpath = '${appDir.path}/storage/${itm.guid}/$fn';
    }
    if (itm.type == "html") {
      var res = await httpAPI("close/students/mobileApp.asp",
          '{"command": "getZIP", "id": "${itm.guid}"}', context);
      itm.path = res.toString();
    }

    itm.localpath = await _downloadFileOne(itm.path, itm.guid, context);
    final file = File(itm.localpath!);

    if (itm.type == "WRITING") {
      Archive archive;
      /*
      var bytes = await File(itm.localpath!).readAsBytes();
      ByteData data = bytes.buffer.asByteData();
      List<int> content =
      List<int>.generate(data.lengthInBytes, (index) => 0);
      for (var i = 0; i < data.lengthInBytes; i++) {
        content[i] = data.getUint8(i);
      }
      archive = ZipDecoder().decodeBytes(content);
       */

      final inputStream = InputFileStream(itm.localpath!);
      archive = ZipDecoder().decodeBuffer(inputStream);

      for (ArchiveFile file_ in archive) {
        if (file_.isFile) {
          List<int> data = file_.content;
          File('${file.parent.path}/${file_.name}')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('${file.parent.path}/${file_.name}')
              .createSync(recursive: true);
        }
      }
      file.deleteSync();
    }

    itm.load = true;
    itm.sync = false;
    await updateItem(itm);
  }

  Future<String?> _downloadFileOne(fileName, localDir, context) async {
    late StreamSubscription<List<int>> responseStream;
    final List<int> _bytes = [];

    var _url = GlobalData.baseUrl;
    var _load = false;

    final Directory appDir = await getApplicationDocumentsDirectory();
    var fn = fileName.split('/').last;
    String? _file = '${appDir.path}/storage/${localDir}/$fn';

    Request req = Request('GET', Uri.parse('$_url$fileName'));
    req.headers.addAll(<String, String>{
      'Authorization': 'Basic ' + base64Encode(utf8.encode('$GlobalData.username:$GlobalData.password')),
    });
    final StreamedResponse _response =
    await Client().send(req);
    if (_response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_response.reasonPhrase!),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _total = 1;
        _received = 0;
      });
      return null;
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
      return null;
    }

    final checkPath =
    await Directory('${appDir.path}/storage/${localDir}').exists();
    if (!checkPath) {
      Directory('${appDir.path}/storage/${localDir}')
          .createSync(recursive: true);
    }
    final file = await File(_file);
    if(file.existsSync()){
      file.deleteSync(recursive: true);
    }

    responseStream = await _response.stream.listen((value) async {
      //_bytes.addAll(value);
      file.writeAsBytesSync(value, mode: FileMode.append, flush: true);
      setState(() {
        _received += value.length;
      });
    }, onDone: () async {
      responseStream.pause();
      await responseStream.cancel();
      _load = true;
      setState(() {
        _total = 1;
        _received = 0;
      });
    }, onError: (e, sT) async {
      file.deleteSync(recursive: true);
      _load = true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e\n$sT'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _total = 1;
        _received = 0;
      });
      _file = null;
      _load = true;
    });

    while (!_load) {
      await Future.delayed(const Duration(microseconds: 500));
    }
    return _file;
  }

  Future<double?> get getFreeDiskSpace async {
    const MethodChannel _channel = MethodChannel('disk_space');

    final double? freeDiskSpace =
        await _channel.invokeMethod('getFreeDiskSpace');
    return freeDiskSpace;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Библиотека"),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: (GlobalData.newNotification > 0)
                      ? badge.Badge(
                          position: badge.BadgePosition.topEnd(top: 0, end: 0),
                          badgeContent: Text('${GlobalData.newNotification}',
                              style: const TextStyle(color: Colors.white)),
                          child: IconButton(
                            icon: const Icon(Icons.notifications),
                            onPressed: () async {
                              Navigator.pushReplacementNamed(context, '/notify',
                                  arguments: 10);
                            },
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/notify',
                                arguments: 10);
                          },
                        ))
            ],
          )
        ],
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
                                        : Colors.grey),
                              ),
                              leading: (item.type == 'pdf')
                                  ? const Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          10.0, 0.0, 0.0, 0.0),
                                      child: Icon(
                                        Icons.picture_as_pdf_outlined,
                                        color: Colors.blue,
                                      ))
                                  : (item.type == 'png' ||
                                          item.type == 'jpg' ||
                                          item.type == 'gif')
                                      ? const Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10.0, 0.0, 0.0, 0.0),
                                          child: Icon(
                                            Icons.image,
                                            color: Colors.blue,
                                          ))
                                      : (item.type == 'mp4')
                                          ? const Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.0, 0.0, 0.0, 0.0),
                                              child: Icon(
                                                Icons
                                                    .video_camera_back_outlined,
                                                color: Colors.blue,
                                              ))
                                          : (item.type == 'html' ||
                                                  item.type == 'CMP')
                                              ? const Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      10.0, 0.0, 0.0, 0.0),
                                                  child: Icon(
                                                    Icons.web_outlined,
                                                    color: Colors.blue,
                                                  ))
                                              : (item.type == 'doc' ||
                                                      item.type == 'docx' ||
                                                      item.type == 'xls' ||
                                                      item.type == 'xlsx')
                                                  ? const Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10.0,
                                                              0.0,
                                                              0.0,
                                                              0.0),
                                                      child: Icon(
                                                        Icons.document_scanner,
                                                        color: Colors.blue,
                                                      ))
                                                  :
                              (item.type == "SCORM")?
                              const FittedBox(
                                  fit: BoxFit.fill,
                                  child: Text("SCORM",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.blueGrey),
                                  )):
                              (item.type == "test")?
                              const FittedBox(
                                  fit: BoxFit.fill,
                                  child: Text("ТЕСТ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.blueGrey),
                                  )):
                              null,
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
                                                                    if (file
                                                                        .parent
                                                                        .existsSync()) {
                                                                      file.parent.deleteSync(
                                                                          recursive:
                                                                              true);
                                                                    }
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
                                if (!(item.load ?? false)) {
                                  await _downloadFile(item, index, context);
                                  if (!(item.load ?? false)) return;
                                }

                                if (item.type == "pdf") {
                                  Navigator.pushNamed(context, '/viewPDF',
                                      arguments: item)
                                      .then((value) {
                                    setState(() {});
                                  });
                                  return;
                                }
                                if (item.type == "mp4") {
                                  Navigator.pushNamed(context, '/viewVideo',
                                      arguments: item)
                                      .then((value) {
                                    setState(() {});
                                  });
                                  return;
                                }
                                if (item.type == "html" || item.type == 'CMP') {
                                  Navigator.pushNamed(context, '/viewHtml',
                                      arguments: item)
                                      .then((value) {
                                    setState(() {});
                                  });
                                  return;
                                }
                                if (item.type == 'png' ||
                                    item.type == 'jpg' ||
                                    item.type == 'jpeg' ||
                                    item.type == 'gif') {
                                  Navigator.pushNamed(context, '/viewPhoto',
                                      arguments: item)
                                      .then((value) {
                                    setState(() {});
                                  });
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

                                Navigator.pushNamed(context, '/player', arguments: item)
                                    .then((value) {
                                  setState(() {});
                                });
                                //openFile(item.localpath);
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
