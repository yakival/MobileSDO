import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:myapp/widgets/config.dart';
import 'package:path_provider/path_provider.dart';

Future<bool> hasNetwork(context) async {
  await initGlobalData();
  var ret = false;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    ret = true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    ret = true;
  }
  if (ret) {
    var res_ = await httpAPI(
        "close/students/mobileApp.asp", '{"command": ""}', context);
    if (jsonEncode(res_) == "{}") ret = false;
  }
  return ret;
}

Future<void> downloadFileAPI(urlfile, fileName) async {
  int _total = 1, _received = 0, _index = -1;
  late StreamSubscription<List<int>> responseStream;
  final List<int> _bytes = [];

  var _url = GlobalData.baseUrl;
  var _load = false;

  final Directory appDir = await getApplicationDocumentsDirectory();
  var fn = fileName.split('/').last;
  var _file = '${appDir.path}/storage/$fn';

  Request req = Request('GET', Uri.parse('$_url$urlfile'));
  req.headers.addAll(<String, String>{
    'Authorization': 'Basic ' + base64Encode(utf8.encode('$GlobalData.username:$GlobalData.password')),
  });
  final StreamedResponse _response =
  await Client().send(req);
  if (_response.statusCode != 200) {
    return;
  }

  _total = _response.contentLength ?? 0;
  var _free = await DiskSpace.getFreeDiskSpace;
  _free = (_free ?? 0) * (1024.0 * 1024.0);
  if (_total > _free) {
    return;
  }

  final checkPath =
  await Directory('${appDir.path}/storage').exists();
  if (!checkPath) {
    Directory('${appDir.path}/storage')
        .createSync(recursive: true);
  }
  final checkFile =
  await File(_file).exists();
  if (checkFile) {
    File(_file)
        .deleteSync(recursive: true);
  }
  final file = await File(_file);

  responseStream = await _response.stream.listen((value) async {
    //_bytes.addAll(value);
    file.writeAsBytesSync(value, mode: FileMode.append, flush: true);
    _received += value.length;
  }, onDone: () async {
    responseStream.pause();
    await responseStream.cancel();

    _load = true;
    _total = 1;
    _received = 0;
  }, onError: (e, sT) async {
    file.deleteSync(recursive: true);
    _total = 1;
    _received = 0;
    return true;
  });

  while (!_load) {
    await Future.delayed(const Duration(microseconds: 500));
  }
}

Future<Object> httpAPI(url1, params, context) async {
  var _username = GlobalData.username;
  var _password = GlobalData.password;
  var _url = GlobalData.baseUrl;
  var auth = 'Basic ' + base64Encode(utf8.encode('$_username:$_password'));

  //var isOnline = await hasNetwork(context);

  try {
    final response =
        await post(Uri.parse('$_url/$url1'), body: params, // {'param': param},
            headers: <String, String>{
          'Authorization': auth,
          HttpHeaders.contentTypeHeader: "application/json",
        });

    if (response.statusCode == 200) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json.length > 0) {
        if (json!["error"] != null) {
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(json!["error"].toString()),
              backgroundColor: Colors.red,
            ));
          }
          return jsonDecode("{}");
        } else {
          return json!["data"];
        }
      } else {
        return json;
      }
    } else {
      if (response.statusCode == 401 || response.statusCode == 403) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ошибка авторизации на сервере'),
            backgroundColor: Colors.red,
          ));
        }
        return jsonDecode("{}");
      } else {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ошибка обращения к серверу'),
            backgroundColor: Colors.red,
          ));
        }
        return jsonDecode("{}");
      }
    }
  } on SocketException catch (_) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Ошибка подключения"),
        backgroundColor: Colors.red,
      ));
    }
    return jsonDecode("{}");
  }
}

Future<Object> httpAPIMultipart(url1, params, filePath, context) async {
  var _username = GlobalData.username;
  var _password = GlobalData.password;
  var _url = GlobalData.baseUrl;
  var auth = 'Basic ' + base64Encode(utf8.encode('$_username:$_password'));

  var postUri = Uri.parse('$_url/$url1');

  MultipartRequest request = MultipartRequest("POST", postUri);
  request.headers['Authorization'] = auth;

  request.fields['jsondata'] = params;

  if (filePath != null) {
    MultipartFile multipartFile =
        await MultipartFile.fromPath('file', filePath);
    request.files.add(multipartFile);
  }

  StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    var data = await response.stream.toBytes();
    var json = jsonDecode(utf8.decode(data));
    if (json.length > 0) {
      if (json!["error"] != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(json!["error"].toString()),
          backgroundColor: Colors.red,
        ));
        return jsonDecode("{}");
      } else {
        return json!["data"];
      }
    } else {
      return json;
    }
  } else {
    if (response.statusCode == 401 || response.statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ошибка авторизации на сервере'),
        backgroundColor: Colors.red,
      ));
      return jsonDecode("{}");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ошибка обращения к серверу'),
        backgroundColor: Colors.red,
      ));
      return jsonDecode("{}");
    }
  }
}
