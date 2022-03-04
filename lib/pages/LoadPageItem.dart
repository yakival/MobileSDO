import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:myapp/widgets/http_post.dart';

import 'package:myapp/widgets/config.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/database/CourseModel.dart';
import 'package:http/http.dart' as http;

class LoadPageItem extends StatefulWidget {
  const LoadPageItem({
    Key? key,
  }) : super(key: key);

  @override
  State<LoadPageItem> createState() => _LoadPageItemState();
}

class _LoadPageItemState extends State<LoadPageItem> {
  List<Item> _list = [];

  int _total = 1, _received = 0;
  String _fn = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> _downloadFile(Item itm, context, args) async {
    late StreamSubscription<List<int>> responseStream;
    final List<int> _bytes = [];

    var _url = GlobalData.baseUrl;
    var _file = itm.path;

    var isOnline = await hasNetwork(context);
    if (!isOnline) return;

    final StreamedResponse _response =
        await http.Client().send(http.Request('GET', Uri.parse('$_url$_file')));
    _total = _response.contentLength ?? 0;
    setState(() {
      _fn = itm.path!.split('/').last;
    });

    responseStream = _response.stream.listen((value) {
      setState(() {
        _bytes.addAll(value);
        _received += value.length;
      });
    }, onDone: () async {
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
      final file = File(itm.localpath!);
      final exist = await file.exists();
      if (exist) file.deleteSync(recursive: true);
      await file.writeAsBytes(_bytes, flush: false);
      itm.load = true;
      await updateItem(itm);

      responseStream.cancel();
      setState(() {
        _total = 1;
        _received = 0;
      });
      _getData(context, args);
    }, onError: (e, sT) async {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e\n$sT'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _total = 1;
        _received = 0;
      });
      _getData(context, args);
      return true;
    });
  }

  Future<void> _getData(context, args) async {
    if (_list.isEmpty) {
      await initGlobalData();
      _list = await getCourseItem(args.id);
    }
    for (var itm in _list) {
      if (!(itm.load ?? false)) {
        _downloadFile(itm, context, args);
        return;
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Course;
    if (_list.isEmpty) {
      Future.delayed(Duration.zero, () => _getData(context, args));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(args.name! + ' (загрузка данных курса)'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            const Text(
              "Загрузка файла:",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
            ),
            Text(
              _fn,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            Center(
                child: CircularProgressIndicator(
              value: _received / _total,
            )),
          ],
        ),
      ),
    );
  }
}
