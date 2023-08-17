import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:open_file_plus/open_file_plus.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PlayerPage> {
  Item _args = Item();
  Timer? _timer;
  bool isLoad = false;
  int? idlog;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  openFile(filePath) async {
    var _result = await OpenFile.open(filePath);
    if (_result.message == "done") {
      isLoad = true;
      if((_args.time ?? 0) == 0 && (_args.rate ?? 0) == 0) {
        _args.time = (_args.time ?? 0) + 1;
        await updateItem(_args);
      }
      _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) async {
        _args.time = (_args.time ?? 0) + 1;
        await updateItem(_args);
        setState(() {});
        var res = await httpAPI(
            "close/students/sync.asp",
            '{"id":"' + _args.guid! + '", "idlog": ' + ((idlog == null)?"null":idlog.toString()) +
                ', "type":"RATEBOOK", "data": 1}',
            context);
        var json = res as Map<String, dynamic>;
        idlog = json["idlog"];
      });
      setState(() {});
    }
  }

  String showTime() {
    int min = (_args.time ?? 0) ~/ 60;
    int sec = ((_args.time ?? 0) - min * 60).toInt();
    return ((min < 10) ? "0" : "") +
        min.toString() +
        ":" +
        ((sec < 10) ? "0" : "") +
        sec.toString();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Item;
    setState(() {
      _args = args;
    });
    if (!isLoad) {
      Future.delayed(Duration.zero, () => openFile(args.localpath));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(args.name!),
      ),
      bottomNavigationBar:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              Navigator.of(context).pop();
            });
          },
          child: const Text('Оглавление'),
        ),
      ]),
      body: Center(
          child: (isLoad)
              ? Text(showTime(),
                  style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 28))
              : const Text("Нет поддержки формата",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 22))),
    );
  }
}
