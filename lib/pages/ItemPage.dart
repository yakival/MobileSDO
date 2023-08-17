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
import 'package:grouped_list/grouped_list.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:myapp/pages/exam/class/Access.dart';
import 'package:myapp/pages/exam/class/Test.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:archive/archive.dart';

import 'package:myapp/widgets/config.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/database/CourseModel.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:windows1251/windows1251.dart';
import 'package:simple_html_css/simple_html_css.dart';

import 'exam/class/Answer.dart';
import 'exam/class/Question.dart';
import 'exam/class/Section.dart';

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
  int _total = 1, _received = 0;
  String _index = "";

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
  Timer? _timer;
  var history;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) async {
      await initGlobalData();
      setState(() {});
    });
    super.initState();
    init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

    var isOnline = await hasNetwork(context);
    if (!isOnline) return;

    _index = index;

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

  Future<double?> get getFreeDiskSpace async {
    const MethodChannel _channel = MethodChannel('disk_space');

    final double? freeDiskSpace =
    await _channel.invokeMethod('getFreeDiskSpace');
    return freeDiskSpace;
  }

  getName(Item itm) {
    String nm = itm.name ?? "";
    if (itm.type == "WRITING") {
      nm = nm.replaceAll("%oncheck2%", " [на повторной проверке]");
      nm = nm.replaceAll("%oncheck%", " [на проверке]");
      nm = nm.replaceAll("%failed%", " [возврат]");
      nm = nm.replaceAll("%passed%", " [проверено]");
    }
    return nm;
  }

  getStatusString(Item itm) {
    String nm = itm.description ?? "{}";
    String status = "";
    if (itm.type == "WRITING") {
      status = jsonDecode(nm)["status"] ?? "";
      status = status.replaceAll("oncheck2", "На повторной проверке");
      status = status.replaceAll("oncheck", "На проверке");
      status = status.replaceAll("failed", "Возврат");
      status = status.replaceAll("passed2", "Проверено повторно");
      status = status.replaceAll("passed", "Проверено");
      status = status.replaceAll("null", "");
    }
    return status;
  }

  Future<bool> getLinks(Item itm) async {
    // Проверяем материалы
    if ((itm.links ?? "") != "") {
      List<Item> ret = [];
      var arr = itm.links!.split(",");
      for (var el in arr) {
        Item rec = await getItemGuid(el);

        if (rec.type == "test") {
          var arr = rec.description!.split("/");
          var val = 0;
          if (arr.length > 1) {
            if (arr[1] != "") {
              val = int.parse(arr[1]);
            }
          }
          if (val < rec.rate!) {
            ret.add(rec);
          }
        } else {
          if ((rec.time ?? 0) < (rec.rate ?? 0)) {
            ret.add(rec);
          }
        }
      }
      if (ret.isNotEmpty) {
        Navigator.pushNamed(context, '/alert', arguments: [itm, ret]);
        return true;
      }
    }

    // Проверяем допуск
    if (itm.type == "test") {
      var fnd = false;
      TTest test = TTest.fromMap(jsonDecode(itm.jsondata!));
      if (test.IdType == "t") {
        if(itm.access != null) {
          var arrAccess = (jsonDecode(itm.access!) as List).toList();
          var date = DateTime.now();
          for (var access in arrAccess) {
            var from = DateTime.parse(access["dtfrom"].toString());
            var to = DateTime.parse(access["dtto"].toString());
            if ((from.isBefore(date)) &&
                (to.isAfter(date))) {
              fnd = true;
              break;
            }
          }
        }
        if (!fnd) {
          Navigator.pushNamed(context, '/alert', arguments: [itm, null]);
          return true;
        }
      }
    }

    return false;
  }

  String getRateBook(Item item) {
    String ret = "";
    if (item.rate! > 0) {
      ret = ret + format(Duration(minutes: item.rate!)) + " / ";
    }
    ret = ret + format(Duration(minutes: item.time!));
    return ("<span style='font-size: 12px;'><b>" + ret + "</b></span>");
  }

  double getRateBookPr(Item item) {
    String ret = "";
    if(item.rate! == 0){
      if(item.time == null){
        return 0;
      }else{
        return 100;
      }
    }

    item.time ??= 0;

    if(item.time! > item.rate!){
      item.time = item.rate!;
    }
    if (item.rate! > 0) {
      return item.time! / (item.rate! / 100);
    }else{
      return 100;
    }
  }

  double getTestPr(String descr) {
    var arr = (descr ?? "").split("/");

    var ret = 0.0;
    if(arr.length > 1){
      if(arr[1] != ""){
        return (double.parse(arr[1]) == -1)?0:double.parse(arr[1]);
      }
    }
    return ret;
  }

  MaterialColor getTestColor(String descr) {
    var arr = (descr ?? "").split("/");

    var ret = Colors.blue;
    if(arr.length > 1){
      if(arr[2] == "1"){
        ret = Colors.green;
      }
    }
    return ret;
  }

  String getTestCr(String descr) {
    var ret = "";

    var arr = (descr ?? "").split("/");
    if(arr.length > 1){
      if(arr[5] != ""){
        ret = '<span style="color: ${arr[6]}">${arr[5]}</span>';
      }
    }
    return ret;
  }

  format(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0").substring(0, 5);

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
        title: Text(args.name!),
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
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/notify',
                            arguments: 10);
                      },
                    ),
                  )
                      : IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/notify',
                          arguments: 10);
                    },
                  ))
            ],
          )
        ],
      ),
      bottomNavigationBar: const BottomMenu(),
      body: FutureBuilder<List<Item>>(
        future: getCourseItem(args.id),
        builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
          if (snapshot.hasData) {
            return //ListView.builder(
              //itemCount: snapshot.data?.length,
              //itemBuilder: (BuildContext context, int index) {
              //Item item = snapshot.data![index];
              GroupedListView<Item, String>(
                  elements: snapshot.data!,
                  groupBy: (element) => (element.modulename ?? ""),
                  groupComparator: (value1, value2) => value2.compareTo(value1),
                  itemComparator: (item1, item2) =>
                      (item1.modulename ?? "").compareTo((item2.modulename ?? "")),
                  order: GroupedListOrder.DESC,
                  useStickyGroupSeparators: true,
                  groupSeparatorBuilder: (String value) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, color: Colors.blueGrey),
                    ),
                  ),
                  itemBuilder: (BuildContext context, element) {
                    Item item = element;
                    String index = item.guid!;
                    return Card(
                      child: ListTile(
                        //isThreeLine: true,
                        title: Row(
                          //textDirection: TextDirection.RTL,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                getName(item),
                                style: TextStyle(
                                    color: (item.load ?? false)
                                        ? Colors.black
                                        : Colors.grey),
                              )
                            ),
                            (item.type == "WRITING" && jsonDecode(item.description ?? '{"comment": ""}')["comment"] != "")?
                            IconButton(
                              icon: const Icon(
                                Icons.comment,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Container(
                                            decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Color(0xff4B4F96), Color(0xff78B1CF)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text('${item.name!}',style: const TextStyle(color: Colors.white),),
                                            )
                                        ),
                                        content: writingComment(context, item),
                                      );
                                    }
                                ).then((value) {
                                  setState(() {});
                                });
                              },
                            ):
                            (item.type == "test" && (item.history ?? "[]") != "[]")?
                            IconButton(
                              icon: const Icon(
                                Icons.history,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                history = jsonDecode(item.history!);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Container(
                                            decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Color(0xff4B4F96), Color(0xff78B1CF)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text('${item.name!}',style: const TextStyle(color: Colors.white),),
                                            )
                                        ),
                                        content: historySelect(context, item),
                                      );
                                    }
                                ).then((value) {
                                  setState(() {});
                                });
                              },
                            )
                                :Container()
                            ,
                          ],
                        ),
                        subtitle: Column(children: [
                          ((item.type != "test") &&
                              (item.type != "WRITING") && (item.type != "SCORM"))?
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child:
                                  LinearProgressIndicator(
                                    backgroundColor: Colors.black12,
                                    color: (getRateBookPr(item).round() == 100)?Colors.green:Colors.red,
                                    value: getRateBookPr(item) / 100,
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child:
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('  ${getRateBookPr(item).round()}%',
                                    style: const TextStyle(color: Colors.blueGrey),
                                  ),
                                )),
                              ]):
                          (item.type == "SCORM")?
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child:
                                  LinearProgressIndicator(
                                    backgroundColor: Colors.black12,
                                    color: (item.rate == 100)?Colors.green:Colors.red,
                                    value: (item.rate ?? 0) / 100,
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child:                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('  ${item.rate ?? 0}%',
                                    style: const TextStyle(color: Colors.blueGrey),
                                  ),
                                )),
                              ]):

                          (item.type == "test")?
                              Column(
                                children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child:
                                  LinearProgressIndicator(
                                    backgroundColor: Colors.black12,
                                    color: getTestColor(item.description!),
                                    value: getTestPr(item.description!) / 100,
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child:
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('  ${getTestPr(item.description!).round()}%',
                                    style: const TextStyle(color: Colors.blueGrey),
                                  ),
                                )),
                              ]),
                                  RichText(
                                      text: HTML.toTextSpan(
                                          context,
                                          '<div style="width: 100%, text-align: left; font-size: 12px;">' +
                                          getTestCr(item.description!) +
                                          "</div>")),
                              ]):

                          (item.type == "WRITING")?
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child:
                                  Text(getStatusString(item),
                                    style: const TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child:
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text((item.attempt != null)?'  ${item.attempt}':"",
                                    style: const TextStyle(color: Colors.blueGrey),
                                  ),
                                )),
                              ]):
                          RichText(
                              text: HTML.toTextSpan(
                                  context,
                                  "<div style='width: 100%, text-align: left;'>" +
                                      ((item.type == "test")
                                          ? "ТЕСТ&nbsp;" + item.description!
                                          : (item.type == "CMP")
                                          ? "СТРАНИЦА&nbsp;" +
                                          item.description!
                                          : (item.type == "WRITING")
                                          ? "ПИСМЕННАЯ РАБОТА&nbsp;"
                                          : (item.type == "SCORM")
                                          ? "SCORM ${item.rate!}"
                                          : ("<span style='font-size: 10pt;'>Время просмотра:&nbsp;&nbsp;" +
                                          getRateBook(item) +
                                          "</span>") +
                                          "</div>"))),
                        ]),
                        //(item.dtend != null)
                        //    ? Text(GlobalData.getDateString(item.dtend!))
                        //    : null,
                        leading: (!((item.type == 'SCORM') || (item.type == 'test') || (item.type == 'WRITING')))?
                        (item.type == 'pdf')
                            ? const Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                            child: Icon(
                              Icons.picture_as_pdf_outlined,
                              color: Colors.blue,
                            ))
                            : (item.type == 'png' ||
                            item.type == 'jpg' ||
                            item.type == 'jpeg' ||
                            item.type == 'gif')
                            ? const Padding(
                            padding:
                            EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                            child: Icon(
                              Icons.image,
                              color: Colors.blue,
                            ))
                            : (item.type == 'mp4')
                            ? const Padding(
                            padding: EdgeInsets.fromLTRB(
                                10.0, 0.0, 0.0, 0.0),
                            child: Icon(
                              Icons.video_camera_back_outlined,
                              color: Colors.blue,
                            ))
                            : (item.type == 'html' || item.type == 'CMP')
                            ? const Padding(
                            padding: EdgeInsets.fromLTRB(
                                10.0, 0.0, 0.0, 0.0),
                            child: Icon(
                              Icons.web_outlined,
                              color: Colors.blue,
                            ))
                            : const Padding(
                            padding: EdgeInsets.fromLTRB(
                                10.0, 0.0, 0.0, 0.0),
                            child: Icon(
                              Icons.document_scanner,
                              color: Colors.blue,
                            ))
                            :

                        (item.type == 'SCORM')?
                        (item.load!)
                            ? (item.sync!)
                            ? FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                                children: <Widget>[
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const <Widget>[
                                        CircularProgressIndicator(),
                                        Text("SCORM",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.blueGrey),
                                        ),
                                      ])
                                ]))
                            : FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                                children: <Widget>[Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                          onPressed: () async {
                                            var isOnline =
                                            await hasNetwork(
                                                context);
                                            if (!isOnline) return;
                                            item.sync = true;
                                            await updateItem(item);
                                            setState(() {});

                                            var ss = "";
                                            var cs = "";
                                            var sd = "";
                                            var max = "";
                                            var raw = "";
                                            var scaled = "";
                                            var data = jsonDecode(item.jsondata!); // as Map<String, dynamic>
                                            if(data["data"] != null) {
                                              data["data"].keys.forEach((key) {
                                                if (key.contains(".success_status")) {
                                                  ss = data["data"][key];
                                                }
                                                if (key.contains(".completion_status")) {
                                                  cs = data["data"][key];
                                                }
                                                if (key.contains(".suspend_data")) {
                                                  sd = data["data"][key];
                                                }
                                                if (key.contains(".raw")) {
                                                  raw = data["data"][key];
                                                }
                                                if (key.contains(".max")) {
                                                  max = data["data"][key];
                                                }
                                                if (key.contains(".scaled")) {
                                                  scaled = data["data"][key];
                                                }
                                              });
                                            }

                                            var newtotal=0.0;
                                            if (ss=="passed" && scaled=="" && raw=="") {
                                              newtotal=100;
                                            } else if (scaled!="") {
                                              newtotal=double.parse(scaled)*100;
                                            } else if (max!="" && raw!="") {
                                              newtotal=double.parse(raw)/(double.parse(max)/100);
                                            } else if (raw!="") {
                                              newtotal=double.parse(raw);
                                            }
                                            if (newtotal>100) newtotal=100;

                                            var res = await httpAPI(
                                                "close/students/sync.asp",
                                                '{"id": "${item.guid}", ' +
                                                    '"type": "SCORM", "courseid": "${args.guid}", '+
                                                    '"attemptid": ${item.attempt}, ' +
                                                    '"cs": "${cs}", ' +
                                                    '"ss": "${ss}", ' +
                                                    '"sd": "${sd}", ' +
                                                    '"rate": "${newtotal.ceil()}", ' +
                                                    '"data": ${jsonEncode(data["data"])}}',
                                                context);
                                            var obj = (res as Map<
                                                String, dynamic>);
                                            item.rate = newtotal.ceil(); //obj["rate"];
                                            item.sync = false;
                                            await updateItem(item);
                                            setState(() {});
                                            /*
                            item.attempt =
                                obj["AttemptId"]
                                    .toString();
                            Navigator.pushNamed(
                                context, '/syncSCORM',
                                arguments: item);
                                */
                                          },
                                          icon: const Icon(
                                            Icons
                                                .cloud_upload_rounded,
                                            color: Colors.green,
                                          )),
                                      const Text("SCORM",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.blueGrey),
                                      ),
                                    ])
                                ]))
                            : FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                                children: <Widget>[
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const <Widget>[
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                5.0, 0.0, 0.0, 0.0),
                                            child: Icon(
                                              Icons.copy_outlined,
                                              color: Colors.blue,
                                            )),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10.0, 0.0, 0.0, 0.0),
                                            child: Text("SCORM",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12, color: Colors.blueGrey),
                                            ))
                                      ])])):

                        (item.type == 'test')?
                        (item.load! && (!item.jsondata!.contains('"IdType":"t"')))
                            ? (item.sync!)
                            ? FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                                children: <Widget>[
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const <Widget>[
                                        CircularProgressIndicator(),
                                        Text("ТЕСТ",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.blueGrey),
                                        ),
                                      ])
                                ]))
                            : FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                                children: <Widget>[Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                          onPressed: () async {
                                            if(!item.exec!){
                                              return;
                                            }
                                            var isOnline =
                                            await hasNetwork(
                                                context);
                                            if (!isOnline) {
                                              return;
                                            }
                                            item.sync = true;
                                            await updateItem(
                                                item);
                                            setState(() {});
                                            var json =
                                            jsonDecode(item
                                                .jsondata!);
                                            //for (var sec in json[
                                            //"sections"]) {
                                            //  for (var q in sec[
                                            //  "questions"]) {
                                            //    q["Txt"] = "";
                                            //  }
                                            //}
                                            var res = await httpAPI(
                                                "close/students/sync.asp",
                                                '{"id": "${item.guid}", "course": "${args.guid}", "type": "TEST", "data": ' +
                                                    jsonEncode(
                                                        json) +
                                                    '}',
                                                context) as Map<
                                                String,
                                                dynamic>;
                                            item.description = res["description"];
                                            item.history = null;
                                            if(res["history"] != null){
                                              item.history = jsonEncode(res["history"]);
                                            }
                                            item.sync = false;
                                            await updateItem(
                                                item);
                                            setState(() {});
                                          },
                                          icon: const Icon(
                                            Icons
                                                .cloud_upload_rounded,
                                            color: Colors.green,
                                          )),
                                      const Text("ТЕСТ",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.blueGrey),
                                      ),
                                    ])
                                ]))
                            : FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                                children: <Widget>[
                            Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                                children: const <Widget>[
                                Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 0.0, 0.0, 0.0),
                                    child: Icon(
                                      Icons.help_outline,
                                      color: Colors.blue,
                                    )),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          10.0, 0.0, 0.0, 0.0),
                                      child: Text("ТЕСТ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.blueGrey),
                            ))
                                ])]))
                            :

                        ((item.type == 'WRITING') &&
                            (item.attempt !=
                                "null"))
                            ?

                            /*
                        CircleAvatar(
                          backgroundColor:
                          Color(0xff60be9d),
                          child: (item.attempt
                              .toString()
                              .length >
                              1)
                              ? Html(
                              data: "<span style='font-size: 8pt;'>" +
                                  item.attempt
                                      .toString() +
                                  "</span>")
                              : Text(item
                              .attempt
                              .toString()),
                        )
                             */
                        FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                                children: <Widget>[
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const <Widget>[
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10.0, 0.0, 0.0, 0.0),
                                            child: Icon(
                                          Icons.note_alt_outlined,
                                          color: Colors.blue,
                                        )),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10.0, 0.0, 0.0, 0.0),
                                            child: Text("ПР",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.blueGrey),
                                        )),
                                      ])
                                ]))

                            : ((item.type ==
                            'WRITING') &&
                            (item.load!))
                            ? (item.sync!)
                            ? const CircularProgressIndicator()
                            : FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                                children: <Widget>[Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  IconButton(
                            onPressed:
                                () async {
                              if (item
                                  .description!
                                  .contains(
                                  "oncheck")) {
                                return;
                              }
                              var isOnline =
                              await hasNetwork(
                                  context);
                              if (!isOnline ||
                                  (item.jsondata ??
                                      "") ==
                                      "") {
                                return;
                              }
                              item.sync =
                              true;
                              await updateItem(
                                  item);
                              setState(
                                      () {});
                              String?
                              fpath;
                              await showDialog(
                                  context:
                                  context,
                                  builder:
                                      (BuildContext
                                  context) {
                                    return AlertDialog(
                                      title:
                                      const Text('Выбрать файл?'),
                                      content:
                                      const Text("Буден закреплён к ответу на писменную работу."),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              FilePickerResult? result = await FilePicker.platform.pickFiles();
                                              if (result != null) {
                                                //File file = File(result
                                                //    .files
                                                //    .single
                                                //    .path!);
                                                fpath = result.files.single.path;
                                              }
                                              setState(() {});
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Выбрать')),
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {});
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Отмена')),
                                      ],
                                    );
                                  });
                              Course val = await getCourse(item.courseid!) as Course;
                              var data = jsonDecode(args.description!);
                              data["status"] = (data["status"] == "failed")?"oncheck2":"oncheck";
                              await httpAPI(
                                  "close/students/sync.asp",
                                  '{"id":"' +
                                      item.guid! +
                                      '", "orderid":"' +
                                      val.orderid! +
                                      '", "status":"' +
                                      data["status"] +
                                      '", "type":"WRITING~1", "data":"' +
                                      item.jsondata!.replaceAll('"', "&quot;") +
                                      '"}',
                                  context);
                              await httpAPIMultipart(
                                  "close/students/sync.asp",
                                  '{"id":"' + item.guid! + '", "orderid":"' +
                                      val.orderid! +
                                      '", "type":"WRITING~2"}',
                                  fpath,
                                  context);
                              item.description = jsonEncode(data);
                              item.sync =
                              false;
                              await updateItem(
                                  item);
                              setState(
                                      () {});
                            },
                            icon:
                            const Icon(
                              Icons
                                  .cloud_upload_rounded,
                              color: Colors
                                  .green,
                            )),
                              const Text("ПР",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                fontSize: 12, color: Colors.blueGrey),
                                ),
                          ])
                                ]))
                            :
                        FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                                children: <Widget>[
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const <Widget>[
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10.0, 0.0, 0.0, 0.0),
                                            child: Icon(
                                              Icons.note_alt_outlined,
                                              color: Colors.blue,
                                            )),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10.0, 0.0, 0.0, 0.0),
                                            child: Text("ПР",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12, color: Colors.blueGrey),
                                            )),
                                      ])
                                ]))
                        ,
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
                                            content:
                                            Text(getName(item)),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    final file = File(
                                                        item.localpath!);
                                                    if (file.parent
                                                        .existsSync()) {
                                                      file.parent
                                                          .deleteSync(
                                                          recursive:
                                                          true);
                                                    }
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

                          var lnk = await getLinks(item);
                          if (lnk) {
                            return;
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
                          if (item.type == "test") {
                            TTest test =
                            TTest.fromMap(jsonDecode(item.jsondata!));
                            test.localpath = item.localpath;
                            // ОЧИЩАЕМ РЕЗУЛЬТАТЫ
                            if (test.IdType! == "r" || test.IdType! == "s") {
                              for (TSection sec in test.sections!) {
                                for (TQuestion q in sec.questions!) {
                                  q.IsMarked = null;
                                  q.Active = null;
                                  for (TAnswer ans in q.answers!) {
                                    ans.answer = null;
                                  }
                                }
                              }
                              item.time = 0;
                              item.jsondata = jsonEncode(test.toMap());
                              await updateItem(item);
                            }
                            Navigator.pushNamed(context, '/test',
                                arguments: [item, test]).then((value) {
                              setState(() {});
                            });
                            return;
                          }
                          if (item.type == "WRITING") {
                            Navigator.pushNamed(context, '/writeritem',
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
    );
  }

  Widget historySelect(context, Item itm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 300.0, // Change as per your requirement
          width: 300.0, // Change as per your requirement
          child: ListView.builder(

            shrinkWrap: true,
            itemCount: history.length,
            itemBuilder: (BuildContext context, int index) {
              var itemf = history[index];
              return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Color(0xFF92C8EA),
                    ),
                  ),
                  child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            '${DateFormat("dd.MM.yyyy HH:mm").format(DateTime.parse(itemf["dt"].toString()))}',
                            style: const TextStyle(
                              color: Color(0xFF4C5193),
                            )
                        ),
                      ),
                      subtitle: Column(
                          children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    child:
                                    LinearProgressIndicator(
                                      backgroundColor: Colors.black12,
                                      color: (getTestPr(itemf["description"]) == 100)?Colors.green:Colors.red,
                                      value: getTestPr(itemf["description"]) / 100,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('  ${getTestPr(itemf["description"]).round()}%',
                                      style: const TextStyle(color: Colors.blueGrey),
                                    ),
                                  ),
                                ]),
                            RichText(
                                text: HTML.toTextSpan(
                                    context,
                                    '<div style="width: 100%, text-align: left; font-size: 12px;">' +
                                        getTestCr(itemf["description"]) +
                                        "</div>")),
                          ]),
                      onTap: () async {
                      }
                  ));
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(

            onPressed: (){
              Navigator.pop(context);
            },child: Text("Назад"),),
        )
      ],
    );
  }

  Widget writingComment(context, Item itm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 300.0, // Change as per your requirement
          width: 300.0, // Change as per your requirement
          child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Html(data: jsonDecode(itm.description ?? "{}")["comment"]),
              ])),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(

            onPressed: (){
              Navigator.pop(context);
            },child: Text("Назад"),),
        )
      ],
    );
  }
}
