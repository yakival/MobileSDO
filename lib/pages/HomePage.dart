import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:myapp/database/Database.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'dart:async';

import 'package:myapp/widgets/config.dart';
import 'package:myapp/database/CourseModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive.dart';

import 'package:http/http.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badge;

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
  Timer? _timer;
  bool checkProcess = false;
  bool _completed = false;

  final List cp1251 = [
    '\u0000',
    '\u0001',
    '\u0002',
    '\u0003',
    '\u0004',
    '\u0005',
    '\u0006',
    '\u0007',
    '\u0008',
    '\u0009',
    '\n',
    '\u000B',
    '\u000C',
    '\r',
    '\u000E',
    '\u000F',
    '\u0010',
    '\u0011',
    '\u0012',
    '\u0013',
    '\u0014',
    '\u0015',
    '\u0016',
    '\u0017',
    '\u0018',
    '\u0019',
    '\u001A',
    '\u001B',
    '\u001C',
    '\u001D',
    '\u001E',
    '\u001F',
    '\u0020',
    '\u0021',
    '\u0022',
    '\u0023',
    '\u0024',
    '\u0025',
    '\u0026',
    '\'',
    '\u0028',
    '\u0029',
    '\u002A',
    '\u002B',
    '\u002C',
    '\u002D',
    '\u002E',
    '\u002F',
    '\u0030',
    '\u0031',
    '\u0032',
    '\u0033',
    '\u0034',
    '\u0035',
    '\u0036',
    '\u0037',
    '\u0038',
    '\u0039',
    '\u003A',
    '\u003B',
    '\u003C',
    '\u003D',
    '\u003E',
    '\u003F',
    '\u0040',
    '\u0041',
    '\u0042',
    '\u0043',
    '\u0044',
    '\u0045',
    '\u0046',
    '\u0047',
    '\u0048',
    '\u0049',
    '\u004A',
    '\u004B',
    '\u004C',
    '\u004D',
    '\u004E',
    '\u004F',
    '\u0050',
    '\u0051',
    '\u0052',
    '\u0053',
    '\u0054',
    '\u0055',
    '\u0056',
    '\u0057',
    '\u0058',
    '\u0059',
    '\u005A',
    '\u005B',
    '\\',
    '\u005D',
    '\u005E',
    '\u005F',
    '\u0060',
    '\u0061',
    '\u0062',
    '\u0063',
    '\u0064',
    '\u0065',
    '\u0066',
    '\u0067',
    '\u0068',
    '\u0069',
    '\u006A',
    '\u006B',
    '\u006C',
    '\u006D',
    '\u006E',
    '\u006F',
    '\u0070',
    '\u0071',
    '\u0072',
    '\u0073',
    '\u0074',
    '\u0075',
    '\u0076',
    '\u0077',
    '\u0078',
    '\u0079',
    '\u007A',
    '\u007B',
    '\u007C',
    '\u007D',
    '\u007E',
    '\u007F',
    '\u0402',
    '\u0403',
    '\u201A',
    '\u0453',
    '\u201E',
    '\u2026',
    '\u2020',
    '\u2021',
    '\u20AC',
    '\u2030',
    '\u0409',
    '\u2039',
    '\u040A',
    '\u040C',
    '\u040B',
    '\u040F',
    '\u0452',
    '\u2018',
    '\u2019',
    '\u201C',
    '\u201D',
    '\u2022',
    '\u2013',
    '\u2014',
    '\uFFFD',
    '\u2122',
    '\u0459',
    '\u203A',
    '\u045A',
    '\u045C',
    '\u045B',
    '\u045F',
    '\u00A0',
    '\u040E',
    '\u045E',
    '\u0408',
    '\u00A4',
    '\u0490',
    '\u00A6',
    '\u00A7',
    '\u0401',
    '\u00A9',
    '\u0404',
    '\u00AB',
    '\u00AC',
    '\u00AD',
    '\u00AE',
    '\u0407',
    '\u00B0',
    '\u00B1',
    '\u0406',
    '\u0456',
    '\u0491',
    '\u00B5',
    '\u00B6',
    '\u00B7',
    '\u0451',
    '\u2116',
    '\u0454',
    '\u00BB',
    '\u0458',
    '\u0405',
    '\u0455',
    '\u0457',
    '\u0410',
    '\u0411',
    '\u0412',
    '\u0413',
    '\u0414',
    '\u0415',
    '\u0416',
    '\u0417',
    '\u0418',
    '\u0419',
    '\u041A',
    '\u041B',
    '\u041C',
    '\u041D',
    '\u041E',
    '\u041F',
    '\u0420',
    '\u0421',
    '\u0422',
    '\u0423',
    '\u0424',
    '\u0425',
    '\u0426',
    '\u0427',
    '\u0428',
    '\u0429',
    '\u042A',
    '\u042B',
    '\u042C',
    '\u042D',
    '\u042E',
    '\u042F',
    '\u0430',
    '\u0431',
    '\u0432',
    '\u0433',
    '\u0434',
    '\u0435',
    '\u0436',
    '\u0437',
    '\u0438',
    '\u0439',
    '\u043A',
    '\u043B',
    '\u043C',
    '\u043D',
    '\u043E',
    '\u043F',
    '\u0440',
    '\u0441',
    '\u0442',
    '\u0443',
    '\u0444',
    '\u0445',
    '\u0446',
    '\u0447',
    '\u0448',
    '\u0449',
    '\u044A',
    '\u044B',
    '\u044C',
    '\u044D',
    '\u044E',
    '\u044F'
  ];
  final List<int> enc =
      "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмноп---¦+¦¦¬¬¦¦¬---¬L+T+-+¦¦Lг¦T¦=+¦¦TTLL-г++----¦¦-рстуфхцчшщъыьэюяЁёЄєЇїЎў°•·v№¤¦ "
          .codeUnits;
  final encStr =
      "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмноп---¦+¦¦¬¬¦¦¬---¬L+T+-+¦¦Lг¦T¦=+¦¦TTLL-г++----¦¦-рстуфхцчшщъыьэюяЁёЄєЇїЎў°•·v№¤¦ ";

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

  void check(context) async {
    if (checkProcess) return;
    checkProcess = true;
    await initGlobalData();
    if (GlobalData.isReadAll){ checkProcess = false; return; }
    isOnline = await hasNetwork(context);
    if (isOnline) {
      Navigator.pushReplacementNamed(context, '/syncCourses').then((value) {
        setState(() { checkProcess = false; });
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

    var isOnline = await hasNetwork(context);
    if (!isOnline) return;

    setState(() {
      _total = 2;
      _received = 0;
    });
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
      List<int>.generate
        (data.lengthInBytes, (index) => 0);
      for (var i = 0; i < data.lengthInBytes; i++) {
        content[i] = data.getUint8(i);
      }
      archive = ZipDecoder().decodeBytes(content);
       */

      final inputStream = InputFileStream(itm.localpath!);
      archive = ZipDecoder().decodeBuffer(inputStream);

      for (ArchiveFile file_ in archive) {
        Uint8List bytesfn = Uint8List.fromList(file_.name.codeUnits);
        StringBuffer htmlBuffer = StringBuffer();
        for (int i = 0; i < bytesfn.length; i++) {
          if (bytesfn[i] > 127) {
            htmlBuffer.write(String.fromCharCode(enc[bytesfn[i] - 128]));
          } else {
            htmlBuffer.write(String.fromCharCode(bytesfn[i]));
          }
        }
        var decode = htmlBuffer.toString();
        if (file_.isFile) {
          List<int> data = file_.content;
          File('${file.parent.path}/${decode}')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('${file.parent.path}/${decode}')
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

  /*
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

      final Directory appDir = await getApplicationDocumentsDirectory();
      final checkPath =
      await Directory('${appDir.path}/storage/${itm.guid}').exists();
      if (!checkPath) {
        Directory('${appDir.path}/storage/${itm.guid}')
            .createSync(recursive: true);
      }

      final file = File(itm.localpath!);
      final exist = await file.exists();
      if (exist) file.deleteSync(recursive: true);
      await file.writeAsBytes(_bytes, flush: true);
      itm.load = true;
      await updateItem(itm);

      if (itm.type == "WRITING") {
        Archive archive;
        var bytes = await File(itm.localpath!).readAsBytes();
        ByteData data = bytes.buffer.asByteData();
        List<int> content =
        List<int>.generate(data.lengthInBytes, (index) => 0);
        for (var i = 0; i < data.lengthInBytes; i++) {
          content[i] = data.getUint8(i);
        }
        archive = ZipDecoder().decodeBytes(content);
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
      _load = true;
      return true;
    });

    while (!_load) {
      await Future.delayed(const Duration(microseconds: 500));
    }
  }

   */

  Future<List<Course>> getCourses() async {
    if(_completed){

      /*
      var isOnline = await hasNetwork(context);
      if (isOnline) {
        // ПОЛУЧАЕМ КУРСЫ ДЛЯ ПОЛУЧЕНИЯ ПРОЦЕНТА
        var res_ = await httpAPI(
            "close/students/mobileApp.asp", '{"command": "getCourses", "cmode": "completed"}', context);
        var _listCourse =
        (res_ as List).toList(); // map((i) => {"id": i["id"], }).toList();
        for (var itm in _listCourse) {
          var res = await getCourseGuidCompl(itm["guid"]!);
          if(res != null){
            Course val = res as Course;
            val.rate = itm["rate"];
            await updateCourseCompl(val);
          }
        }
      }
       */

      return getAllCourseCompl();
    }else{

      var isOnline = await hasNetwork(context);
      if (isOnline) {
        // ПОЛУЧАЕМ КУРСЫ ДЛЯ ПОЛУЧЕНИЯ ПРОЦЕНТА
        var res_ = await httpAPI(
            "close/students/mobileApp.asp", '{"command": "getCourses", "cmode": ""}', context);
        var _listCourse =
        (res_ as List).toList(); // map((i) => {"id": i["id"], }).toList();
        for (var itm in _listCourse) {
          var res = await getCourseGuid(itm["guid"]!);
          if(res != null){
            Course val = res as Course;
            val.rate = itm["rate"];

            var items = await getCourseItem(val.id);
            var items_ = items.where((element) => element.load ?? false);
            val.load = items.length == items_.length;

            await updateCourse(val);
          }
        }
      }

      return getAllCourse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => check(context));
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Мои курсы'),
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
                            })),
                  ],
                )
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Text("Активные")),
                  Tab(icon: Text("Пройденные")),
                ],
              ),
            ),
            bottomNavigationBar: (isLoad) ? null : const BottomMenu(),
            body: TabBarView(children: [
              Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: FutureBuilder<List<Course>>(
                    future: getCourses(),
                    builder: (BuildContext context, AsyncSnapshot<List<Course>> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data?.length,
                          itemBuilder: (BuildContext context, int index) {
                            Course item = snapshot.data![index];
                            return Card(
                                child: ListTile(
                                  title: Text(item.name!),
                                  subtitle:  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 7,
                                          child:
                                          LinearProgressIndicator(
                                            backgroundColor: Colors.black12,
                                            color: (item.description! == "100")?Colors.green:Colors.red,
                                            value: item.rate! / 100,
                                          ),
                                        ),
                                  Expanded(
                                      flex: 3,
                                      child:
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text('  ${item.rate.toString()}%',
                                            style: const TextStyle(color: Colors.blueGrey),
                                          ),
                                        )),
                                      ]),
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
                                              Icons.cloud_done_outlined,
                                              color: Colors.green,
                                            ),
                                            onPressed: () {},
                                          )
                                              : IconButton(
                                            icon: const Icon(
                                              Icons.download,
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
                                                                  final exist = await file
                                                                      .parent
                                                                      .exists();
                                                                  if (exist) {
                                                                    file.parent
                                                                        .deleteSync(
                                                                        recursive:
                                                                        true);
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
                          },
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
              ),
              Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: FutureBuilder<List<Course>>(
                    future: getAllCourseCompl(),
                    builder: (BuildContext context, AsyncSnapshot<List<Course>> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data?.length,
                          itemBuilder: (BuildContext context, int index) {
                            Course item = snapshot.data![index];
                            return Card(
                                child: ListTile(
                                  title: Text(item.name!),
                                  subtitle:  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 7,
                                          child:
                                          LinearProgressIndicator(
                                            backgroundColor: Colors.black12,
                                            color: (item.rate! == 100)?Colors.green:Colors.red,
                                            value: item.rate! / 100,
                                          ),
                                        ),
                              Expanded(
                                  flex: 3,
                                  child:
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text('  ${item.rate.toString()}%',
                                            style: const TextStyle(color: Colors.blueGrey),
                                          ),
                                        )),
                                      ]),
                                  trailing: FittedBox(
                                      fit: BoxFit.fill,
                                      child: Row(
                                        children: <Widget>[
                                          IconButton(
                                            icon: const Icon(
                                              Icons.receipt_long_outlined,
                                            ),
                                            color: ((item.rate ?? 0) == 100)?Colors.blue:Colors.white,
                                              onPressed: ((item.rate ?? 0) == 100)?
                                              () async {
                                              return;
                                                await initGlobalData();
                                              var itm = Item();
                                              itm.name = "Сертификат";
                                              var _url = 'https://${GlobalData.username}:${GlobalData.password}@myapp.prometeus.ru'; //GlobalData.baseUrl;
                                              var _username = GlobalData.username;
                                              var _password = GlobalData.password;
                                              var auth = 'Basic ' + base64Encode(utf8.encode('$_username:$_password'));
                                              itm.localpath = '$_url/close/modules/print_templates/?orderid=${item.orderid}';

                                              Navigator.pushNamed(context, '/viewHtml',
                                              arguments: itm);

                                              }
                                              :null,
                                            //onPressed: () {
                                            //},
                                          )
                                        ],
                                      )),
                                ));
                          },
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
              ),
            ])
        ));
  }

  Future<List<Item>> getCourseItem(id) async {
    Database db = await DBProvider.db.database as Database;
    var res = await db.query("Items", where: "courseid = ?", whereArgs: [id]);
    List<Item> list =
    res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
    return list;
  }
}
